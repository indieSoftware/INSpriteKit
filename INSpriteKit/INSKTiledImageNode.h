// INSKTiledImageNode.h
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
#import "INSKOSBridge.h"


/**
 A SKSpriteNode for large images which will be tiled to show as one.
 
 As described in Apple's docs SKTexture images can have a maximum dimension of 4k x 4k (2k x 2k for older devices).
 For backgrounds often bigger images are useful, so this is INSKTiledImageNode for.
 INSKTiledImageNode loads an image into memory and tiles it into smaller texture pieces each with a given tile size.
 Then each tile will be added as a SKSpriteNode subnode to the INSKTiledImageNode's instance at the correct position
 so the huge image consisting of the smaller pieces will look like one image.
 
    INSKTiledImageNode *imageNode = [INSKTiledImageNode tiledImageNodeNamed:pathOfHugeImageInBundle tileSize:CGSizeMake(2048, 2048)];
    imageNode.position = positionOfImageNode;
    [self addChild:imageNode];
 
 The tiled image node itself has a blue background, but shouldn't be visible because the tiled images should be drawn on top of this.
 However, if loading and tiling the huge image fails the blue becomes visible. So if encountered with a blue image have a look why the real image coudn't be displayed.
 */
@interface INSKTiledImageNode : SKSpriteNode

/// @name properties

/**
 The number of colums the image is tiled in.
 */
@property (nonatomic, assign, readonly) NSUInteger numberOfColumns;


/**
 The number of rows the image is tiled in.
 */
@property (nonatomic, assign, readonly) NSUInteger numberOfRows;


/**
 The size of each tile.
 
 The last tiles in a row and column may have a smaller size, because they may be cropped to fit into the original image.
 */
@property (nonatomic, assign, readonly) CGSize tileSize;


// ------------------------------------------------------------
#pragma mark - init methods
// ------------------------------------------------------------
/// @name init methods

/**
 Creates and returns a new instance of INSKTiledImageNode.
 
 Calls initWithImage:tileSize:.
 
 @param image The image.
 @param tileSize The size each tile should have at most.
 @return A new instance.
 @see initWithImage:tileSize:
 */
+ (instancetype)tiledImageNode:(UIImage *)image tileSize:(CGSize)tileSize;


/**
 Initializes a INSKTiledImageNode instance with an already loaded image.
 
 UIImage's -imageNamed: method uses the system cache so when loading big images without using the cache call something like:
 
    UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imageName ofType:nil]];
    INSKTiledImageNode *node = [[INSKTiledImageNode alloc] initWithImage:image tileSize:tileSize];
 
 When using images and the UIImage system cache then call something like:
 
    UIImage *image = [UIImage imageNamed:imageName];
    INSKTiledImageNode *node = [[INSKTiledImageNode alloc] initWithImage:image tileSize:tileSize];
 
 @param image The image to use.
 @param tileSize The size each tile should have at most. Width and height have to be each greater than zero.
 */
- (instancetype)initWithImage:(UIImage *)image tileSize:(CGSize)tileSize;


/**
 Creates and returns a new instance of INSKTiledImageNode.
 
 Calls initWithImageTiles:.
 
 @param imageTiles The image to show tiled into smaller images.
 @return A new instance.
 @see initWithImageTiles:
 */
+ (instancetype)tiledImageNodeWithImageTiles:(NSArray *)imageTiles;


/**
 Initializes a INSKTiledImageNode instance with a pack of image tiles.
 
 Instead of a huge image the smaller image tiles are passed in an array of arrays.
 The imageTiles array represents the columns and contains NSArray objects which represents the UIImage objects themselves as the secified column's row.
 As an example tiling an image into 2x2 pieces the image tile array should look something like the following:
 
    NSArray *imageTiles = [
        [
            image00,    // top left
            image01     // bottom left
        ], [
            image10,    // top right
            image11     // bottom right
        ]
    ];
 
 The image tile matrix must have a propper sizes, as created by the imageTiled:tileSize: method.
 Use the imageTiled:tileSize: method to create the image tile matrix to be sure.
 
 @param imageTiles The image tiles array.
 @see imageTiled:tileSize:
 */
- (instancetype)initWithImageTiles:(NSArray *)imageTiles;


/**
 Creates a matrix of tiled images from a given huge image and a tile size.
 
 When an image is too huge to load it as a single image on a mobile device it may be necessary to tile it and save the tiles to disc on a Mac.
 The tiles then can be loaded separately from the bundle on a mobile device and passed to the tiled image node.
 
 @param image The huge image to tile.
 @param tileSize The tile size.
 @return A matrix of images which tiles the original huge image.
 @see initWithImageTiles:
 */
+ (NSArray *)imageTiled:(UIImage *)image tileSize:(CGSize)tileSize;


@end
