// INSKTiledImageNode.m
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


#import "INSKTiledImageNode.h"


@interface INSKTiledImageNode ()

@property (nonatomic, assign, readwrite) NSUInteger numberOfColumns;
@property (nonatomic, assign, readwrite) NSUInteger numberOfRows;
@property (nonatomic, assign, readwrite) CGSize tileSize;

@end


@implementation INSKTiledImageNode

+ (instancetype)tiledImageNode:(UIImage *)image tileSize:(CGSize)tileSize {
    return [[self alloc] initWithImage:image tileSize:tileSize];
}

- (instancetype)initWithImage:(UIImage *)image tileSize:(CGSize)tileSize {
    self = [super initWithColor:[SKColor blueColor] size:CGSizeZero];
    if (self == nil) return self;

    self.size = image.size;
    self.tileSize = tileSize;

    if (image != nil && tileSize.width > 0.f && tileSize.height > 0.f) {
        // calculate columns and rows
        self.numberOfColumns = ceilf(self.size.width / tileSize.width);
        self.numberOfRows = ceilf(self.size.height / tileSize.height);
        if (self.numberOfColumns > 0 && self.numberOfRows > 0) {
            // Calculate the size of the last tile, the one at the bottom right corner, because it may have less width and height than the normal expected tileSize.
            CGSize croppedTileSize = CGSizeMake(self.size.width - ((self.numberOfColumns - 1) * tileSize.width), self.size.height - ((self.numberOfRows - 1) * tileSize.height));
            
            // Create tiles from top left corner
            CGImageRef imageRef = image.CGImage;
            NSAssert(imageRef != nil, @"expecting an imageRef");
            CGImageRetain(imageRef);
            for (NSUInteger column = 0; column < self.numberOfColumns; ++column) {
                for (NSUInteger row = 0; row < self.numberOfRows; ++row) {
                    // Size of tile
                    CGRect rect = CGRectMake(column * tileSize.width, row * tileSize.height, tileSize.width, tileSize.height);
                    if (column == self.numberOfColumns - 1) {
                        // Last column, use width of cropped tile
                        rect.size.width = croppedTileSize.width;
                    }
                    if (row == self.numberOfRows - 1) {
                        // Last row, use height of cropped tile
                        rect.size.height = croppedTileSize.height;
                    }
                    // Get tile texture
                    CGImageRef tileImage = CGImageCreateWithImageInRect(imageRef, rect);
                    NSAssert(tileImage != nil, @"expecting an imageRef");
                    SKTexture *texture = [SKTexture textureWithCGImage:tileImage];
                    NSAssert(texture != nil, @"expecting a created texture");
                    CGImageRelease(tileImage);
                    
                    // Add tile node
                    SKSpriteNode *tileNode = [SKSpriteNode spriteNodeWithTexture:texture];
                    tileNode.anchorPoint = CGPointZero;
                    CGPoint position = CGPointMake(column * tileSize.width - self.size.width * self.anchorPoint.x, (self.numberOfRows - (row + 1)) * tileSize.height - self.size.height * self.anchorPoint.y);
                    if (row < self.numberOfRows - 1) {
                        position.y = position.y - (tileSize.height - croppedTileSize.height);
                    }
                    tileNode.position = position;
                    [self addChild:tileNode];
                }
            }
            CGImageRelease(imageRef);
        }
    }
    
    return self;
}

+ (instancetype)tiledImageNodeWithImageTiles:(NSArray *)imageTiles {
    return [[self alloc] initWithImageTiles:imageTiles];
}

- (instancetype)initWithImageTiles:(NSArray *)imageTiles {
    self = [super initWithColor:[SKColor blueColor] size:CGSizeZero];
    if (self == nil) return self;

    // Get tile size from first image in the tiles matrix
    NSAssert(imageTiles.count > 0 && ((NSArray *)imageTiles[0]).count > 0, @"expecting a matrix of images");
    self.numberOfColumns = imageTiles.count;
    self.numberOfRows = ((NSArray *)imageTiles[0]).count;
    UIImage *image = imageTiles[0][0];
    NSAssert(image != nil, @"expecting an image object");
    self.tileSize = image.size;
    
    // Calculate the total image size
    image = imageTiles[self.numberOfColumns-1][self.numberOfRows-1];
    NSAssert(image != nil, @"expecting an image object");
    CGSize croppedTileSize = image.size;
    self.size = CGSizeMake(self.tileSize.width * (self.numberOfColumns-1) + croppedTileSize.width, self.tileSize.height * (self.numberOfRows-1) + croppedTileSize.height);
    
    // Create textures from the tiled image matrix
    for (NSUInteger column = 0; column < self.numberOfColumns; ++column) {
        NSArray *tileRows = imageTiles[column];
        for (NSUInteger row = 0; row < self.numberOfRows; ++row) {
            UIImage *image = tileRows[row];
            SKTexture *texture = [SKTexture textureWithImage:image];
            NSAssert(texture != nil, @"expecting a created texture");
            
            // Add tile node
            SKSpriteNode *tileNode = [SKSpriteNode spriteNodeWithTexture:texture];
            tileNode.anchorPoint = CGPointZero;
            CGPoint position = CGPointMake(column * self.tileSize.width - self.size.width * self.anchorPoint.x, (self.numberOfRows - (row + 1)) * self.tileSize.height - self.size.height * self.anchorPoint.y);
            if (row < self.numberOfRows - 1) {
                position.y = position.y - (self.tileSize.height - croppedTileSize.height);
            }
            tileNode.position = position;
            [self addChild:tileNode];
        }
    }
    
    return self;
}

+ (NSArray *)imageTiled:(UIImage *)image tileSize:(CGSize)tileSize {
    if (image == nil || tileSize.width <= 0.f || tileSize.height <= 0.f) {
        return nil;
    }
    
    // calculate columns and rows
    CGSize imageSize = image.size;
    NSInteger numberOfColumns = ceilf(imageSize.width / tileSize.width);
    NSInteger numberOfRows = ceilf(imageSize.height / tileSize.height);
    if (numberOfColumns <= 0 || numberOfRows <= 0) {
        return nil;
    }
    
    // Calculate the size of the last tile, the one at the bottom right corner, because it may have less width and height than the normal expected tileSize.
    CGSize croppedTileSize = CGSizeMake(imageSize.width - ((numberOfColumns - 1) * tileSize.width), imageSize.height - ((numberOfRows - 1) * tileSize.height));
    
    // Prepare image ref
    CGImageRef imageRef = image.CGImage;
    NSAssert(imageRef != nil, @"expecting an imageRef");
    CGImageRetain(imageRef);

    // Create tiles from top left corner
    NSMutableArray *tileMatrix = [NSMutableArray arrayWithCapacity:numberOfColumns];
    for (NSUInteger column = 0; column < numberOfColumns; ++column) {
        NSMutableArray *tiles = [NSMutableArray arrayWithCapacity:numberOfRows];
        [tileMatrix addObject:tiles];
        
        for (NSUInteger row = 0; row < numberOfRows; ++row) {
            // Size of tile
            CGRect rect = CGRectMake(column * tileSize.width, row * tileSize.height, tileSize.width, tileSize.height);
            if (column == numberOfColumns - 1) {
                // Last column, use width of cropped tile
                rect.size.width = croppedTileSize.width;
            }
            if (row == numberOfRows - 1) {
                // Last row, use height of cropped tile
                rect.size.height = croppedTileSize.height;
            }
            
            // Create tile image
            CGImageRef tileImageRef = CGImageCreateWithImageInRect(imageRef, rect);
            NSAssert(tileImageRef != nil, @"expecting an imageRef");
            UIImage *tileImage = [UIImage imageWithCGImage:tileImageRef];
            NSAssert(tileImage != nil, @"expecting a created image");
            CGImageRelease(tileImageRef);
            
            [tiles addObject:tileImage];
        }
        
        NSAssert(tiles.count == numberOfRows, @"each column should have the same number of rows");
    }
    CGImageRelease(imageRef);
    NSAssert(tileMatrix.count == numberOfColumns, @"the column should match the calculation");

    return tileMatrix;
}


@end
