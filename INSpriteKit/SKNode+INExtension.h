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
#import "INSKTypes.h"


@interface SKNode (INExtension)

/**
 The priority of this node to get touches. Defaults to 0.
 
 The top visible node with the highest priority will receive the touches.
 Normally the last rendered and top visible node will receive any touches,
 but with setting a touch priority the node can receive the touches even when the node is under other nodes.
 
 @warning For the touch delivery to work the Sprite Kit view has to be an instance of INSKView instead of SKView.
 
 @see INSKView
 */
@property (nonatomic, assign) NSInteger touchPriority;


/**
 A bit mask to define the mouse buttons which this node should accept. OS X only.
 Defaults to INSKMouseButtonLeft so only left mouse buttons are used for hit detections.
 
 Take into count, that when setting to a mask which includes the right mouse button
 the right mouse button can only be detected when the view delivers it which an SKView instance does not per default,
 but INSKView does. However, an INSKView instance is needed in any case for this property to work.

 @warning For the mouse button support to work the Sprite Kit view has to be an instance of INSKView instead of SKView.
 
 @see INSKView
 */
@property (nonatomic, assign) INSKMouseButton supportedMouseButtons;

#pragma mark - Tree order manipulation
/// @name Tree order manipulation

/**
 Removes and re-adds the node to its parent so the node will be at top of all other parent's childen in the tree.
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
 Inserts a node as child to a specific position the safe and working way.
 
 Due to a bug in Sprite Kit on iOS 7 insertChild:atIndex: doesn't insert the node but adds it only
 so the rendering of an inserted node will always be the last in order which is not the correct behavior.
 This method will remove all children beginning from the index, adding the node and re-adding all children afterwards.
 So this method workarounds the rendering bug and should be used instead of SKNode's insertChild:atIndex:.
 
 At plus it is safe to insert nil which does nothing or a node which has already a parent in which case
 it is first removed from the parent before adding to the new.
 
 @param node The node to insert. May be nil.
 @param index The index in the children array where to insert the node. Has to be in bounds of the current children array.
 */
- (void)insertChildOrNil:(SKNode *)node atIndex:(NSInteger)index;


/**
 Replaces the node's parent and converts its position.
 
 Removes the node from the current parent and adds it to the new.
 The node's position will be converted so the node's position in the global scene will remain.
 Both nodes have to be in the scene graph otherwise the node is just added to the new parent without any conversions.
 The scale value is unaffected by this so has to be adopted manually if needed.
 If the node currently has no parent it will just be added to the new parent without any new position calculations.
 
 @param parent The new node's parent node to add this node to.
 */
- (void)changeParent:(SKNode *)parent;


#pragma mark - Actions
/// @name Actions

/**
 Runs a new action sequence with the given actions.
 
 It's a shortcut for writing
 
    [self runAction:[SKAction sequence:actions]];
 
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


#pragma mark - Debugging
/// @name Debugging

/**
 Returns a string representation of the node tree for debugging purposes.
 
 The method will print the tree's nodes.
 Each node's name, it's class and position will be printed, indented by '-' characters depending of their level.
 
 @return The node's tree as a string representation.
 */
- (NSString *)stringifyNodeTree;


@end
