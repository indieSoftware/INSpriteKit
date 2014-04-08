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

+ (INSKTiledImageNode *)tiledImageNamed:(NSString *)imageName tileSize:(CGSize)tileSize {
    return [[INSKTiledImageNode alloc] initWithImageNamed:imageName tileSize:tileSize];
}

- (instancetype)initWithImageNamed:(NSString *)imageName tileSize:(CGSize)tileSize {
    self = [super initWithColor:[UIColor blueColor] size:CGSizeZero];
    if (self == nil) return self;

    // load image
    NSAssert(imageName != nil, @"image file must be not nil");
    UIImage *image = [UIImage imageNamed:imageName];
    if (image == nil) {
        return self;
    }
    self.size = image.size;
    self.tileSize = tileSize;
    
    // calculate columns and rows
    self.numberOfColumns = ceilf(self.size.width / tileSize.width);
    self.numberOfRows = ceilf(self.size.height / tileSize.height);
    CGSize croppedTileSize = CGSizeMake(self.size.width - ((self.numberOfColumns - 1) * tileSize.width), self.size.height - ((self.numberOfRows - 1) * tileSize.height));
    
    // create tiles from top left corner
    CGImageRef imageRef = image.CGImage;
    for (NSUInteger column = 0; column < self.numberOfColumns; column++) {
        for (NSUInteger row = 0; row < self.numberOfRows; row++) {
            // get tile texture
            CGRect rect = CGRectMake(column * tileSize.width, row * tileSize.height, tileSize.width, tileSize.height);
            if (column == self.numberOfColumns - 1) {
                rect.size.width = croppedTileSize.width;
            }
            if (row == self.numberOfRows - 1) {
                rect.size.height = croppedTileSize.height;
            }
            CGImageRef tileImage = CGImageCreateWithImageInRect(imageRef, rect);
            SKTexture *texture = [SKTexture textureWithCGImage:tileImage];
            CGImageRelease(tileImage);
            
            // add tile node
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

    return self;
}


@end
