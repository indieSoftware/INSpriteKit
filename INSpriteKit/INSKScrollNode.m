// INSKScrollNode.m
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


#import "INSKScrollNode.h"
#import "INSKMath.h"


@interface INSKScrollNode ()

@property (nonatomic, strong, readwrite) SKSpriteNode *scrollBackgroundNode;
@property (nonatomic, strong, readwrite) SKNode *scrollContentNode;
@property (nonatomic, strong) SKCropNode *cropNode;

@end


@implementation INSKScrollNode

#pragma mark - public methods

+ (instancetype)scrollNodeWithSize:(CGSize)scrollNodeSize {
    return [[self alloc] initWithSize:scrollNodeSize];
}

- (instancetype)initWithSize:(CGSize)scrollNodeSize {
    self = [super init];
    if (self == nil) return self;

    self.scrollNodeSize = scrollNodeSize;
    self.scrollContentSize = CGSizeZero;
    self.clipContent = NO;
    self.userInteractionEnabled = YES;

    // create background node
    self.scrollBackgroundNode = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor] size:self.scrollNodeSize];
    self.scrollBackgroundNode.anchorPoint = CGPointMake(0.0, 1.0);
    [self addChild:self.scrollBackgroundNode];
    
    // create scroll content node
    self.scrollContentNode = [SKNode node];
    [self addChild:self.scrollContentNode];
    
    return self;
}

- (void)setClipContent:(BOOL)clipContent {
    _clipContent = clipContent;
    
    // remove old crop node
    if (self.cropNode != nil) {
        [self.scrollContentNode removeFromParent];
        [self addChild:self.scrollContentNode];
        
        [self.cropNode removeFromParent];
        self.cropNode = nil;
    }

    // add crop node
    if (clipContent) {
        self.cropNode = [SKCropNode node];
        [self addChild:self.cropNode];
        
        [self.scrollContentNode removeFromParent];
        [self.cropNode addChild:self.scrollContentNode];
        SKSpriteNode *maskNode = [SKSpriteNode spriteNodeWithColor:[SKColor blackColor] size:self.scrollBackgroundNode.size];
        maskNode.anchorPoint = CGPointMake(0.0, 1.0);
        self.cropNode.maskNode = maskNode;
    }
}

- (void)setScrollNodeSize:(CGSize)scrollNodeSize {
    _scrollNodeSize = scrollNodeSize;
    self.scrollBackgroundNode.size = scrollNodeSize;
    if (self.cropNode != nil) {
        ((SKSpriteNode *)self.cropNode.maskNode).size = scrollNodeSize;
    }
}

- (void)setScrollContentSize:(CGSize)scrollContentSize {
    _scrollContentSize = scrollContentSize;
    [self applyScrollLimits];
}


#pragma mark - private methods

- (void)applyScrollLimits {
    // limit scrolling horizontally
    if (self.scrollContentSize.width <= self.scrollNodeSize.width) {
        self.scrollContentNode.position = CGPointMake(0, self.scrollContentNode.position.y);
    } else  if (self.scrollContentNode.position.x > 0.0) {
        self.scrollContentNode.position = CGPointMake(0, self.scrollContentNode.position.y);
    } else if (self.scrollContentNode.position.x < -(self.scrollContentSize.width - self.scrollNodeSize.width)) {
        self.scrollContentNode.position = CGPointMake(-(self.scrollContentSize.width - self.scrollNodeSize.width), self.scrollContentNode.position.y);
    }
    
    // limit scrolling vertically
    if (self.scrollContentSize.height <= self.scrollNodeSize.height) {
        self.scrollContentNode.position = CGPointMake(self.scrollContentNode.position.x, 0);
    } else if (self.scrollContentNode.position.y < 0.0) {
        self.scrollContentNode.position = CGPointMake(self.scrollContentNode.position.x, 0);
    } else if (self.scrollContentNode.position.y > self.scrollContentSize.height - self.scrollNodeSize.height) {
        self.scrollContentNode.position = CGPointMake(self.scrollContentNode.position.x, self.scrollContentSize.height - self.scrollNodeSize.height);
    }
}


#pragma mark - touch events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    // find touch location
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self.scene.view];
    location = [self.scene convertPointFromView:location];
    
    // ignore clipped touches
    if (self.clipContent) {
        CGPoint locationInBounds = [self.scene convertPoint:location toNode:self];
        CGRect frame = CGRectMake(0, 0, self.scrollNodeSize.width, -self.scrollNodeSize.height);
        if (!CGRectContainsPoint(frame, locationInBounds)) {
            return;
        }
    }
    
    // calculate and apply translation
    CGPoint oldLocation = [touch previousLocationInView:self.scene.view];
    CGPoint oldLocationInverted = [self.scene convertPointFromView:oldLocation];
    CGPoint translation = CGPointSubtract(location, oldLocationInverted);
    CGPoint oldPosition = self.scrollContentNode.position;
    self.scrollContentNode.position = CGPointAdd(self.scrollContentNode.position, translation);

    [self applyScrollLimits];
    
    // inform subclasses and delegate
    [self didScrollFromOffset:oldPosition toOffset:self.scrollContentNode.position];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
}

- (void)didScrollFromOffset:(CGPoint)fromOffset toOffset:(CGPoint)toOffset {
    if ([self.scrollDelegate respondsToSelector:@selector(scrollNode:didScrollFromOffset:toOffset:)]) {
        [self.scrollDelegate scrollNode:self didScrollFromOffset:fromOffset toOffset:toOffset];
    }
}


@end
