// INSKView.h
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


/**
 A SKView replacement which has a workaround for touch delivery bugs in Sprite Kit. At plus it adds behavior for global touch observers.
 
 On iOS 7 and OS X 10.9 [SKNode userInteractionEnabled] is ignored, but should be respected
 otherwise a sprite or label over a touch respecting node will swallow all touches instead of ignoring
 and delivering them to the node beneath which should handle the touch instead.

 A INSKView respects the userInteractionEnabled property as well as the node's visibility state.
 Only nodes with userInteractionEnabled set to YES, hidden set to NO and an alpha greater than 0 potentially receives touches.
 The touch receiving order is defined by the node's rendering order with the last rendered node and thus the top most one gets any touches first.
 The zPosition has a direct impact on the rendering order and is also respected when delivering touches.
 At plus the touch receiving order may be manipulated directly with the [SKNode touchPriority] property.
 The node with the highest touchPriority will get the touch even when other nodes are rendered over this one.
 
 SKView also uses children of nodes for determining the one who should receive a touch.
 This will result in unexpected behavior, but not so with INSKView.
 On SKView, when adding a sprite node as a child to a button the button receives touches inside of an extended frame which includes both the child's and the button's frame.
 So the button will trigger even when the touch is outside.
 Rotating a node will also extend the frame, so a rotated button has a bigger frame and touching the corners of the frame even when outside of the button's visual representation will trigger touch delivery to this button.
 On INSKView the rotated sprite node texture will be used for touch detection so the touch has to be inside of the visual representation of the button to trigger.
 
 To use the INSKView and the touch delivering mechanism just replace the class name in the storyboard or nib file
 with 'INSKView' or instantiate a INSKView object manually. No additional set up is needed.

 If overriding any touch methods of INSKView make sure to call super.
 
 Nodes which currently handle a touch are retained and do receive touch events even when their interactions or visibility state changes during a touch event.
 
 @warning *Limitation:* Each node may have at most 65'536 children otherwise the correct touch receiver won't be determined.
 */
@interface INSKView : SKView


/**
 Adds a node as a global touch observer.
 
 Global touch observers will get each touch event regardless of their position in the scene, their visibility or their userInteractionEnabled state.
 Each observer will be informed before the proper touched object.
 The order of informing each observer is defined by their order added as an observer, meaning the first observer added will receive touch events before any other observer.
 Obersvers in the scene may get informed twice for each touch, first as the observer, second when touched on it.
 To prevent the double calls set userInteractionEnabled to NO so the node won't get regular touches, only those as an observer.
 When the node isn't interested in touch events anymore remove it from the observing list with removeTouchObservingNode:.
 
 @param node The node which will be informed about any touch events.
 @see removeTouchObservingNode:
 */
- (void)addTouchObservingNode:(SKNode *)node;


/**
 Removes the node from the list of global touch observers.
 
 @param node The overserving node to remove.
 */
- (void)removeTouchObservingNode:(SKNode *)node;


/**
 Returns the node which will receives touches/mouse clicks occuring at a specified position.
 
 This method may also be called on OS X, in which case any interacting node will be returned.
 In fact this method calls topInteractingNodeAtPosition:withSupportedMouseButton: with INSKMouseButtonAll for the mouseButton value.
 
 @param position The position in the scene coordinate system.
 @return The node which will receive any touches/mouse clicks at the given position or nil if there is none.
 */
- (SKNode *)topInteractingNodeAtPosition:(CGPoint)position;


/**
 Returns the node which will receives touches/clicks occuring at a specified position and for a specific mouse button.
 This method may also be called on iOS for touches where the mouse button value is ignored.
 
 INSKView uses this method to retrieve the interacting node which should handle a touch/mouse event.
 If no node could be found by this method nil is returned and INSKView will deliver the touches to the scene.
 The method can be used to check wheter a touch/click at a position will be handled by a node or not.
 This can be handy when mixing touches for UIKit/AppKit and Sprite Kit, i.e. when a UIGestureRecognizer wants to see if a touch would be otherwise on a INSKButtonNode.
 
 @param position The position in the scene coordinate system.
 @param mouseButton A specific mouse button which has to be supported by the node or INSKMouseButtonAll for any interacting node. If the value is 0 no node will match and nil will be returned. However, on iOS the value will be ignored and any interacting node will match.
 @return The interacting node for a touch/click at a given position or nil if there is none found.
 */
- (SKNode *)topInteractingNodeAtPosition:(CGPoint)position withSupportedMouseButton:(INSKMouseButton)mouseButton;


/**
 Flag to deliver right mouse button events to the scene and their nodes. OS X only. Defaults to YES.
 
 AppKit uses the right button for presenting context menus and therefore SKView does not deliver right mouse clicks to the scene.
 To support SKView's default behavior and use a context menu set this property to NO.
 INSKView bypasses this behavior with setting the property to YES so right mouse button clicks can be processed in games defaultly.
 */
@property (nonatomic, assign) BOOL deliverRightMouseButtonEventsToScene;


@end
