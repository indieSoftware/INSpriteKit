// SKSpriteNode+INExtension.h
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

@interface SKSpriteNode (INExtension)


/**
 Returns the sprite node's unscaled size by dividing the node's size with the scale factor.
 
 @return The unscaled size of the node.
 */
- (CGSize)sizeUnscaled;


/**
 Sets the sprite node's position converted first for an anchor point.
 
 The sprite node's anchor point itself won't be changed it is only used for calculating.
 The converted position will be the position which would be when the sprite node's anchor point would be the one given.
 
 For exampe when having a button sprite node in a menu you normally allign the layout with the upper left coordinates of the sprite nodes rather than using the sprite node's center, but changing the anchor point is not always desired.
 With this method you can have the anchor point still at the center, but setting the sprite node's position as if the anchor point would be the given one.
 
 @param position The new position to convert and assign.
 @param anchor An anchor point for which to interpret the sprite node's current position.
 */
- (void)setPosition:(CGPoint)position forAnchor:(CGPoint)anchor;


/**
 Returns YES if the given position point in the coordinate system of this sprite node is inside of the sprite node's size.
 
 Normally a sprite node shows an image. With this method you can determine easily if a touch point is inside of this image or not.
 The anchor point and scale is taken into count.
 
 @param point The position point to check, has to be in the coordinate system of this sprite node.
 @return YES if the point is inside of the node's image or size if no image is assigned. Otherwise returns NO.
 */
- (BOOL)isPointInside:(CGPoint)point;


@end
