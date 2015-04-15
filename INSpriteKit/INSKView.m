// INSKView.m
//
// Copyright (c) 2014 Sven Korset
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


#import "INSKView.h"
#import "SKNode+INExtension.h"
#import "SKSpriteNode+INExtension.h"


@interface INSKView ()

// A dictionary with touch locations as keys and the top node which handles the touch as value. iOS only.
@property (nonatomic, strong) NSMutableDictionary *nodeForTouchMapping;
// The node which currently is attached to a mouse event. OS X only.
@property (nonatomic, weak) SKNode *nodeForMouseEvent;
// The number of actually pressed buttons. OS X only.
@property (nonatomic, assign) NSInteger numberOfMouseButtonsPressed;

// A list of nodes which want to receive each touch regardless of their position.
@property (nonatomic, strong) NSMutableSet *touchObservingNodes;

@end


@implementation INSKView

#pragma mark - init methods

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self == nil) return self;
    
    [self setupINSKView];
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self == nil) return self;
    
    [self setupINSKView];
    
    return self;
}

- (void)setupINSKView {
    self.nodeForTouchMapping = [NSMutableDictionary dictionary];
    self.touchObservingNodes = [NSMutableSet set];
    self.deliverRightMouseButtonEventsToScene = YES;
}


#pragma mark - private methods

- (NSString *)treeOrderTagForNode:(SKNode *)node {
    // Walks the tree up to the root which is the scene and collects the index for each subnode.
    // Each subnode's index will be printed as a hexadecimal value with 4 digits.
    // Returns the empty string for the scene itself.
    NSString *tag = @"";
    SKNode *currentNode = node;
    while (currentNode.parent != nil) {
        NSUInteger index = [currentNode.parent.children indexOfObject:currentNode];
        tag = [NSString stringWithFormat:@"%04lx%@", (unsigned long)index, tag];
        currentNode = currentNode.parent;
    }
    return tag;
}


#pragma mark - public methods

- (void)addTouchObservingNode:(SKNode *)node {
    [self.touchObservingNodes addObject:node];
}

- (void)removeTouchObservingNode:(SKNode *)node {
    [self.touchObservingNodes removeObject:node];
}

- (SKNode *)topInteractingNodeAtPosition:(CGPoint)position {
    return [self topInteractingNodeAtPosition:position withSupportedMouseButton:INSKMouseButtonAll];
}

- (SKNode *)topInteractingNodeAtPosition:(CGPoint)position withSupportedMouseButton:(INSKMouseButton)mouseButton {
    NSArray *nodesAtPosition = [self.scene nodesAtPoint:position];
    SKNode *nodeForTouch = nil;
    NSInteger nodeForTouchPriority = 0;
    NSString *nodeForTouchTag = nil;
    for (SKNode *node in nodesAtPosition) {
        // Only nodes which are enabled for touches, not hidden and not fully transparent should receive touches.
        if (!node.userInteractionEnabled || node.hidden || node.alpha == 0.0) {
            continue;
        }

#if !TARGET_OS_IPHONE
        // Only accept nodes which support the mouse buttons, but only on OS X.
        if (!(node.supportedMouseButtons & mouseButton)) {
            continue;
        }
#endif
        
        // For sprite nodes only accept touches inside of the texture.
        if ([node isKindOfClass:[SKSpriteNode class]]) {
            CGPoint positionInNode = [node.scene convertPoint:position toNode:node];
            if (![(SKSpriteNode *)node isPointInside:positionInNode]) {
                continue;
            }
        }
        
        // Use first node found.
        if (nodeForTouch == nil) {
            nodeForTouch = node;
            nodeForTouchPriority = nodeForTouch.touchPriority;
            nodeForTouchTag = nil;
            continue;
        }
        
        // The highest touch priority has always priority.
        NSInteger nodePriority = node.touchPriority;
        if (nodePriority > nodeForTouchPriority) {
            nodeForTouch = node;
            nodeForTouchPriority = nodePriority;
            nodeForTouchTag = nil;
            continue;
        } else if (node.touchPriority < nodeForTouch.touchPriority) {
            // Ignore nodes with lower touch priority.
            continue;
        }
        
        // The zPosition has a global impact on the rendering order.
        // The higher the zPosition the later the rendering,
        // so take the one with the highest zPosition for touch interaction.
        if (node.zPosition > nodeForTouch.zPosition) {
            nodeForTouch = node;
            nodeForTouchPriority = nodePriority;
            nodeForTouchTag = nil;
            continue;
        } else if (node.zPosition < nodeForTouch.zPosition) {
            // Ignore any nodes with a lower zPosition
            continue;
        }
        
        // The rendering order in the tree has to descide, the last rendered object receives the touch.
        NSString *nodeTag = [self treeOrderTagForNode:node];
        // The tag is lazily created, so create it now if not yet done.
        if (nodeForTouchTag == nil) {
            nodeForTouchTag = [self treeOrderTagForNode:nodeForTouch];
        }
        if ([nodeForTouchTag compare:nodeTag] == NSOrderedAscending) {
            // Higher string tags should receive touches.
            nodeForTouch = node;
            nodeForTouchPriority = nodePriority;
            nodeForTouchTag = nodeTag;
            continue;
        } else {
            // Not highest node, ignore it.
            continue;
        }
    }
    return nodeForTouch;
}


#if TARGET_OS_IPHONE
#pragma mark - touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // Deliver touches to all observers.
    for (SKNode *node in self.touchObservingNodes) {
        [node touchesBegan:touches withEvent:event];
    }
    
    // No scene at all, ignore all touches.
    if (self.scene == nil) {
        return;
    }
    
    // User interaction disabled, ignore touches.
    if (!self.userInteractionEnabled) {
        return;
    }

    // Deliver touches to touched nodes.
    for (UITouch *touch in touches) {
        // Find new node for touch.
        CGPoint touchLocation = [touch locationInNode:self.scene];
        SKNode *nodeForTouch = [self topInteractingNodeAtPosition:touchLocation];
        if (nodeForTouch == nil) {
            // No node found for touch at the position, use the scene.
            nodeForTouch = self.scene;
        }
        
        // save found node for touch position
        NSValue *key = [NSValue valueWithCGPoint:[touch locationInView:nil]];
        [self.nodeForTouchMapping setObject:nodeForTouch forKey:key];
        // deliver touch to node
        [nodeForTouch touchesBegan:[NSSet setWithObject:touch] withEvent:event];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    // Deliver touches to all observers.
    for (SKNode *node in self.touchObservingNodes) {
        [node touchesMoved:touches withEvent:event];
    }
    
    // Deliver touches to touched nodes.
    for (UITouch *touch in touches) {
        // Get saved node for touch.
        NSValue *key = [NSValue valueWithCGPoint:[touch previousLocationInView:nil]];
        SKNode *nodeForTouch = [self.nodeForTouchMapping objectForKey:key];
        // Fallback because the touch with the same location may be returned.
        if (nodeForTouch == nil) {
            key = [NSValue valueWithCGPoint:[touch locationInView:nil]];
            nodeForTouch = [self.nodeForTouchMapping objectForKey:key];
            if (nodeForTouch == nil) {
                // Still no node found, maybe there is no scene so ignore touch.
                continue;
            }
        }
        
        // Update touch key.
        [self.nodeForTouchMapping removeObjectForKey:key];
        key = [NSValue valueWithCGPoint:[touch locationInNode:nil]];
        [self.nodeForTouchMapping setObject:nodeForTouch forKey:key];
        // Deliver touch to node.
        [nodeForTouch touchesMoved:[NSSet setWithObject:touch] withEvent:event];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // Deliver touches to all observers.
    for (SKNode *node in self.touchObservingNodes) {
        [node touchesEnded:touches withEvent:event];
    }
    
    // Deliver touches to touched nodes.
    for (UITouch *touch in touches) {
        // Get saved node for touch.
        NSValue *key = [NSValue valueWithCGPoint:[touch previousLocationInView:nil]];
        SKNode *nodeForTouch = [self.nodeForTouchMapping objectForKey:key];
        // Fallback because the touch with the same location may be returned.
        if (nodeForTouch == nil) {
            key = [NSValue valueWithCGPoint:[touch locationInView:nil]];
            nodeForTouch = [self.nodeForTouchMapping objectForKey:key];
            if (nodeForTouch == nil) {
                // Still no node found, maybe there is no scene so ignore touch.
                continue;
            }
        }
        
        // Clean up touch mapping.
        [self.nodeForTouchMapping removeObjectForKey:key];
        // Deliver touch to node.
        [nodeForTouch touchesEnded:[NSSet setWithObject:touch] withEvent:event];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    // Deliver touches to all observers.
    for (SKNode *node in self.touchObservingNodes) {
        [node touchesCancelled:touches withEvent:event];
    }
    
    // Deliver touches to touched nodes.
    for (UITouch *touch in touches) {
        // Get saved node for touch.
        NSValue *key = [NSValue valueWithCGPoint:[touch previousLocationInView:nil]];
        SKNode *nodeForTouch = [self.nodeForTouchMapping objectForKey:key];
        // Fallback because the touch with the same location may be returned.
        if (nodeForTouch == nil) {
            key = [NSValue valueWithCGPoint:[touch locationInView:nil]];
            nodeForTouch = [self.nodeForTouchMapping objectForKey:key];
            if (nodeForTouch == nil) {
                // Still no node found, maybe there is no scene so ignore touch.
                continue;
            }
        }
        
        // Clean up touch mapping.
        [self.nodeForTouchMapping removeObjectForKey:key];
        // Deliver touch to node.
        [nodeForTouch touchesCancelled:[NSSet setWithObject:touch] withEvent:event];
    }
}

#else // OSX
#pragma mark - mouse events

- (void)mouseDown:(NSEvent *)theEvent {
    // Deliver mouse event to all observers.
    for (SKNode *node in self.touchObservingNodes) {
        [node mouseDown:theEvent];
    }
    
    // Track mouse events
    self.numberOfMouseButtonsPressed++;
    //NSLog(@"currently mouse buttons pressed: %ld", (long)self.numberOfMouseButtonsPressed);
    
    // No scene at all, ignore all events.
    if (self.scene == nil) {
        return;
    }
    
    // First button clicked
    if (self.numberOfMouseButtonsPressed == 1) {
        // Find node for event.
        CGPoint positionInScene = [theEvent locationInNode:self.scene];
        SKNode *nodeForEvent = [self topInteractingNodeAtPosition:positionInScene withSupportedMouseButton:INSKMouseButtonLeft];
        if (nodeForEvent == nil) {
            // No node found for event at the position, use the scene.
            nodeForEvent = self.scene;
        }
        
        // save found node for event processing
        self.nodeForMouseEvent = nodeForEvent;
    }
    
    // Deliver touch to node
    [self.nodeForMouseEvent mouseDown:theEvent];
}

- (void)rightMouseDown:(NSEvent *)theEvent {
    // Deliver mouse event to all observers.
    for (SKNode *node in self.touchObservingNodes) {
        [node rightMouseDown:theEvent];
    }
    
    // Track mouse events
    self.numberOfMouseButtonsPressed++;
    //NSLog(@"currently mouse buttons pressed: %ld", (long)self.numberOfMouseButtonsPressed);
    
    // Support AppKit's defaults behavior
    if (!self.deliverRightMouseButtonEventsToScene) {
        [super rightMouseDown:theEvent];
        return;
    }
    
    // No scene at all, ignore all events.
    if (self.scene == nil) {
        return;
    }
    
    // First button clicked
    if (self.numberOfMouseButtonsPressed == 1) {
        // Find node for event.
        CGPoint positionInScene = [theEvent locationInNode:self.scene];
        SKNode *nodeForEvent = [self topInteractingNodeAtPosition:positionInScene withSupportedMouseButton:INSKMouseButtonRight];
        if (nodeForEvent == nil) {
            // No node found for event at the position, use the scene.
            nodeForEvent = self.scene;
        }
        
        // save found node for event processing
        self.nodeForMouseEvent = nodeForEvent;
    }
    
    // Deliver touch to node
    [self.nodeForMouseEvent rightMouseDown:theEvent];
}

- (void)otherMouseDown:(NSEvent *)theEvent {
    // Deliver mouse event to all observers.
    for (SKNode *node in self.touchObservingNodes) {
        [node otherMouseDown:theEvent];
    }
    
    // Track mouse events
    self.numberOfMouseButtonsPressed++;
    //NSLog(@"currently mouse buttons pressed: %ld", (long)self.numberOfMouseButtonsPressed);
    
    // No scene at all, ignore all events.
    if (self.scene == nil) {
        return;
    }

    // First button clicked
    if (self.numberOfMouseButtonsPressed == 1) {
        // Find node for event.
        CGPoint positionInScene = [theEvent locationInNode:self.scene];
        SKNode *nodeForEvent = [self topInteractingNodeAtPosition:positionInScene withSupportedMouseButton:INSKMouseButtonOther];
        if (nodeForEvent == nil) {
            // No node found for event at the position, use the scene.
            nodeForEvent = self.scene;
        }
        
        // save found node for event processing
        self.nodeForMouseEvent = nodeForEvent;
    }
    
    // Deliver touch to node
    [self.nodeForMouseEvent otherMouseDown:theEvent];
}

- (void)mouseDragged:(NSEvent *)theEvent {
    // Deliver mouse event to all observers.
    for (SKNode *node in self.touchObservingNodes) {
        [node mouseDragged:theEvent];
    }
    
    // Deliver event to active node.
    [self.nodeForMouseEvent mouseDragged:theEvent];
}

- (void)rightMouseDragged:(NSEvent *)theEvent {
    // Deliver mouse event to all observers.
    for (SKNode *node in self.touchObservingNodes) {
        [node rightMouseDragged:theEvent];
    }
    
    // Support AppKit's defaults behavior
    if (!self.deliverRightMouseButtonEventsToScene) {
        [super rightMouseDragged:theEvent];
        return;
    }
    
    // Deliver event to active node.
    [self.nodeForMouseEvent rightMouseDragged:theEvent];
}

- (void)otherMouseDragged:(NSEvent *)theEvent {
    // Deliver mouse event to all observers.
    for (SKNode *node in self.touchObservingNodes) {
        [node otherMouseDragged:theEvent];
    }
    
    // Deliver event to active node.
    [self.nodeForMouseEvent otherMouseDragged:theEvent];
}

- (void)mouseUp:(NSEvent *)theEvent {
    // Deliver mouse event to all observers.
    for (SKNode *node in self.touchObservingNodes) {
        [node mouseUp:theEvent];
    }
    
    // Track mouse events
    self.numberOfMouseButtonsPressed--;
    //NSLog(@"currently mouse buttons pressed: %ld", (long)self.numberOfMouseButtonsPressed);
    
    // Deliver event to active node.
    [self.nodeForMouseEvent mouseUp:theEvent];
}

- (void)rightMouseUp:(NSEvent *)theEvent {
    // Deliver mouse event to all observers.
    for (SKNode *node in self.touchObservingNodes) {
        [node rightMouseUp:theEvent];
    }
    
    // Track mouse events
    self.numberOfMouseButtonsPressed--;
    //NSLog(@"currently mouse buttons pressed: %ld", (long)self.numberOfMouseButtonsPressed);
    
    // Support AppKit's defaults behavior
    if (!self.deliverRightMouseButtonEventsToScene) {
        [super rightMouseUp:theEvent];
        return;
    }

    // Deliver event to active node.
    [self.nodeForMouseEvent rightMouseUp:theEvent];
}

- (void)otherMouseUp:(NSEvent *)theEvent {
    // Deliver mouse event to all observers.
    for (SKNode *node in self.touchObservingNodes) {
        [node otherMouseUp:theEvent];
    }
    
    // Track mouse events
    self.numberOfMouseButtonsPressed--;
    //NSLog(@"currently mouse buttons pressed: %ld", (long)self.numberOfMouseButtonsPressed);
    
    // Deliver event to active node.
    [self.nodeForMouseEvent otherMouseUp:theEvent];
}

#endif // OS X


@end
