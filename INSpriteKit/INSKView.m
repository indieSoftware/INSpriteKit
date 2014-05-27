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


@interface INSKView ()

// A dictionary with touch locations as keys and the top node which handles the touch as value.
@property (nonatomic, strong) NSMutableDictionary *nodeForTouchMapping;

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
    NSArray *nodesAtPosition = [self.scene nodesAtPoint:position];
    SKNode *nodeForTouch = nil;
    NSInteger nodeForTouchPriority = 0;
    NSString *nodeForTouchTag = nil;
    for (SKNode *node in nodesAtPosition) {
        // Only nodes which are enabled for touches, not hidden and not fully transparent should receive touches.
        if (!node.userInteractionEnabled || node.hidden || node.alpha == 0.0) {
            continue;
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


@end
