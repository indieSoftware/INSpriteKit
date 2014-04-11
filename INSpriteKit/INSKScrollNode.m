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
#import "SKNode+INExtension.h"


static NSString * const PagedContentMoveActionName = @"INSKScrollNodeMovePagedContent";
static CGFloat const PagedContentMoveActionDuration = 0.3;


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
    self.pageSize = CGSizeZero;
    self.pagingMode = INSKScrollNodePageModeNone;
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

    [self stopScrollAnimations];
    [self applyScrollLimits];
}

- (void)setScrollContentPosition:(CGPoint)scrollContentPosition {
    self.scrollContentNode.position = scrollContentPosition;
    [self stopScrollAnimations];
    [self applyScrollLimits];
}

- (CGPoint)scrollContentPosition {
    return self.scrollContentNode.position;
}

- (NSUInteger)numberOfPagesX {
    if (self.pagingMode == INSKScrollNodePageModeHalfPage || self.pagingMode == INSKScrollNodePageModeDirection) {
        if (self.pageSize.width > 0) {
            return ceilf((self.scrollContentSize.width - self.scrollNodeSize.width) / self.pageSize.width);
        }
    }
    return 0;
}

- (NSUInteger)numberOfPagesY {
    if (self.pagingMode == INSKScrollNodePageModeHalfPage || self.pagingMode == INSKScrollNodePageModeDirection) {
        if (self.pageSize.height > 0) {
            return ceilf((self.scrollContentSize.height - self.scrollNodeSize.height) / self.pageSize.height);
        }
    }
    return 0;
}

- (NSUInteger)currentPageX {
    if (self.pagingMode == INSKScrollNodePageModeHalfPage || self.pagingMode == INSKScrollNodePageModeDirection) {
        if (self.pageSize.width > 0) {
            return roundf(-self.scrollContentNode.position.x / self.pageSize.width);
        }
    }
    return 0;
}

- (NSUInteger)currentPageY {
    if (self.pagingMode == INSKScrollNodePageModeHalfPage || self.pagingMode == INSKScrollNodePageModeDirection) {
        if (self.pageSize.height > 0) {
            return roundf(self.scrollContentNode.position.y / self.pageSize.height);
        }
    }
    return 0;
}


#pragma mark - private methods

- (CGPoint)positionWithScrollLimitsApplyed:(CGPoint)position {
    // limit scrolling horizontally
    if (self.scrollContentSize.width <= self.scrollNodeSize.width) {
        position = CGPointMake(0, position.y);
    } else  if (position.x > 0.0) {
        position = CGPointMake(0, position.y);
    } else if (position.x < -(self.scrollContentSize.width - self.scrollNodeSize.width)) {
        position = CGPointMake(-(self.scrollContentSize.width - self.scrollNodeSize.width), position.y);
    }
    
    // limit scrolling vertically
    if (self.scrollContentSize.height <= self.scrollNodeSize.height) {
        position = CGPointMake(position.x, 0);
    } else if (position.y < 0.0) {
        position = CGPointMake(position.x, 0);
    } else if (position.y > self.scrollContentSize.height - self.scrollNodeSize.height) {
        position = CGPointMake(position.x, self.scrollContentSize.height - self.scrollNodeSize.height);
    }
    
    return position;
}

- (void)applyScrollLimits {
    self.scrollContentNode.position = [self positionWithScrollLimitsApplyed:self.scrollContentNode.position];
}

- (void)stopScrollAnimations {
    [self.scrollContentNode removeActionForKey:PagedContentMoveActionName];
}

- (void)applySnappingWithDirection:(CGPoint)direction {
    if (self.pagingMode == INSKScrollNodePageModeNone) {
        [self didFinishScrollingAtPosition:self.scrollContentNode.position];
        return;
    }
    
    // calculate translation for page snapping
    CGPoint translation = CGPointZero;
    NSLog(@"dir %f", direction.x);
    
    if (self.pageSize.width > 0) {
        CGFloat translationX = (NSInteger)self.scrollContentNode.position.x % (NSInteger)self.pageSize.width;
        BOOL snappingOccured = NO;
        if (self.pagingMode == INSKScrollNodePageModeDirection) {
            if (direction.x < 0) {
                translation.x = -self.pageSize.width - translationX;
                snappingOccured = YES;
            } else if (direction.x > 0) {
                translation.x = -translationX;
                snappingOccured = YES;
            } else {
                // use INSKScrollNodePageModeHalfPage behavior
            }
        }
        if (!snappingOccured) {
            if (fabs(translationX) >= self.pageSize.width / 2) {
                translation.x = -self.pageSize.width - translationX;
            } else {
                translation.x = -translationX;
            }
        }
    }
    
    if (self.pageSize.height > 0) {
        CGFloat translationY = (NSInteger)self.scrollContentNode.position.y % (NSInteger)self.pageSize.height;
        BOOL snappingOccured = NO;
        if (self.pagingMode == INSKScrollNodePageModeDirection) {
            if (direction.y > 0) {
                translation.y = self.pageSize.height - translationY;
                snappingOccured = YES;
            } else if (direction.y < 0) {
                translation.y = -translationY;
                snappingOccured = YES;
            } else {
                // use INSKScrollNodePageModeHalfPage behavior
            }
        }
        if (!snappingOccured) {
            if (translationY >= self.pageSize.height / 2) {
                translation.y = self.pageSize.height - translationY;
            } else {
                translation.y = -translationY;
            }
        }
    }
    
    // apply scroll bounds for destination position
    CGPoint destinationPosition = CGPointAdd(self.scrollContentNode.position, translation);
    destinationPosition = [self positionWithScrollLimitsApplyed:destinationPosition];
    
    // apply snap animation
    if (!CGPointNearToPoint(destinationPosition, self.scrollContentNode.position)) {
        SKAction *move = [SKAction moveTo:destinationPosition duration:PagedContentMoveActionDuration];
        move.timingMode = SKActionTimingEaseOut;
        SKAction *callback = [SKAction runBlock:^{
            [self didFinishScrollingAtPosition:destinationPosition];
        }];
        [self.scrollContentNode runActions:@[move, callback] withKey:PagedContentMoveActionName];
    }
}


#pragma mark - touch events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (event.allTouches.count == touches.count) {
        [self stopScrollAnimations];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    // find touch location
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self.scene];
    
    // ignore clipped touches
    if (self.clipContent) {
        CGPoint locationInBounds = [self.scene convertPoint:location toNode:self];
        CGRect frame = CGRectMake(0, 0, self.scrollNodeSize.width, -self.scrollNodeSize.height);
        if (!CGRectContainsPoint(frame, locationInBounds)) {
            return;
        }
    }
    
    // calculate and apply translation
    CGPoint oldLocation = [touch previousLocationInNode:self.scene];
    CGPoint translation = CGPointSubtract(location, oldLocation);
    CGPoint oldPosition = self.scrollContentNode.position;
    self.scrollContentNode.position = CGPointAdd(self.scrollContentNode.position, translation);

    [self applyScrollLimits];
    
    // inform subclasses and delegate
    [self didScrollFromOffset:oldPosition toOffset:self.scrollContentNode.position];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (event.allTouches.count == touches.count) {
        UITouch *touch = [touches anyObject];
        CGPoint location = [touch locationInNode:self.scene];
        CGPoint lastLocation = [touch previousLocationInNode:self.scene];
        CGPoint direction = CGPointSubtract(location, lastLocation);
        
        [self applySnappingWithDirection:direction];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self.scene];
    CGPoint lastLocation = [touch previousLocationInNode:self.scene];
    CGPoint direction = CGPointSubtract(location, lastLocation);
    
    [self applySnappingWithDirection:direction];
}


#pragma mark - methods to override

- (void)didScrollFromOffset:(CGPoint)fromOffset toOffset:(CGPoint)toOffset {
    if ([self.scrollDelegate respondsToSelector:@selector(scrollNode:didScrollFromOffset:toOffset:)]) {
        [self.scrollDelegate scrollNode:self didScrollFromOffset:fromOffset toOffset:toOffset];
    }
}

- (void)didFinishScrollingAtPosition:(CGPoint)offset {
    if ([self.scrollDelegate respondsToSelector:@selector(scrollNode:didFinishScrollingAtPosition:)]) {
        [self.scrollDelegate scrollNode:self didFinishScrollingAtPosition:offset];
    }
}


@end
