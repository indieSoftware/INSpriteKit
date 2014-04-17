// INSKButtonNode.h
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


/**
 A button node for easy action handling.
 
 This class represents a button which can be enabled and disabled.
 The highlight state will be updated by the user's touch and the correspondign selectors will be called.
 The INSKButtonNode instance can also be used as a toggle button with a selected state which will also be automatically updated.
 After initializing a new instance assign SKNode objects to the node properties.
 They will be added to and removed from the scene's tree automatically upon the state changes of the button.
 At least the nodeNormal and nodeHighlighted node should be set with a visual representation or the button will be invisible.
 It is possible to use the same node for different states, i.e. use the same visual representation for normal and highlight just assign the SKNode to all the nodeXXX properties.
 The nodeDisabled is only used if the enabled flag is manually set to NO.
 nodeSelectedNormal and nodeSelectedHighlighted are only needed if the selected flag is also used.
 Register for target-selector callbacks to get informed about user input.
 
    INSKButtonNode *button = [INSKButtonNode buttonNodeWithImageNamed:@"imageName"];
    button.position = buttonPosition;
    [button setTouchUpInsideTarget:self selector:@selector(buttonPressed:)];
    [self addChild:button];
 
 */
@interface INSKButtonNode : SKSpriteNode

// ------------------------------------------------------------
#pragma mark - Properties
// ------------------------------------------------------------

/**
 Flag indicating whether the button is enabled. Defaults to YES.
 
 Disable the button manually according to the logic.
 If set to NO the nodeDisabled will be shown and user input ignored.
 */
@property (nonatomic, assign, getter=isEnabled) BOOL enabled;


/**
 Flag indicating whether the button is acutally pressed and thus highlighted.
 
 This flag automatically updates to the user input.
 If YES nodeHighlighted or nodeSelectedHighlighted will be shown.
 */
@property (nonatomic, assign, getter=isHighlighted) BOOL highlighted;


/**
 Flag indicating whether the toggle button is actually in the selected mode or not.
 
 Each touch lifting inside of the button will toggle this state automatically, 
 but only if updateSelectedStateAutomatically is set to YES.
 As long as selected is YES nodeSelectedNormal and nodeSelectedHighlighted will be used 
 instead of nodeNormal and nodeHighlighted.
 
 @see updateSelectedStateAutomatically
 */
@property (nonatomic, assign, getter=isSelected) BOOL selected;


/**
 Activate to make the button automatically toggle its selected state. Defaults to NO.
 
 If set to YES the selected property will be updated automatically according to touch up events.
 Has to be set to YES if the button should behave like a toggle button.
 */
@property (nonatomic, assign) BOOL updateSelectedStateAutomatically;


/**
 The node to show when the button's enabled property is set to NO.
 */
@property (nonatomic, strong) SKNode *nodeDisabled;


/**
 The node to show when the button's enabled property is set to YES, no touch occured and the selected state is NO.
 */
@property (nonatomic, strong) SKNode *nodeNormal;


/**
 The node to show when the button's enabled property is set to YES, a touch occured and the selected state is NO.
 */
@property (nonatomic, strong) SKNode *nodeHighlighted;


/**
 The node to show when the button's enabled property is set to YES, no touch occured and the selected state is YES.
 */
@property (nonatomic, strong) SKNode *nodeSelectedNormal;


/**
 The node to show when the button's enabled property is set to YES, a touch occured and the selected state is YES.
 */
@property (nonatomic, strong) SKNode *nodeSelectedHighlighted;


// ------------------------------------------------------------
#pragma mark - Initializer
// ------------------------------------------------------------

/**
 Creates and returns a new instance of INSKButtonNode.
 
 Calls initWithSize:.
 
 @param size The size of the button.
 @return A new button instance.
 @see initWithSize:
 */
+ (instancetype)buttonNodeWithSize:(CGSize)size;


/**
 Initializes a INSKButtonNode instance with the given size.
 
 The size describes the touch area of the button.
 An instance of INSKButtonNode is also a SKSpriteNode so a background image or color may be set.
 However the button representation should be done with the other nodes the button contains of.
 For a visible representation of the button the node properties should be set with SKSpriteNodes
 otherwise the button will be invisible.
 
 @param size The size of the button.
 @return The initialized node.
 */
- (instancetype)initWithSize:(CGSize)size;


/**
 Creates and returns a new instance of INSKButtonNode.
 
 Calls initWithImageNamed:.
 
 @param imageName The name of the image file to load for the normal representation.
 @return A new button instance.
 @see initWithImageNamed:
 */
+ (instancetype)buttonNodeWithImageNamed:(NSString *)imageName;


/**
 Initializes a INSKButtonNode instance with the given image name.
 
 A new button instance will be initialized by loading a SKSpriteNode with the image named 
 and assigned to the nodeNormal and nodeHighlighted properties.
 The button's size will be set with the size of the image.
 
 @param imageName The name of the image file to load for a visual representation of the button.
 @return The initialized node.
 */
- (instancetype)initWithImageNamed:(NSString *)imageName;


/**
 Creates and returns a new instance of INSKButtonNode.
 
 Calls initWithImageNamed:highlightImageNamed:.
 
 @param imageName The name of the image file to show in the normal state.
 @param highlightImageName The name of the image to show in the highlighted state.
 @return A new button instance.
 @see initWithImageNamed:highlightImageNamed:
 */
+ (instancetype)buttonNodeWithImageNamed:(NSString *)imageName highlightImageNamed:(NSString *)highlightImageName;


/**
 Initializes a INSKButtonNode instance with the given image names.
 
 A new button instance will be initialized by loading two SKSpriteNodes with the image named
 and assigned to the nodeNormal and nodeHighlighted properties.
 The button's size will be set with the size of the image used for the normal state.
 
 @param imageName The name of the image file to show in the normal state.
 @param highlightImageName The name of the image to show in the highlighted state.
 @return The initialized node.
 */
- (instancetype)initWithImageNamed:(NSString *)imageName highlightImageNamed:(NSString *)highlightImageName;


// ------------------------------------------------------------
#pragma mark - Target-selector setter
// ------------------------------------------------------------
/// @name Seting the target-selector pair.

/**
 Target-selector pair that is called when the touch goes up inside of the button's frame.
 
 The target's selector has to accept either no parameters at all or a single object of the type INSKButtonNode.
 
    aSelector
    aSelector:(INSKButtonNode *)button
 
 @param target The target to invoce the selector on. Will not be retained.
 @param selector The selector to call on the target.
 */
- (void)setTouchUpInsideTarget:(id)target selector:(SEL)selector;


/**
 Target-selector pair that is called when the touch goes down inside of the button's frame.
 
 The target's selector has to accept either no parameters at all or a single object of the type INSKButtonNode.
 
 aSelector
 aSelector:(INSKButtonNode *)button
 
 @param target The target to invoce the selector on. Will not be retained.
 @param selector The selector to call on the target.
 */
- (void)setTouchDownTarget:(id)target selector:(SEL)selector;


/**
 Target-selector pair that is called when the touch goes up inside or outside of the button's frame.

 The target's selector has to accept either no parameters at all or a single object of the type INSKButtonNode.
 
 aSelector
 aSelector:(INSKButtonNode *)button
 
 @param target The target to invoce the selector on. Will not be retained.
 @param selector The selector to call on the target.
 */
- (void)setTouchUpTarget:(id)target selector:(SEL)selector;


@end