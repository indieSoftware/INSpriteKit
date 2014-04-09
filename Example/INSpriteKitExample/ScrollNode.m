//
//  ScrollNode.m
//  INSpriteKitExample
//
//  Created by Sven Korset on 09.04.14.
//  Copyright (c) 2014 indie-Software. All rights reserved.
//

#import "ScrollNode.h"


@interface ScrollNode () <INSKScrollNodeDelegate>

@end


@implementation ScrollNode

-(id)initWithSize:(CGSize)size {
    self = [super initWithSize:size];
    if (self == nil) return self;
    
    self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
    self.anchorPoint = CGPointMake(0.5, 0.5);

    // Create scroll node
    INSKScrollNode *scrollNode = [INSKScrollNode scrollNodeWithSize:CGSizeMake(500, 700)];
    scrollNode.position = CGPointMake(-scrollNode.scrollNodeSize.width / 2, scrollNode.scrollNodeSize.height / 2);
    scrollNode.scrollDelegate = self;
    scrollNode.scrollContentSize = CGSizeMake(1000, 1000);
    scrollNode.scrollBackgroundNode.color = [SKColor yellowColor];
    scrollNode.clipContent = YES;
    [self addChild:scrollNode];

    // Add content to the scroll node
    SKSpriteNode *spaceship = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
    spaceship.position = CGPointMake(500, -500);
    [scrollNode.scrollContentNode addChild:spaceship];

    return self;
}

- (void)scrollNode:(INSKScrollNode *)scrollNode didScrollFromOffset:(CGPoint)fromOffset toOffset:(CGPoint)toOffset {
    NSLog(@"scrollNode scrolled to %.0fx%0.f", toOffset.x, toOffset.y);
}


@end
