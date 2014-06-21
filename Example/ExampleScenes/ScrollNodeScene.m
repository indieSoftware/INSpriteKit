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

#if TARGET_OS_IPHONE
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
#endif
@property (nonatomic, strong) INSKScrollNode *scrollNode;
@property (nonatomic, assign) INSKScrollNodeDecelerationMode scrollDecelerationMode;

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
    self.scrollDecelerationMode = INSKScrollNodeDecelerationModeDecelerate;
    self.scrollNode.decelerationMode = self.scrollDecelerationMode;
    self.scrollNode.scrollContentSize = CGSizeMake(1000, 1000);
    
    // Set content size and position
    self.scrollNode.scrollContentPosition = CGPointMake(-(self.scrollNode.scrollContentSize.width - self.scrollNode.scrollNodeSize.width) / 2, (self.scrollNode.scrollContentSize.height - self.scrollNode.scrollNodeSize.height) / 2);

    // Add content to the scroll node
    SKSpriteNode *background = [SKSpriteNode spriteNodeWithColor:[SKColor colorWithRed:1 green:1 blue:1 alpha:0.2] size:self.scrollNode.scrollContentSize];
    background.position = CGPointMake(background.size.width/2, -background.size.height/2);
    [self.scrollNode.scrollContentNode addChild:background];
    SKSpriteNode *spaceship = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
    spaceship.position = CGPointMake(500, -500);
    [self.scrollNode.scrollContentNode addChild:spaceship];
    
    // Create paging lines and set up for paging, but don't activate it
    self.scrollNode.pageSize = CGSizeMake(200, 200);
    for (NSInteger x = self.scrollNode.pageSize.width; x < self.scrollNode.scrollContentSize.width; x += self.scrollNode.pageSize.width) {
        SKSpriteNode *line = [SKSpriteNode spriteNodeWithColor:[SKColor colorWithRed:0 green:0 blue:0 alpha:0.4] size:CGSizeMake(2, self.scrollNode.scrollContentSize.height)];
        line.anchorPoint = CGPointMake(0, 1);
        line.position = CGPointMake(x-1, 0);
        [self.scrollNode.scrollContentNode addChild:line];
    }
    for (NSInteger y = self.scrollNode.pageSize.height; y < self.scrollNode.scrollContentSize.height; y += self.scrollNode.pageSize.height) {
        SKSpriteNode *line = [SKSpriteNode spriteNodeWithColor:[SKColor colorWithRed:0 green:0 blue:0 alpha:0.4] size:CGSizeMake(self.scrollNode.scrollContentSize.width, 2)];
        line.anchorPoint = CGPointMake(0, 0);
        line.position = CGPointMake(0, -y+1);
        [self.scrollNode.scrollContentNode addChild:line];
    }
    NSLog(@"scrollNode has %lux%lu pages", (unsigned long)self.scrollNode.numberOfPagesX, (unsigned long)self.scrollNode.numberOfPagesY);

    // Create custom crop node, but don't activate clipping, yet
    SKSpriteNode *cropMask = [SKSpriteNode spriteNodeWithColor:[SKColor redColor] size:CGSizeMake(self.scrollNode.scrollNodeSize.width*2/3, self.scrollNode.scrollNodeSize.height*2/3)];
    SKCropNode *cropNode = [[SKCropNode alloc] init];
    [cropNode setMaskNode:cropMask];
    cropNode.position = CGPointMake(self.scrollNode.scrollNodeSize.width/2, -self.scrollNode.scrollNodeSize.height/2);
    self.scrollNode.contentCropNode = cropNode;

    // Add info label
    SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    label.fontSize = 14;
    label.text = @"The blue is the scroll node itself and the transparent white is the scroll node's content.";
    label.position = CGPointMake(0, (self.scrollNode.scrollNodeSize.height / 2) + 30);
    label.verticalAlignmentMode = SKLabelVerticalAlignmentModeBottom;
    [self addChild:label];
    
    label = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    label.fontSize = 14;
#if TARGET_OS_IPHONE
    label.text = @"Double tap for centering the scroll content.";
#else
    label.text = @"Right mouse click for centering the scroll content.";
#endif
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
    toggleButton.position = CGPointMake(-250, -self.scrollNode.scrollNodeSize.height / 2 - 70);
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
    toggleButton.position = CGPointMake(0, -self.scrollNode.scrollNodeSize.height / 2 - 70);
    [toggleButton setTouchUpInsideTarget:self selector:@selector(toggleButtonCropPressed:)];
    [self addChild:toggleButton];
    
    // Add toggle deceleration mode button
    toggleButton = [INSKButtonNode buttonNodeWithSize:CGSizeMake(200, 50)];
    toggleButton.color = [SKColor lightGrayColor];
    label = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    label.fontSize = 17;
    label.text = @"Decelerate";
    label.color = [SKColor blueColor];
    label.colorBlendFactor = 1;
    label.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    toggleButton.nodeNormal = label;
    label = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    label.fontSize = 17;
    label.text = @"Deceleration Mode";
    label.color = [SKColor whiteColor];
    label.colorBlendFactor = 1;
    label.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    toggleButton.nodeHighlighted = label;
    toggleButton.position = CGPointMake(250, -self.scrollNode.scrollNodeSize.height / 2 - 70);
    [toggleButton setTouchUpInsideTarget:self selector:@selector(toggleButtonDecelerationModePressed:)];
    [self addChild:toggleButton];
    
#if TARGET_OS_IPHONE
    // Add tap gesture recognizer
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapPressGesture:)];
    self.tapGestureRecognizer.numberOfTapsRequired = 2;
#endif

    return self;
}

- (void)didMoveToView:(SKView *)view {
#if TARGET_OS_IPHONE
    [self.view addGestureRecognizer:self.tapGestureRecognizer];
#endif
}

- (void)willMoveFromView:(SKView *)view {
#if TARGET_OS_IPHONE
    [self.view removeGestureRecognizer:self.tapGestureRecognizer];
#endif
}


#if TARGET_OS_IPHONE

- (void)handleTapPressGesture:(UITapGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateRecognized) {
        CGPoint contentCenterPosition = CGPointMake(-(self.scrollNode.scrollContentSize.width - self.scrollNode.scrollNodeSize.width) / 2, (self.scrollNode.scrollContentSize.height - self.scrollNode.scrollNodeSize.height) / 2);
        [self.scrollNode setScrollContentPosition:contentCenterPosition animationDuration:0.5];
    }
}

#else // OS X

- (void)rightMouseUp:(NSEvent *)theEvent {
    CGPoint contentCenterPosition = CGPointMake(-(self.scrollNode.scrollContentSize.width - self.scrollNode.scrollNodeSize.width) / 2, (self.scrollNode.scrollContentSize.height - self.scrollNode.scrollNodeSize.height) / 2);
    [self.scrollNode setScrollContentPosition:contentCenterPosition animationDuration:0.5];
}

#endif // OS X


- (void)toggleButtonEnablePressed:(INSKButtonNode *)button {
    self.scrollNode.scrollingEnabled = !button.selected;
}

- (void)toggleButtonCropPressed:(INSKButtonNode *)button {
    self.scrollNode.clipContent = button.selected;
}

- (void)toggleButtonDecelerationModePressed:(INSKButtonNode *)button {
    SKLabelNode *label = (SKLabelNode *)button.nodeNormal;
    if (self.scrollDecelerationMode == INSKScrollNodeDecelerationModeNone) {
        self.scrollDecelerationMode = INSKScrollNodeDecelerationModePagingHalfPage;
        label.text = @"Paging Half Page";
    } else if (self.scrollDecelerationMode == INSKScrollNodeDecelerationModePagingHalfPage) {
        self.scrollDecelerationMode = INSKScrollNodeDecelerationModePagingDirection;
        label.text = @"Paging Direction";
    } else if (self.scrollDecelerationMode == INSKScrollNodeDecelerationModePagingDirection) {
        self.scrollDecelerationMode = INSKScrollNodeDecelerationModeDecelerate;
        label.text = @"Decelerate";
    } else if (self.scrollDecelerationMode == INSKScrollNodeDecelerationModeDecelerate) {
        self.scrollDecelerationMode = INSKScrollNodeDecelerationModeNone;
        label.text = @"None";
    } else {
        NSAssert(false, @"unknown deceleration mode");
    }
    self.scrollNode.decelerationMode = self.scrollDecelerationMode;
}

- (void)scrollNode:(INSKScrollNode *)scrollNode didFinishScrollingAtPosition:(CGPoint)offset {
    NSLog(@"scrollNode finished scrolling at %.0fx%0.f on page %lu,%lu", offset.x, offset.y, (unsigned long)scrollNode.currentPageX, (unsigned long)scrollNode.currentPageY);
}


@end
