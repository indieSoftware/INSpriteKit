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
#import "INSKTypes.h"


@class INSKButtonNode;


/**
 The delegate protocol to inform about state changes of a INSKButtonNode according to touches.
 All methods are optional.
 */
@protocol INSKButtonNodeDelegate <NSObject>

@optional

/**
 Gets called when the first touch goes down on a button node or the last touch gets lifted.
 
 @param button The button node on which the touch occured.
 @param touchUp Is YES if the touch gets lifted, NO if the first touch gets pressed down.
 @param touchInside YES if the touch occured inside of the button's touch area.
 */
- (void)buttonNode:(INSKButtonNode *)button touchUp:(BOOL)touchUp inside:(BOOL)touchInside;


/**
 Gets called when an event occures which calles all touches on the button, i.e. when a UIGestureRecognizer fires and cancels touches for others.
 With this method any changes according to a touch down event can be undone because a touch up event will never be send.
 
 @param button The corresponding button node.
 */
- (void)buttonNodeTouchCancelled:(INSKButtonNode *)button;


/**
 Gets called when a touch moved and the highlight state of the button updates because of the movement.
 
 The highlight state will be true as long as at least one touch resists inside of the button.
 When the last touch moves out of the button's touch area the highlight state gets NO and this method will be called.
 As soon as a finger moves inside of the button's touch area again the highlight state changes to YES again and the method gets called again.
 
 @param button The corresponding button node.
 @param isHighlighted YES if the button is actually highlighted after the movement, which means there was no touch inside of the button, but a finger moved inside again. Otherwise NO so the last finger moved actually outside of the touch area.
 */
- (void)buttonNode:(INSKButtonNode *)button touchMoveUpdatesHighlightState:(BOOL)isHighlighted;


@end




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
 
 Register for target-selector callbacks to get informed about user input or use the delegate protocol.
 
 Use the `buttonNodeWithSize:` class methods for initializing the button with a size and assign the visual nodes afterwards.

    CGSize myButtonSize = ...
    INSKButtonNode *button = [INSKButtonNode buttonNodeWithSize:myButtonSize];
    button.nodeNormal = ...
    button.nodeHighlighted = ...
    [button setTouchUpInsideTarget:self selector:@selector(myButtonPressed:)];
    ...
    [self addChild:button];

 You can also call the SKNode's class method `node` or use `alloc` + `init` and assigning a size afterwards.
 
    CGSize myButtonSize = ...
    INSKButtonNode *button = [INSKButtonNode node];
    button.size = myButtonSize
    ...
 
 Or use the class methods like `buttonNodeWithSize:` for initializing the button already with image nodes and a size of the image.
 
    INSKButtonNode *button = [INSKButtonNode buttonNodeWithImageNamed:@"imageName"];
    [button setTouchUpInsideTarget:self selector:@selector(myButtonPressed:)];
    [self addChild:button];
 
 */
@interface INSKButtonNode : SKSpriteNode

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
 
 An example of how to create an INSKButtonNode instance with an image and a highlight state:
 
    UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imageName ofType:nil]];
    UIImage *imageHighlighted = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imageHighlightedName ofType:nil]];
    INSKButtonNode *button = [[INSKButtonNode alloc] initWithSize:image.size];
    SKSpriteNode *buttonNormalRepresentation = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:image]];
    button.nodeNormal = buttonNormalRepresentation;
    SKSpriteNode *buttonHighlightRepresentation = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:imageHighlighted]];
    button.nodeHighlighted = buttonHighlightRepresentation;
    [button setTouchUpInsideTarget:self selector:@selector(buttonTouchedUpInside:)];

 @param size The size of the button.
 @return The initialized node.
 */
- (instancetype)initWithSize:(CGSize)size;


/**
 Creates and returns a new instance of INSKButtonNode.
 
 Calls initWithColor:size:.
 
 @param color The node's color.
 @param size The size of the button.
 @return A new button instance.
 @see initWithColor:size:
 */
+ (instancetype)buttonNodeWithColor:(SKColor *)color size:(CGSize)size;


/**
 Initializes a INSKButtonNode instance with the given color and size.
 
 The size describes the touch area of the button which will be visible by SKSpriteNodes in the given color.
 See initWithSize: for more instructions.
 
 @param size The size of the button.
 @return The initialized node.
 @see initWithSize:
 */
- (instancetype)initWithColor:(SKColor *)color size:(CGSize)size;


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
 
 A new button instance will be initialized by loading a SKSpriteNode with the image named and assigned to the node properties.
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
 
 A new button instance will be initialized by loading SKSpriteNodes with the image named and assigned to the node properties.
 The button's size will be set with the size of the image used for the normal state.
 
 @param imageName The name of the image file to show in the normal state.
 @param highlightImageName The name of the image to show in the highlighted state.
 @return The initialized node.
 */
- (instancetype)initWithImageNamed:(NSString *)imageName highlightImageNamed:(NSString *)highlightImageName;


/**
 Creates and returns a new instance of INSKButtonNode in toggle mode.
 
 Calls initWithToggleImageNamed:highlightImageNamed:selectedImageNamed:selectedHighlightImageNamed:.
 
 @param imageName The name of the image file to show in the normal state.
 @param highlightImageName The name of the image to show in the highlighted state.
 @param selectedImageName The name of the image file to show in the normal selected state.
 @param selectedHighlightImageName The name of the image to show in the highlighted and selected state.
 @return A new button instance.
 @see initWithToggleImageNamed:highlightImageNamed:selectedImageNamed:selectedHighlightImageNamed:
 */
+ (instancetype)buttonNodeWithToggleImageNamed:(NSString *)imageName highlightImageNamed:(NSString *)highlightImageName selectedImageNamed:(NSString *)selectedImageName selectedHighlightImageNamed:(NSString *)selectedHighlightImageName;


/**
 Initializes a INSKButtonNode instance in toggle mode, which means it has selected states and updateSelectedStateAutomatically is set to YES.
 
 A new button instance will be initialized by loading SKSpriteNodes with the image named and assigned to the node properties.
 The button's size will be set with the size of the image used for the normal state.
 
 @param imageName The name of the image file to show in the normal state.
 @param highlightImageName The name of the image to show in the highlighted state.
 @param selectedImageName The name of the image file to show in the normal selected state.
 @param selectedHighlightImageName The name of the image to show in the highlighted and selected state.
 @return The initialized node.
 */
- (instancetype)initWithToggleImageNamed:(NSString *)imageName highlightImageNamed:(NSString *)highlightImageName selectedImageNamed:(NSString *)selectedImageName selectedHighlightImageNamed:(NSString *)selectedHighlightImageName;


/**
 Creates and returns a new instance of INSKButtonNode with a label as visual representation.
 
 Calls initWithTitle: and is meant for debugging purposes.
 
 @param title The button's title.
 @param fontSize The font's size.
 @return A new button instance.
 @see initWithTitle:
 */
+ (instancetype)buttonNodeWithTitle:(NSString *)title fontSize:(CGFloat)fontSize;


/**
 Initializes a INSKButtonNode instance with a label as visual representation.
 
 A new button instance will be initialized with a label and a background sprite for the states normal, hightlighted and disabled.
 This method is only designed as an easier debugging button which has a colored shape and a simple text in it.
 There are no (easy) possiblities to change the font, the color, and sort of.
 In a productive environment the 'real' button will be much more complex with a sprite as background, a customized font, etc.
 If you need a button with a title in a productive setting create a new button with it's init or initWithSize: method, create label and sprite nodes and assign them to the button's node-X properties.
 However, if you don't have any sprites, yet, and just need a button for tests, use this initializer.
 
 @param title The button's title.
 @param fontSize The font's size. Use 0 for a default font size.
 @return The initialized node.
 */
- (instancetype)initWithTitle:(NSString *)title fontSize:(CGFloat)fontSize;


// ------------------------------------------------------------
#pragma mark - Properties
// ------------------------------------------------------------

/**
 The delegate to inform about any button touch state changes.
 
 The delegate will not be retained.
 The delegate protocol is an alternative to the target-selector callbacks.
 */
@property (nonatomic, weak) id<INSKButtonNodeDelegate> inskButtonNodeDelegate;


/**
 Flag indicating whether the button is enabled. Defaults to YES.
 
 Disable the button manually according to the logic.
 If set to NO the nodeDisabled will be shown and user input ignored due to userInteractionEnabled set to NO.
 The highlighted flag will also be set to NO automatically.
 If set to YES the visual representation will be restored and user input no longer ignored because userInteractionEnabled will be set to YES.
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