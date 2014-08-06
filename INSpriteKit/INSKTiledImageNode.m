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


@end
