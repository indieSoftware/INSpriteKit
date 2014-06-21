// INSKScrollNode.h
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
 The type of deceleration to use if any. Use a paging mode to support paging.
 */
typedef NS_ENUM(NSInteger, INSKScrollNodeDecelerationMode) {
    /**
     No paging or any deceleration functions to use, the default.
     The content will be left right there where the user lifted the finger, so scrolling abruptly stops.
     */
    INSKScrollNodeDecelerationModeNone = 0,
    /**
     The page snaps accordingly to where the most of the actual content is inside,
     so the user has to move the finger at least half a page size to get snapped to the next.
     */
    INSKScrollNodeDecelerationModePagingHalfPage,
    /**
     The page snaps accordingly to the direction of the last touch move, i.e.
     when dragged to the right and the finger lifted the page will snap to the next right page
     regardless of the distance the finger moved.
     */
    INSKScrollNodeDecelerationModePagingDirection,
    /**
     The content uses a smooth deceleration.
     The content will move a little bit in the direction the user moved it before it slowly stops.
     */
    INSKScrollNodeDecelerationModeDecelerate
};



@class INSKScrollNode;

/**
 The INSKScrollNode delegate protocol which informs about scrolling changes in the scroll node.

 All protocol methods are optional.
 */
@protocol INSKScrollNodeDelegate <NSObject>

@optional

/**
 Optional delegate method which will be called when the content scroll node has been moved by the user.
 
 This method is called for every touch move event.
 
 @param scrollNode The ISKScrollNode node which informs about the scrolling.
 @param fromOffset The scrollContentNode's starting position.
 @param toOffset The scrollContentNode's end position.
 @param velocity The scrollContentNode's velocity averaged.
 */
- (void)scrollNode:(INSKScrollNode *)scrollNode didScrollFromOffset:(CGPoint)fromOffset toOffset:(CGPoint)toOffset velocity:(CGPoint)velocity;


/**
 Optional delegate method which will be called when the content scroll node has finished moving and the user has lifted all fingers.
 
 This method is only called once when the last touch has been lifted.
 If no paging or automated scrolling is enabled the method will be called right after the user has lifted the finger,
 otherwise the method call is delayed until the scroll animation has finished.
 
 @param scrollNode The ISKScrollNode node which informs about the scrolling.
 @param offset The final scrollContentNode's position.
 */
- (void)scrollNode:(INSKScrollNode *)scrollNode didFinishScrollingAtPosition:(CGPoint)offset;


@end


// ------------------------------------------------------------
#pragma mark - Class interface
// ------------------------------------------------------------


/**
 A node with a scrolling ability.
 
 Add subnodes to the scrollContentNode, define the sizes and the user can pan the content around. To initialize a INSKScrollNode do the following steps
 
 - Create a new instance of the class with initWithSize:
 - Set scrollContentSize to the size of the scrollable content area to show inside of the visible scroll area.
 - Add subnodes to scrollContentNode at the appropriate positions.
 - Optionally set the clipContent flag if clipping is needed.
 
    INSKScrollNode *scrollNode = [INSKScrollNode scrollNodeWithSize:sizeOfScrollNode];
    scrollNode.position = positionOfScrollNode;
    scrollNode.scrollContentSize = sizeOfContent;
    scrollNode.scrollContentNode addChild:anySKNodeTreeToShowAsContent];
    [self addChild:scrollNode];

 The content node's origin is defined as the upper left corner, so the scroll node's frame is right bottom of the node's position. Adding it directly to the scene node will not show the scroll content, because it will be just under the screen, instead set the position to something like
 
    scrollNode.position = CGPointMake(0, scene.size.height);
    scrollNode.scrollContentSize = scene.size;
    scrollNode.scrollBackgroundNode.color = [SKColor yellowColor]; // for debugging purposes makes the scroll node visible
 
 Because the scroll content is under the origin all content objects added to scrollContentNode should therefore have a position with a negative value for the Y-axis.
 
    SKSpriteNode *picture = [SKSpriteNode spriteNodeWithImageNamed:@"picture"];
    picture.position = CGPoint(scene.size.width / 2, -scene.size.height / 2);
    [scrollNode.scrollContentNode addChild:picture];
 
 */
@interface INSKScrollNode : SKNode

// ------------------------------------------------------------
#pragma mark - properties
// ------------------------------------------------------------
/// @name properties

/**
 A not retained delegate object which will be informed about any scroll behaviour.
 */
@property (nonatomic, weak) id<INSKScrollNodeDelegate> scrollDelegate;


/**
 The size of the scroll node itself.

 It defines a frame with the node's position as the top left corner where the content will be shown and should be shown inside.
 */
@property (nonatomic, assign) CGSize scrollNodeSize;


/**
 The size of the content of the scroll node.

 It defines how big the content is and how far the user can scroll it.
 
 @warning *Needs to be set.*
 */
@property (nonatomic, assign) CGSize scrollContentSize;


/**
 The position of the scrollContentNode relative to it's parent which is this scroll node, thus the point has negative values for the X-axis and positive for the Y-axis.
 
 Setting a new value with by this property also applies boundary checks afterwards 
 so the scrollContentNode may be repositioned if it otherwise would be outside of the visible frame.
 Update the scrollContentNode's position property directly if you don't want the boundary checks to be applied.
 
    scrollNode.scrollContentNode.position = newPosition; // direct assigning, no boundary check
    scrollNode.scrollContentPosition = newPosition; // assigning new position with cropped to the bounday
    [scrollNode setScrollContentPosition:newPosition animationDuration:kAnimationDuration]; // same as the previous line, but with the movement animated
 */
@property (nonatomic, assign) CGPoint scrollContentPosition;


/**
 The background of the scroll node with the size equal to the scroll node itself.
 
 It is a SKSpriteNode which is needed to catch user input inside of the scroll node.
 The background sprite node has no texture and a clean color so it is invisible by default, but can be changed.

 @warning *Warning:* Never change other properties of this node than the texture or the color.
 */
@property (nonatomic, strong, readonly) SKSpriteNode *scrollBackgroundNode;


/**
 The content node to add the content as subnodes to.
 
 Other visible nodes should be added to this node for having them scrolled by calling addChild: on this property's node.
 The total size of the content is defined by scrollContentSize and should be changed there so the scroll node knows how far the user can scroll.
 Keep in mind that the content frame is definied with the origin at the top left corner so adding subnodes to this node should have negative values for the Y-axis to be visible.
 
 @see scrollContentSize
 @warning *Warning:* Never change any properties of this node.
 */
@property (nonatomic, strong, readonly) SKNode *scrollContentNode;


/**
 Clips the visible part of the scroll node. Defaults to NO.
 
 If set to YES the content will be clipped according the contentCropNode.
 If no contentCropNode is set a default one with the size of the scroll node will be created to clip the content at the scroll node's borders.
 If clipContent is false the content will be visible beneath the scroll node's bounds.
 The content dragging touches will be ignored when outside of the scroll node's bounds if clipContent is set to YES, otherwise the user can drag the visible content even beneath the borders.
 */
@property (nonatomic, assign) BOOL clipContent;


/**
 The crop node to use for clipping the content if clipContent is true.
 
 When clipContent is set to YES this node will be used for cropping the content, otherwise it is not used.
 This node defaults to nil.
 If clipContent is set to NO and the crop node is still nil a new crop node will be created with the size of the scroll node and positioned according so the content will be cropped at the scroll node's borders.
 A custom crop node can be assigned, but take into count that the scroll node's position is the top left corner, so set a position for the contentCropNode accordingly.
 
 @see clipContent
 */
@property (nonatomic, strong) SKCropNode *contentCropNode;


/**
 The paging behavior to use. Defaults to INSKScrollNodeDecelerationModeNone so deceleration and paging is disabled.
 @see INSKScrollNodeDecelerationMode
 */
@property (nonatomic, assign) INSKScrollNodeDecelerationMode decelerationMode;


/**
 Defines the size of each page. Defaults to CGSizeZero.
 
 To enable paging for the scroll node set width and/or height of the page size with a value greater than zero and decelerationMode to INSKScrollNodeDecelerationModePagingHalfPage or INSKScrollNodeDecelerationModePagingDirection.
 After the scroll content has been dragged the content will snap according to the page's size and deceleration mode.
 A usual use case for paging should be having a page size of equal size to the scroll node's size itself:
 
    scrollNode.pageSize = scrollNode.scrollNodeSize;
 
 @see decelerationMode
 */
@property (nonatomic, assign) CGSize pageSize;


/**
 The deceleration in pixels per squared second. Defaults to 10'000.
 
 This value is only used when the property decelerationMode is set to INSKScrollNodeDecelerationModeDecelerate.
 @see decelerationMode
 */
@property (nonatomic, assign) CGFloat deceleration;


/**
 Enables the user input recognition for the scrolling behavior. Defaults to YES.
 
 Set to NO when the user is not allowed to scroll the content.
 Only touches are ignored, all methods still work so scrolling via method calls is still possible.
 */
@property (nonatomic, assign, getter=isScrollingEnabled) BOOL scrollingEnabled;


// ------------------------------------------------------------
#pragma mark - init methods
// ------------------------------------------------------------
/// @name init methods

/**
 Creates and initializes an instance of INSKScrollNode with the size of the visible scroll node's area.
 
 Calls initWithSize:.
 
 @param scrollNodeSize The size of the visible scroll node which shows the content inside.
 @return A new initialized instance.
 @see initWithSize:
 */
+ (instancetype)scrollNodeWithSize:(CGSize)scrollNodeSize;


/**
 Initializes the node with the size of the visible scroll node's area.
 
 The property scrollNodeSize with be set with the giving size so it doesn't need to be set.
 
 @param scrollNodeSize The size of the visible scroll node which shows the content inside.
 @return An initialized node.
 */
- (instancetype)initWithSize:(CGSize)scrollNodeSize;


// ------------------------------------------------------------
#pragma mark - public interface
// ------------------------------------------------------------
/// @name Public interface

/**
 Sets a new position for the content node with an animation.
 
 The new position will be clipped by the scroll node's bounds, like assigning the position to scrollContentPosition.
 By settings an animation duration of greater than 0 the content will scroll to the new position with a deceleration animation.
 
 @param scrollContentPosition The new position for the scroll content node.
 @param duration The animation duration in seconds.
 @see scrollContentPosition
 */
- (void)setScrollContentPosition:(CGPoint)scrollContentPosition animationDuration:(CGFloat)duration;

/**
 The total number of snappable pages on the X-axis.
 
 Calculates 
 
    ceil(scrollContentSize.width - scrollNodeSize.width) / self.pageSize.width
 
 @return The number of pages. Always 0 if page width is 0.
 */
- (NSUInteger)numberOfPagesX;


/**
 The total number of snappable pages on the Y-axis.
 
 Calculates
 
    ceil((scrollContentSize.height - scrollNodeSize.height) / self.pageSize.height)
 
 @return The number of pages. Always 0 if page height is 0.
 */
- (NSUInteger)numberOfPagesY;


/**
 The current page's index on the X-axis.
 
 Calculates
 
    round(-self.scrollContentNode.position.x / self.pageSize.width)
 
 @return The page index beginning with 0. Always 0 if page width is 0.
 */
- (NSUInteger)currentPageX;


/**
 The current page's index on the Y-axis.
 
 Calculates
 
    round(-self.scrollContentNode.position.y / self.pageSize.height)
 
 @return The page index beginning with 0. Always 0 if page height is 0.
 */
- (NSUInteger)currentPageY;


// ------------------------------------------------------------
#pragma mark - subclassing methods
// ------------------------------------------------------------
/// @name Methods for overriding by subclasses.

/**
 Will be called after the user scrolled the content node.
 
 Subclasses may override this method to get informed, but should never be called manually.
 This method informs the delegate about the movement so subclasses should call super.
 
 @param fromOffset The scrollContentNode's starting position.
 @param toOffset The scrollContentNode's end position.
 @param velocity The scrollContentNode's velocity averaged.
 */
- (void)didScrollFromOffset:(CGPoint)fromOffset toOffset:(CGPoint)toOffset velocity:(CGPoint)velocity;


/**
 Will be called after the unser lifted all fingers and any paging scroll behavior has finished.
 
 Subclasses may override this method to get informed, but should never be called manually.
 This method informs the delegate about the end of movement so subclasses should call super.
 
 @param offset The final scrollContentNode's position.
 */
- (void)didFinishScrollingAtPosition:(CGPoint)offset;


@end
