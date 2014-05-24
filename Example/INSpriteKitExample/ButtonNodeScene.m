// ButtonNodeScene.m
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


#import "ButtonNodeScene.h"


@interface ButtonNodeScene () <INSKButtonNodeDelegate>

@end


@implementation ButtonNodeScene

- (id)initWithSize:(CGSize)size {
    self = [super initWithSize:size];
    if (self == nil) return self;
    
    self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
    self.anchorPoint = CGPointMake(0.5, 0.5);
    
    INSKButtonNode *button;
    
    
    // Create "push button" with only one picture
    button = [INSKButtonNode buttonNodeWithImageNamed:@"indie_banner_small"];
    button.position = CGPointMake(0, 200);
    button.name = @"push button";
    button.inskButtonNodeDelegate = self;
    [self addChild:button];
    
    
    // Create "push button 2" with more control
    UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"indie_banner_small" ofType:@"png"]];
    UIImage *imageHighlighted = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"indie_banner" ofType:@"jpg"]];
    button = [[INSKButtonNode alloc] initWithSize:image.size];
    SKSpriteNode *buttonNormalRepresentation = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:image]];
    button.nodeNormal = buttonNormalRepresentation;
    SKSpriteNode *buttonHighlightRepresentation = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:imageHighlighted]];
    button.nodeHighlighted = buttonHighlightRepresentation;
    SKSpriteNode *disabledRepresentation = [buttonNormalRepresentation copy];
    disabledRepresentation.color = [SKColor grayColor];
    disabledRepresentation.colorBlendFactor = 0.5;
    button.nodeDisabled = disabledRepresentation;
    button.position = CGPointMake(0, 0);
    button.name = @"push button 2";
    button.inskButtonNodeDelegate = self;
    [self addChild:button];

    // A label as child of the button
    SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Regular"];
    label.text = @"A label added to a button";
    [button addChild:label];
    
    
    // Create "toggle button"
    button = [INSKButtonNode buttonNodeWithImageNamed:@"indie_banner_small"];
    button.position = CGPointMake(0, -200);
    button.name = @"toggle button";
    button.updateSelectedStateAutomatically = YES;
    [button setTouchUpInsideTarget:self selector:@selector(buttonTouchedUpInside:)];
    button.inskButtonNodeDelegate = self;
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

- (void)buttonNode:(INSKButtonNode *)button touchUp:(BOOL)touchUp inside:(BOOL)touchInside {
    if (touchUp) {
        if (touchInside) {
            NSLog(@"'%@' touched up inside", button.name);
        } else {
            NSLog(@"'%@' touched up outside", button.name);
        }
    } else {
        NSLog(@"'%@' touched down", button.name);
    }
}

- (void)buttonNode:(INSKButtonNode *)button touchMoveUpdatesHighlightState:(BOOL)isHighlighted {
    if (isHighlighted) {
        NSLog(@"'%@' highlights again", button.name);
    } else {
        NSLog(@"'%@' not highlighted anymore", button.name);
    }
}

- (void)buttonNodeTouchCancelled:(INSKButtonNode *)button {
    NSLog(@"'%@' has all touches get cancelled", button.name);
}

- (void)buttonTouchedUpInside:(INSKButtonNode *)button {
    // the toggle button enables/disables the other buttons
    if ([button.name isEqualToString:@"toggle button"]) {
        INSKButtonNode *buttonToDisable = (INSKButtonNode *)[button.parent childNodeWithName:@"push button"];
        buttonToDisable.enabled = !buttonToDisable.enabled;
        buttonToDisable = (INSKButtonNode *)[button.parent childNodeWithName:@"push button 2"];
        buttonToDisable.enabled = !buttonToDisable.enabled;
    }
}


@end
