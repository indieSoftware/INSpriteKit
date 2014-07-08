// TreeOrderManipulationScene.m
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


#import "TreeOrderManipulationScene.h"


static CGFloat const ButtonAlpha = 0.7;


@interface TreeOrderManipulationScene ()

@property (nonatomic, strong) SKSpriteNode *whiteSprite;

@end


@implementation TreeOrderManipulationScene

- (id)initWithSize:(CGSize)size {
    self = [super initWithSize:size];
    if (self == nil) return self;
    
    self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
    self.anchorPoint = CGPointMake(0.5, 0.5);
    
    INSKButtonNode *button;
    SKLabelNode *label;
    
    // Label for the first button
    label = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Regular"];
    label.text = @"The left button moves the white label to the back.";
    label.fontSize = 20;
    label.position = CGPointMake(0, 360);
    [self addChild:label];
    
    label = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Regular"];
    label.text = @"The middle button moves the white label to the middle of the stack.";
    label.fontSize = 20;
    label.position = CGPointMake(0, 330);
    [self addChild:label];
    
    label = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Regular"];
    label.text = @"The right button moves the white label to the front.";
    label.fontSize = 20;
    label.position = CGPointMake(0, 300);
    [self addChild:label];
    
    // Create buttons for manipulating the tree order
    button = [INSKButtonNode buttonNodeWithSize:CGSizeMake(130, 100)];
    button.color = [SKColor greenColor];
    button.colorBlendFactor = 1;
    button.position = CGPointMake(-150, 150);
    button.name = @"back";
    label = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Regular"];
    label.text = @"Back";
    label.fontSize = 30;
    label.fontColor = [SKColor blackColor];
    button.nodeNormal = label.copy;
    label.fontColor = [SKColor darkGrayColor];
    button.nodeHighlighted = label.copy;
    [button setTouchUpInsideTarget:self selector:@selector(sendSpriteToBack)];
    [self addChild:button];

    button = [INSKButtonNode buttonNodeWithSize:CGSizeMake(130, 100)];
    button.color = [SKColor greenColor];
    button.colorBlendFactor = 1;
    button.position = CGPointMake(0, 150);
    button.name = @"between";
    label = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Regular"];
    label.text = @"Between";
    label.fontSize = 30;
    label.fontColor = [SKColor blackColor];
    button.nodeNormal = label.copy;
    label.fontColor = [SKColor darkGrayColor];
    button.nodeHighlighted = label.copy;
    [button setTouchUpInsideTarget:self selector:@selector(moveSpriteInBetween)];
    [self addChild:button];
    
    button = [INSKButtonNode buttonNodeWithSize:CGSizeMake(130, 100)];
    button.color = [SKColor greenColor];
    button.colorBlendFactor = 1;
    button.position = CGPointMake(150, 150);
    button.name = @"front";
    label = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Regular"];
    label.text = @"Front";
    label.fontSize = 30;
    label.fontColor = [SKColor blackColor];
    button.nodeNormal = label.copy;
    label.fontColor = [SKColor darkGrayColor];
    button.nodeHighlighted = label.copy;
    [button setTouchUpInsideTarget:self selector:@selector(bringSpriteToFront)];
    [self addChild:button];

    // The stack of sprites
    SKNode *stackRoot = [SKNode node];
    stackRoot.position = CGPointMake(0, -50);
    stackRoot.name = @"Stack Root";
    [self addChild:stackRoot];
    
    SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithColor:[SKColor colorWithRed:1 green:0 blue:0 alpha:ButtonAlpha] size:CGSizeMake(200, 100)];
    sprite.name = @"Red Sprite";
    sprite.position = CGPointMake(-75, -50);
    [stackRoot addChild:sprite];

    sprite = [SKSpriteNode spriteNodeWithColor:[SKColor colorWithRed:0 green:0 blue:1 alpha:ButtonAlpha] size:CGSizeMake(200, 100)];
    sprite.name = @"Blue Sprite";
    sprite.position = CGPointMake(75, -50);
    [stackRoot addChild:sprite];
    
    // The linked sprite node which changes in order
    self.whiteSprite = [SKSpriteNode spriteNodeWithColor:[SKColor colorWithRed:1 green:1 blue:1 alpha:ButtonAlpha] size:CGSizeMake(200, 100)];
    self.whiteSprite.name = @"White Sprite";
    self.whiteSprite.position = CGPointMake(0, 0);
    [stackRoot addChild:self.whiteSprite];
    
    return self;
}

- (void)sendSpriteToBack {
    [self.whiteSprite sendToBack];
}

- (void)bringSpriteToFront {
    [self.whiteSprite bringToFront];
}

- (void)moveSpriteInBetween {
    SKNode *parent = self.whiteSprite.parent;
    [self.whiteSprite removeFromParent];
    [parent insertChildOrNil:self.whiteSprite atIndex:1];
    // use the follwing line instead of the above one to see the bug in Sprite Kit
    // [parent insertChild:self.whiteSprite atIndex:1];
}


@end
