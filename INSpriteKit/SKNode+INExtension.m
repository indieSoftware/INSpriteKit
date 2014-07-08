// SKNode+INExtension.m
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


#import "SKNode+INExtension.h"
#import <objc/runtime.h>


static const char *SKNodeINExtensionTouchPriorityKey = "SKNodeINExtensionTouchPriorityKey";
static const char *SKNodeINExtensionSupportedMouseButtonKey = "SKNodeINExtensionSupportedMouseButtonKey";


@implementation SKNode (INExtension)

- (NSInteger)touchPriority {
    return [((NSNumber *)objc_getAssociatedObject(self, SKNodeINExtensionTouchPriorityKey)) integerValue];
}

- (void)setTouchPriority:(NSInteger)touchPriority {
    objc_setAssociatedObject(self, SKNodeINExtensionTouchPriorityKey, @(touchPriority), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (INSKMouseButton)supportedMouseButtons {
    NSNumber *number = ((NSNumber *)objc_getAssociatedObject(self, SKNodeINExtensionSupportedMouseButtonKey));
    INSKMouseButton returnValue = INSKMouseButtonLeft;
    if (number != nil) {
        returnValue = [number integerValue];
    }
    return returnValue;
}

- (void)setSupportedMouseButtons:(INSKMouseButton)supportedMouseButtons {
    objc_setAssociatedObject(self, SKNodeINExtensionSupportedMouseButtonKey, @(supportedMouseButtons), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)bringToFront {
    SKNode *parent = self.parent;
    [self removeFromParent];
    [parent addChild:self];
}

- (void)sendToBack {
    SKNode *parent = self.parent;
    [self removeFromParent];
    [parent insertChildOrNil:self atIndex:0];
}

- (void)addChildOrNil:(SKNode *)node {
    if (node != nil) {
        [self addChild:node];
    }
}

- (void)insertChildOrNil:(SKNode *)node atIndex:(NSInteger)index {
    // skip nils
    if (node == nil) {
        return;
    }
    
    // remove node from old parent which may be this one
    if (node.parent != nil) {
        [node removeFromParent];
    }
    
    // get all children beginning from the index and remove them
    NSRange range = NSMakeRange(index, self.children.count - index);
    NSArray *childrenAtIndex = [self.children subarrayWithRange:range];
    [self removeChildrenInArray:childrenAtIndex];

    // add node and the children afterwards
    [self addChild:node];
    for (SKNode *child in childrenAtIndex) {
        // prevent adding the node twice for the case it was already a child
        if (child != node) {
            [self addChild:child];
        }
    }
}

- (void)changeParent:(SKNode *)parent {
    if (self.parent == nil) {
        [parent addChild:self];
    } else if (self.parent == parent) {
        // Already child of the parent, so do nothing
    } else {
        CGPoint convertedPosition = [self.parent convertPoint:self.position toNode:parent];
        [self removeFromParent];
        [parent addChild:self];
        self.position = convertedPosition;
    }
}

- (void)runActions:(NSArray *)actions {
    [self runAction:[SKAction sequence:actions]];
}

- (void)runActions:(NSArray *)actions withKey:(NSString *)key {
    [self runAction:[SKAction sequence:actions] withKey:key];
}


@end
