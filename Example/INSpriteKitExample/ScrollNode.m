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
    [self addChild:scrollNode];

    // Additional set up
    scrollNode.scrollBackgroundNode.color = [SKColor yellowColor];
    scrollNode.clipContent = YES;
    scrollNode.decelerationMode = INSKScrollNodeDecelerationModeDecelerate;
    scrollNode.pageSize = CGSizeMake(200, 200);
    scrollNode.scrollContentSize = CGSizeMake(1000, 1000);
    NSLog(@"scrollNode has %dx%d pages", scrollNode.numberOfPagesX, scrollNode.numberOfPagesY);

    // Set content size and position
    scrollNode.scrollContentPosition = CGPointMake(-(scrollNode.scrollContentSize.width - scrollNode.scrollNodeSize.width) / 2, (scrollNode.scrollContentSize.height - scrollNode.scrollNodeSize.height) / 2);

    // Add content to the scroll node
    SKSpriteNode *spaceship = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
    spaceship.position = CGPointMake(500, -500);
    [scrollNode.scrollContentNode addChild:spaceship];

    return self;
}

- (void)scrollNode:(INSKScrollNode *)scrollNode didScrollFromOffset:(CGPoint)fromOffset toOffset:(CGPoint)toOffset velocity:(CGPoint)velocity {
//    NSLog(@"scrollNode scrolled to %.0fx%0.f at page %d,%d", toOffset.x, toOffset.y, scrollNode.currentPageX, scrollNode.currentPageY);
}

- (void)scrollNode:(INSKScrollNode *)scrollNode didFinishScrollingAtPosition:(CGPoint)offset {
    NSLog(@"scrollNode finished scrolling at %.0fx%0.f on page %d,%d", offset.x, offset.y, scrollNode.currentPageX, scrollNode.currentPageY);
}


@end
