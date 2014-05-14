// ScrollNode.m
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


#import "ScrollNode.h"


@interface ScrollNode () <INSKScrollNodeDelegate>

@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) INSKScrollNode *scrollNode;

@end


@implementation ScrollNode

- (id)initWithSize:(CGSize)size {
    self = [super initWithSize:size];
    if (self == nil) return self;
    
    self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
    self.anchorPoint = CGPointMake(0.5, 0.5);

    // Create scroll node
    self.scrollNode = [INSKScrollNode scrollNodeWithSize:CGSizeMake(500, 700)];
    self.scrollNode.position = CGPointMake(-self.scrollNode.scrollNodeSize.width / 2, self.scrollNode.scrollNodeSize.height / 2);
    self.scrollNode.scrollDelegate = self;
    [self addChild:self.scrollNode];

    // Additional set up
    self.scrollNode.scrollBackgroundNode.color = [SKColor yellowColor];
    self.scrollNode.clipContent = YES;
    self.scrollNode.decelerationMode = INSKScrollNodeDecelerationModeDecelerate;
    self.scrollNode.pageSize = CGSizeMake(200, 200);
    self.scrollNode.scrollContentSize = CGSizeMake(1000, 1000);
    NSLog(@"scrollNode has %dx%d pages", self.scrollNode.numberOfPagesX, self.scrollNode.numberOfPagesY);

    // Set content size and position
    self.scrollNode.scrollContentPosition = CGPointMake(-(self.scrollNode.scrollContentSize.width - self.scrollNode.scrollNodeSize.width) / 2, (self.scrollNode.scrollContentSize.height - self.scrollNode.scrollNodeSize.height) / 2);

    // Add content to the scroll node
    SKSpriteNode *spaceship = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
    spaceship.position = CGPointMake(500, -500);
    [self.scrollNode.scrollContentNode addChild:spaceship];

    // add info label
    SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    label.fontSize = 17;
    label.text = @"Double tap for centering the space ship";
    label.position = CGPointMake(0, self.scrollNode.scrollNodeSize.height / 2);
    label.verticalAlignmentMode = SKLabelVerticalAlignmentModeBottom;
    [self addChild:label];
    
    // add toggle button
    INSKButtonNode *toggleButton = [INSKButtonNode buttonNodeWithSize:CGSizeMake(200, 50)];
    toggleButton.color = [SKColor lightGrayColor];
    label = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    label.fontSize = 17;
    label.text = @"Scrolling enabled";
    label.color = [SKColor greenColor];
    label.colorBlendFactor = 1;
    label.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    toggleButton.nodeNormal = label;
    toggleButton.nodeSelectedHighlighted = label;
    label = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    label.fontSize = 17;
    label.text = @"Scrolling disabled";
    label.color = [SKColor redColor];
    label.colorBlendFactor = 1;
    label.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    toggleButton.nodeSelectedNormal = label;
    toggleButton.nodeHighlighted = label;
    toggleButton.updateSelectedStateAutomatically = YES;
    toggleButton.position = CGPointMake(0, -self.scrollNode.scrollNodeSize.height / 2 - 70);
    [toggleButton setTouchUpInsideTarget:self selector:@selector(toggleButtonPressed:)];
    [self addChild:toggleButton];
    
    // add tap gesture recognizer
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapPressGesture:)];
    self.tapGestureRecognizer.numberOfTapsRequired = 2;

    return self;
}

- (void)didMoveToView:(SKView *)view {
    [self.view addGestureRecognizer:self.tapGestureRecognizer];
}

- (void)willMoveFromView:(SKView *)view {
    [self.view removeGestureRecognizer:self.tapGestureRecognizer];
}

- (void)handleTapPressGesture:(UITapGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateRecognized) {
        CGPoint contentCenterPosition = CGPointMake(-(self.scrollNode.scrollContentSize.width - self.scrollNode.scrollNodeSize.width) / 2, (self.scrollNode.scrollContentSize.height - self.scrollNode.scrollNodeSize.height) / 2);
        [self.scrollNode setScrollContentPosition:contentCenterPosition animationDuration:0.5];
    }
}

- (void)toggleButtonPressed:(INSKButtonNode *)button {
    self.scrollNode.scrollingEnabled = !button.selected;
}

- (void)scrollNode:(INSKScrollNode *)scrollNode didFinishScrollingAtPosition:(CGPoint)offset {
    NSLog(@"scrollNode finished scrolling at %.0fx%0.f on page %d,%d", offset.x, offset.y, scrollNode.currentPageX, scrollNode.currentPageY);
}


@end
