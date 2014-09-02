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


#import "TiledImageNodeScene.h"


static CGFloat const TileSizeWidth = 500;
static CGFloat const TileSizeHeight = 500;


@interface TiledImageNodeScene ()

@property (nonatomic, strong) INSKScrollNode *scrollNode;

@end


@implementation TiledImageNodeScene

- (id)initWithSize:(CGSize)size {
    self = [super initWithSize:size];
    if (self == nil) return self;
    
    self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
    self.anchorPoint = CGPointMake(0.5, 0.5);

    INSKButtonNode *button;

    
    // Create scroll node for the tiled image
    self.scrollNode = [INSKScrollNode scrollNodeWithSize:size];
    self.scrollNode.position = CGPointMake(-self.scrollNode.scrollNodeSize.width / 2, self.scrollNode.scrollNodeSize.height / 2);
    [self addChild:self.scrollNode];
    self.scrollNode.decelerationMode = INSKScrollNodeDecelerationModeDecelerate;
    

    // Create buttons
    button = [INSKButtonNode buttonNodeWithTitle:@"Load a single huge image file" fontSize:0];
    button.position = CGPointMake(0, 250);
    button.name = @"button1";
    [button setTouchUpInsideTarget:self selector:@selector(loadSingleImage)];
    [self addChild:button];
    
    button = [INSKButtonNode buttonNodeWithTitle:@"Clear scroll content" fontSize:0];
    button.position = CGPointMake(0, 150);
    button.name = @"button2";
    [button setTouchUpInsideTarget:self selector:@selector(clearScrollContent)];
    [self addChild:button];
    
    button = [INSKButtonNode buttonNodeWithTitle:@"Load huge image as smaller tiles" fontSize:0];
    button.position = CGPointMake(0, 50);
    button.name = @"button3";
    [button setTouchUpInsideTarget:self selector:@selector(loadTiledImages)];
    [self addChild:button];
    
    return self;
}

- (void)loadSingleImage {
    // Clear scroll node's content
    [self clearScrollContent];
    // Load the huge image
    UIImage *image = [UIImage imageNamed:@"hugeImage.jpg"];
    // Create a tiled image node
    INSKTiledImageNode *tiledImageNode = [INSKTiledImageNode tiledImageNode:image tileSize:CGSizeMake(TileSizeWidth, TileSizeHeight)];
    tiledImageNode.position = CGPointMake(tiledImageNode.size.width/2, -tiledImageNode.size.height/2);
    // Add the tiled image node as the scroll node's content
    [self.scrollNode.scrollContentNode addChild:tiledImageNode];
    self.scrollNode.scrollContentSize = CGSizeMake(tiledImageNode.size.width, tiledImageNode.size.height);
    self.scrollNode.scrollContentPosition = CGPointMake(-tiledImageNode.size.width/2 + self.scrollNode.scrollNodeSize.width/2, tiledImageNode.size.height/2 - self.scrollNode.scrollNodeSize.height/2);
}

- (void)clearScrollContent {
    for (SKNode *node in self.scrollNode.scrollContentNode.children) {
        [node removeFromParent];
    }
}

- (void)loadTiledImages {
    // Clear scroll node's content
    [self clearScrollContent];
    // Load the huge image
    UIImage *image = [UIImage imageNamed:@"hugeImage.jpg"];
    // Create image tiles which may be saved to and loaded from disc,
    // here we pass them directly to the image node.
    NSArray *imageTiles = [INSKTiledImageNode imageTiled:image tileSize:CGSizeMake(TileSizeWidth, TileSizeHeight)];
    // Create a tiled image node
    INSKTiledImageNode *tiledImageNode = [INSKTiledImageNode tiledImageNodeWithImageTiles:imageTiles];
    tiledImageNode.position = CGPointMake(tiledImageNode.size.width/2, -tiledImageNode.size.height/2);
    // Add the tiled image node as the scroll node's content
    [self.scrollNode.scrollContentNode addChild:tiledImageNode];
    self.scrollNode.scrollContentSize = CGSizeMake(tiledImageNode.size.width, tiledImageNode.size.height);
    self.scrollNode.scrollContentPosition = CGPointMake(-tiledImageNode.size.width/2 + self.scrollNode.scrollNodeSize.width/2, tiledImageNode.size.height/2 - self.scrollNode.scrollNodeSize.height/2);
}


@end
