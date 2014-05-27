// ScrollNodeScene.m
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


#import "ScrollNodeScene.h"


@interface ScrollNodeScene () <INSKScrollNodeDelegate>

@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) INSKScrollNode *scrollNode;

@end


@implementation ScrollNodeScene

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
    self.scrollNode.scrollBackgroundNode.color = [SKColor blueColor];
//    self.scrollNode.decelerationMode = INSKScrollNodeDecelerationModeNone;
//    self.scrollNode.decelerationMode = INSKScrollNodeDecelerationModePagingHalfPage;
//    self.scrollNode.decelerationMode = INSKScrollNodeDecelerationModePagingDirection;
    self.scrollNode.decelerationMode = INSKScrollNodeDecelerationModeDecelerate;
    self.scrollNode.pageSize = CGSizeMake(200, 200);
    self.scrollNode.scrollContentSize = CGSizeMake(1000, 1000);
    NSLog(@"scrollNode has %lux%lu pages", (unsigned long)self.scrollNode.numberOfPagesX, (unsigned long)self.scrollNode.numberOfPagesY);

    // Set content size and position
    self.scrollNode.scrollContentPosition = CGPointMake(-(self.scrollNode.scrollContentSize.width - self.scrollNode.scrollNodeSize.width) / 2, (self.scrollNode.scrollContentSize.height - self.scrollNode.scrollNodeSize.height) / 2);

    // Add content to the scroll node
    SKSpriteNode *background = [SKSpriteNode spriteNodeWithColor:[SKColor colorWithRed:1 green:1 blue:1 alpha:0.2] size:self.scrollNode.scrollContentSize];
    background.position = CGPointMake(background.size.width/2, -background.size.height/2);
    [self.scrollNode.scrollContentNode addChild:background];
    SKSpriteNode *spaceship = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
    spaceship.position = CGPointMake(500, -500);
    [self.scrollNode.scrollContentNode addChild:spaceship];
    
    // Create custom crop node, but don't activate clipping, yet
    SKSpriteNode *cropMask = [SKSpriteNode spriteNodeWithColor:[SKColor redColor] size:CGSizeMake(self.scrollNode.scrollNodeSize.width*2/3, self.scrollNode.scrollNodeSize.height*2/3)];
    SKCropNode *cropNode = [[SKCropNode alloc] init];
    [cropNode setMaskNode:cropMask];
    cropNode.position = CGPointMake(self.scrollNode.scrollNodeSize.width/2, -self.scrollNode.scrollNodeSize.height/2);
    self.scrollNode.contentCropNode = cropNode;

    // Add info label
    SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    label.fontSize = 17;
    label.text = @"Double tap for centering the space ship";
    label.position = CGPointMake(0, self.scrollNode.scrollNodeSize.height / 2);
    label.verticalAlignmentMode = SKLabelVerticalAlignmentModeBottom;
    [self addChild:label];
    
    // Add toggle disable button
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
    toggleButton.position = CGPointMake(-150, -self.scrollNode.scrollNodeSize.height / 2 - 70);
    [toggleButton setTouchUpInsideTarget:self selector:@selector(toggleButtonEnablePressed:)];
    [self addChild:toggleButton];
    
    // Add toggle clipping button
    toggleButton = [INSKButtonNode buttonNodeWithSize:CGSizeMake(200, 50)];
    toggleButton.color = [SKColor lightGrayColor];
    label = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    label.fontSize = 17;
    label.text = @"Cropping disabled";
    label.color = [SKColor redColor];
    label.colorBlendFactor = 1;
    label.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    toggleButton.nodeNormal = label;
    toggleButton.nodeSelectedHighlighted = label;
    label = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    label.fontSize = 17;
    label.text = @"Cropping enabled";
    label.color = [SKColor greenColor];
    label.colorBlendFactor = 1;
    label.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    toggleButton.nodeSelectedNormal = label;
    toggleButton.nodeHighlighted = label;
    toggleButton.updateSelectedStateAutomatically = YES;
    toggleButton.position = CGPointMake(150, -self.scrollNode.scrollNodeSize.height / 2 - 70);
    [toggleButton setTouchUpInsideTarget:self selector:@selector(toggleButtonCropPressed:)];
    [self addChild:toggleButton];
    
    // Add tap gesture recognizer
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

- (void)toggleButtonEnablePressed:(INSKButtonNode *)button {
    self.scrollNode.scrollingEnabled = !button.selected;
}

- (void)toggleButtonCropPressed:(INSKButtonNode *)button {
    self.scrollNode.clipContent = button.selected;
}

- (void)scrollNode:(INSKScrollNode *)scrollNode didFinishScrollingAtPosition:(CGPoint)offset {
    NSLog(@"scrollNode finished scrolling at %.0fx%0.f on page %lu,%lu", offset.x, offset.y, (unsigned long)scrollNode.currentPageX, (unsigned long)scrollNode.currentPageY);
}


@end
