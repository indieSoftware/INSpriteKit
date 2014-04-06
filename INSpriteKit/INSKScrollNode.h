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


@class INSKScrollNode;

@protocol INSKScrollNodeDelegate <NSObject>

@optional

/**
 Optional delegate method which will be called when teh content scroll node has been moved by the user.
 @param scrollNode The ISKScrollNode node which informs about the scrolling.
 @param fromOffset The scrollContentNode's starting position.
 @param toOffset The scrollContentNode's end position.
 */
- (void)scrollNode:(INSKScrollNode *)scrollNode didScrollFromOffset:(CGPoint)fromOffset toOffset:(CGPoint)toOffset;

@end


/**
 A node with a scrolling ability.
 Add subnodes to the scrollContentNode, define the sizes and the user can pan the content around.
 */
@interface INSKScrollNode : SKNode

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
 */
@property (nonatomic, assign) CGSize scrollContentSize;

/**
 The background of the scroll node with the size equal to the scroll node itself.
 It is a SKSpriteNode which is needed to catch user input inside of the scroll node.
 The background sprite node has no texture and a clean color so it is invisible by default, but can be changed.
 Never change other properties of this node than the texture or the color.
 */
@property (nonatomic, strong, readonly) SKSpriteNode *scrollBackgroundNode;

/**
 The content node to add the content as subnodes to.
 Other visible nodes should be added to this node for having them scrolled.
 The size of the total content is defined by scrollContentSize and should be changed there so the scroll node knows how far the user can scroll.
 */
@property (nonatomic, strong, readonly) SKNode *scrollContentNode;

/**
 Clips the visible part of the scroll node. Defaults to NO.
 If set to YES the content will be clipped to the bounds of the scroll node, otherwise it may be visible beneath it's bounds.
 */
@property (nonatomic, assign) BOOL clipContent;


/**
 Will be called after the user scrolled the content node and may be overridden by subclasses.
 This method informs the delegate about the movement.
 @param fromOffset The scrollContentNode's starting position.
 @param toOffset The scrollContentNode's end position.
 */
- (void)didScrollFromOffset:(CGPoint)fromOffset toOffset:(CGPoint)toOffset;

@end
