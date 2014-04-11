// SKNode+INExtension.h
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


#import <SpriteKit/SpriteKit.h>

@interface SKNode (INExtension)


/**
 Removes and re-adds the node to its parent so the node will be at top of all other parent's childen.
 */
- (void)bringToFront;


/**
 Removes the node and inserts it to the parent at position 0 so it will become the first node in the tree with all other children ontop of it.
 */
- (void)sendToBack;


/**
 Adds a node as child, but may also be nil which will not result in an exception.
 
 Same as
 
    if (node != nil) {
        [self addChild:node];
    }
 
 @param node The node or nil to add as child.
 */
- (void)addChildOrNil:(SKNode *)node;


/**
 Runs a new action sequence with the given actions.
 
 It's a shortcut for writing
 
    [self runAction:[SKAction sequence:actions]]
 
 @param actions An array with the actions to make a sequence of.
 */
- (void)runActions:(NSArray *)actions;


/**
 Runs a new action sequence with the given actions and a name.
 
 Same as calling
 
    [self runAction:[SKAction sequence:actions] withKey:key];
 
 @param actions An array with the actions to make a sequence of.
 @param key The key name of this added sequence.
 */
- (void)runActions:(NSArray *)actions withKey:(NSString *)key;


@end
