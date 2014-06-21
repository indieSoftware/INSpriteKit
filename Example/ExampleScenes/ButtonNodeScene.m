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
    SKLabelNode *label;

    
    // Label for the first button
    label = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Regular"];
    label.text = @"A simple push button (with support for the right mouse button on OS X).";
    label.fontSize = 20;
    label.position = CGPointMake(0, 280);
    [self addChild:label];
    
    // Create "push button" with only one picture, but add a darkened copy for the highlight state
    button = [INSKButtonNode buttonNodeWithImageNamed:@"indie_banner_small"];
    button.position = CGPointMake(0, 200);
    button.name = @"push button";
    button.nodeHighlighted = button.nodeNormal.copy;
    ((SKSpriteNode *)button.nodeHighlighted).color = [SKColor blackColor];
    ((SKSpriteNode *)button.nodeHighlighted).colorBlendFactor = 0.2;
    button.inskButtonNodeDelegate = self;
    [self addChild:button];
    // add support for all buttons to this button on OS X
    button.supportedMouseButtons = INSKMouseButtonLeft | INSKMouseButtonRight | INSKMouseButtonOther;
    

    // Label for the second button
    label = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Regular"];
    label.text = @"A normal push button with a second sprite for the highlight state.";
    label.fontSize = 20;
    label.position = CGPointMake(0, 80);
    [self addChild:label];
    
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

    
    // Label for the third button
    label = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Regular"];
    label.text = @"A toggle button which toggles the enable state of the button above.";
    label.fontSize = 20;
    label.position = CGPointMake(0, -120);
    [self addChild:label];

    // Create "toggle button"
    button = [INSKButtonNode buttonNodeWithToggleImageNamed:@"indie_banner_small" highlightImageNamed:@"indie_banner_small" selectedImageNamed:@"indie_banner_small" selectedHighlightImageNamed:@"indie_banner_small"];
    button.position = CGPointMake(0, -200);
    button.name = @"toggle button";
    [button setTouchUpInsideTarget:self selector:@selector(buttonTouchedUpInside:)];
    button.inskButtonNodeDelegate = self;
    ((SKSpriteNode *)button.nodeHighlighted).color = [SKColor colorWithRed:1 green:0 blue:0 alpha:1];
    ((SKSpriteNode *)button.nodeHighlighted).colorBlendFactor = 0.2;
    [((SKSpriteNode *)button.nodeSelectedNormal) setScale:1.1];
    ((SKSpriteNode *)button.nodeSelectedNormal).color = [SKColor colorWithRed:0 green:1 blue:0 alpha:1];
    ((SKSpriteNode *)button.nodeSelectedNormal).colorBlendFactor = 0.2;
    [((SKSpriteNode *)button.nodeSelectedHighlighted) setScale:0.9];
    ((SKSpriteNode *)button.nodeSelectedHighlighted).color = [SKColor colorWithRed:0 green:0 blue:1 alpha:1];
    ((SKSpriteNode *)button.nodeSelectedHighlighted).colorBlendFactor = 0.2;
    [self addChild:button];
    
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
