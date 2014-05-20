// ButtonNode.m
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


#import "ButtonNode.h"


@interface ButtonNode ()

@end


@implementation ButtonNode

- (id)initWithSize:(CGSize)size {
    self = [super initWithSize:size];
    if (self == nil) return self;
    
    self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
    self.anchorPoint = CGPointMake(0.5, 0.5);
    
    INSKButtonNode *button;
    
    // Create push button with only one picture
    button = [INSKButtonNode buttonNodeWithImageNamed:@"indie_banner_small"];
    button.position = CGPointMake(0, 200);
    button.name = @"push button";
    [button setTouchUpInsideTarget:self selector:@selector(buttonTouchedUpInside:)];
    [self addChild:button];
    
    // Create second push button with more control
    UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"indie_banner_small" ofType:@"png"]];
    UIImage *imageHighlighted = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"indie_banner" ofType:@"jpg"]];
    button = [[INSKButtonNode alloc] initWithSize:image.size];
    SKSpriteNode *buttonNormalRepresentation = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:image]];
    button.nodeNormal = buttonNormalRepresentation;
    SKSpriteNode *buttonHighlightRepresentation = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:imageHighlighted]];
    button.nodeHighlighted = buttonHighlightRepresentation;
    button.position = CGPointMake(0, 0);
    button.name = @"push button 2";
    [button setTouchUpInsideTarget:self selector:@selector(buttonTouchedUpInside:)];
    [self addChild:button];

    // Create toggle button
    button = [INSKButtonNode buttonNodeWithImageNamed:@"indie_banner_small"];
    button.position = CGPointMake(0, -200);
    button.name = @"toggle button";
    button.updateSelectedStateAutomatically = YES;
    [button setTouchUpInsideTarget:self selector:@selector(buttonTouchedUpInside:)];
    [self addChild:button];
    
    // clone the button's normal state and modify it for the highlight and selected states
    SKSpriteNode *spriteNode = [button.nodeNormal copy];
    [spriteNode setScale:0.9];
    spriteNode.color = [SKColor colorWithRed:1 green:0 blue:0 alpha:1];
    spriteNode.colorBlendFactor = 0.2;
    button.nodeHighlighted = spriteNode;

    spriteNode = [button.nodeNormal copy];
    [spriteNode setScale:1.1];
    spriteNode.color = [SKColor colorWithRed:1 green:0 blue:0 alpha:1];
    spriteNode.colorBlendFactor = 0.2;
    button.nodeSelectedNormal = spriteNode;

    spriteNode = [button.nodeNormal copy];
    [spriteNode setScale:0.9];
    spriteNode.color = [SKColor colorWithRed:0 green:0 blue:0 alpha:1];
    spriteNode.colorBlendFactor = 0.2;
    button.nodeSelectedHighlighted = spriteNode;
    
    
    return self;
}

- (void)buttonTouchedUpInside:(INSKButtonNode *)button {
    NSLog(@"'%@' touched up inside", button.name);
}


@end
