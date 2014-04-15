//
//  ButtonNode.m
//  INSpriteKitExample
//
//  Created by Sven Korset on 14.04.14.
//  Copyright (c) 2014 indie-Software. All rights reserved.
//

#import "ButtonNode.h"


@interface ButtonNode ()

@end


@implementation ButtonNode

-(id)initWithSize:(CGSize)size {
    self = [super initWithSize:size];
    if (self == nil) return self;
    
    self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
    self.anchorPoint = CGPointMake(0.5, 0.5);
    
    INSKButtonNode *button;
    
    // Create push button
    button = [INSKButtonNode buttonNodeWithImageNamed:@"indie_banner_small" highlightImageNamed:@"indie_banner.jpg"];
    button.position = CGPointMake(0, 200);
    button.name = @"push button";
    [button setTouchUpInsideTarget:self selector:@selector(buttonTouchedUpInside:)];
    [self addChild:button];

    
    // Create toggle button
    button = [INSKButtonNode buttonNodeWithImageNamed:@"indie_banner_small"];
    button.position = CGPointMake(0, 0);
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
