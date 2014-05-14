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


static NSString * const ScrollContentMoveActionName = @"INSKScrollNodeMoveScrollContent";
static CGFloat const ScrollContentMoveActionDuration = 0.3;
static NSUInteger const MaxNumberOfVelocities = 5;


@interface INSKScrollNode ()

@property (nonatomic, strong, readwrite) SKSpriteNode *scrollBackgroundNode;
@property (nonatomic, strong, readwrite) SKNode *scrollContentNode;
@property (nonatomic, strong) SKCropNode *cropNode;

@property (nonatomic, assign) NSTimeInterval lastTouchTimestamp;
@property (nonatomic, strong) NSMutableArray *lastVelocities;

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
    self.deceleration = 10000;
    self.decelerationMode = INSKScrollNodeDecelerationModeNone;
    self.userInteractionEnabled = YES;
    self.scrollingEnabled = YES;
    self.lastVelocities = [NSMutableArray arrayWithCapacity:MaxNumberOfVelocities];

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

- (void)setScrollContentPosition:(CGPoint)scrollContentPosition animationDuration:(CGFloat)duration {
    if (duration <= 0 || CGPointNearToPoint(scrollContentPosition, self.scrollContentPosition)) {
        [self setScrollContentPosition:scrollContentPosition];
        return;
    }

    // v(t) = a * t + v0; s(t) = (a/2) * t*t + v0 * t + s0
    // v0 = v(t) - (a * t); sdiff = s(t) - s0; a = -2 * sdiff / t*t
    CGPoint positionDifference = CGPointSubtract(scrollContentPosition, self.scrollContentPosition);
    CGFloat differenceLength = CGPointLength(positionDifference);
    CGPoint differenceNormalized = CGPointMultiplyScalar(positionDifference, 1.0 / differenceLength);
    CGFloat deceleration = differenceLength * -2 / (duration * duration);
    CGFloat velocity = deceleration * -duration;
    
    CGPoint startPosition = self.scrollContentNode.position;
    
    SKAction *move = [SKAction customActionWithDuration:duration actionBlock:^(SKNode *node, CGFloat elapsedTime) {
        CGFloat distance = (deceleration / 2) * (elapsedTime * elapsedTime) + velocity * elapsedTime;
        CGPoint translation = CGPointMake(distance * differenceNormalized.x, distance * differenceNormalized.y);
        CGPoint currentPosition = CGPointAdd(startPosition, translation);
        node.position = [self positionWithScrollLimitsApplyed:currentPosition];
    }];
    SKAction *callback = [SKAction runBlock:^{
        [self didFinishScrollingAtPosition:self.scrollContentNode.position];
    }];
    [self.scrollContentNode runActions:@[move, callback] withKey:ScrollContentMoveActionName];
}

- (NSUInteger)numberOfPagesX {
    if (self.pageSize.width > 0) {
        return ceilf((self.scrollContentSize.width - self.scrollNodeSize.width) / self.pageSize.width);
    }
    return 0;
}

- (NSUInteger)numberOfPagesY {
    if (self.pageSize.height > 0) {
        return ceilf((self.scrollContentSize.height - self.scrollNodeSize.height) / self.pageSize.height);
    }
    return 0;
}

- (NSUInteger)currentPageX {
    if (self.pageSize.width > 0) {
        return roundf(-self.scrollContentNode.position.x / self.pageSize.width);
    }
    return 0;
}

- (NSUInteger)currentPageY {
    if (self.pageSize.height > 0) {
        return roundf(self.scrollContentNode.position.y / self.pageSize.height);
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
    [self.scrollContentNode removeActionForKey:ScrollContentMoveActionName];
}

- (void)applyScrollOutWithVelocity:(CGPoint)velocity {
    if (self.decelerationMode == INSKScrollNodeDecelerationModeNone) {
        [self didFinishScrollingAtPosition:self.scrollContentNode.position];
        return;
    }
    
    if (self.decelerationMode == INSKScrollNodeDecelerationModeDecelerate) {
        // any velocity at all?
        if (CGPointNearToPoint(velocity, CGPointZero)) {
            return;
        }
        
        // calculate and apply animation
        // v(t) = a * t + v0; s(t) = (a/2) * t*t + v0 * t + s0
        CGFloat velocityLength = CGPointLength(velocity);
        CGFloat time = velocityLength / self.deceleration;
        CGPoint velocityNormalized = CGPointMultiplyScalar(velocity, 1.0 / velocityLength);
        
        CGPoint startPosition = self.scrollContentNode.position;
        
        SKAction *move = [SKAction customActionWithDuration:time actionBlock:^(SKNode *node, CGFloat elapsedTime) {
            CGFloat distance = -self.deceleration * elapsedTime * elapsedTime / 2 + velocityLength * elapsedTime;
            CGPoint translation = CGPointMake(distance * velocityNormalized.x, distance * velocityNormalized.y);
            CGPoint currentPosition = CGPointAdd(startPosition, translation);
            node.position = [self positionWithScrollLimitsApplyed:currentPosition];
        }];
        SKAction *callback = [SKAction runBlock:^{
            [self didFinishScrollingAtPosition:self.scrollContentNode.position];
        }];
        [self.scrollContentNode runActions:@[move, callback] withKey:ScrollContentMoveActionName];

        return;
    }
    
    // calculate translation for page snapping
    CGPoint translation = CGPointZero;
    
    if (self.pageSize.width > 0) {
        CGFloat translationX = (NSInteger)self.scrollContentNode.position.x % (NSInteger)self.pageSize.width;
        BOOL snappingOccured = NO;
        if (self.decelerationMode == INSKScrollNodeDecelerationModePagingDirection) {
            if (velocity.x < 0) {
                translation.x = -self.pageSize.width - translationX;
                snappingOccured = YES;
            } else if (velocity.x > 0) {
                translation.x = -translationX;
                snappingOccured = YES;
            } else {
                // use INSKScrollNodeDecelerationModePagingHalfPage behavior
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
        if (self.decelerationMode == INSKScrollNodeDecelerationModePagingDirection) {
            if (velocity.y > 0) {
                translation.y = self.pageSize.height - translationY;
                snappingOccured = YES;
            } else if (velocity.y < 0) {
                translation.y = -translationY;
                snappingOccured = YES;
            } else {
                // use INSKScrollNodeDecelerationModePagingHalfPage behavior
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
        SKAction *move = [SKAction moveTo:destinationPosition duration:ScrollContentMoveActionDuration];
        move.timingMode = SKActionTimingEaseOut;
        SKAction *callback = [SKAction runBlock:^{
            [self didFinishScrollingAtPosition:destinationPosition];
        }];
        [self.scrollContentNode runActions:@[move, callback] withKey:ScrollContentMoveActionName];
    }
}

- (void)addVelocity:(CGPoint)velocity {
    if (self.lastVelocities.count == MaxNumberOfVelocities) {
        [self.lastVelocities removeObjectAtIndex:0];
    }
    [self.lastVelocities addObject:[NSValue valueWithCGPoint:velocity]];
}

- (CGPoint)getVelocity {
    CGPoint velocity = CGPointZero;
    for (NSValue *value in self.lastVelocities) {
        CGPoint point = [value CGPointValue];
        velocity = CGPointAdd(velocity, point);
    }
    if (self.lastVelocities.count > 0) {
        velocity = CGPointDivideScalar(velocity, self.lastVelocities.count);
    }
    return velocity;
}


#pragma mark - touch events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.scrollingEnabled) return;
    
    if (event.allTouches.count == touches.count) {
        [self stopScrollAnimations];

        UITouch *touch = [touches anyObject];
        self.lastTouchTimestamp = touch.timestamp;
        [self.lastVelocities removeAllObjects];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.scrollingEnabled) return;

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
    CGPoint lastLocation = [touch previousLocationInNode:self.scene];
    CGPoint translation = CGPointSubtract(location, lastLocation);
    CGPoint oldPosition = self.scrollContentNode.position;
    self.scrollContentNode.position = CGPointAdd(self.scrollContentNode.position, translation);

    // calculate velocity
    NSTimeInterval timeDifferecne = touch.timestamp - self.lastTouchTimestamp;
    self.lastTouchTimestamp = touch.timestamp;
    CGPoint scrollVelocity = CGPointDivideScalar(translation, timeDifferecne);
    [self addVelocity:scrollVelocity];

    [self applyScrollLimits];
    
    // inform subclasses and delegate
    [self didScrollFromOffset:oldPosition toOffset:self.scrollContentNode.position velocity:[self getVelocity]];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.scrollingEnabled) return;

    if (event.allTouches.count == touches.count) {
        [self applyScrollOutWithVelocity:[self getVelocity]];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.scrollingEnabled) return;

    [self applyScrollOutWithVelocity:[self getVelocity]];
}


#pragma mark - methods to override

- (void)didScrollFromOffset:(CGPoint)fromOffset toOffset:(CGPoint)toOffset velocity:(CGPoint)velocity {
    if ([self.scrollDelegate respondsToSelector:@selector(scrollNode:didScrollFromOffset:toOffset:velocity:)]) {
        [self.scrollDelegate scrollNode:self didScrollFromOffset:fromOffset toOffset:toOffset velocity:(CGPoint)velocity];
    }
}

- (void)didFinishScrollingAtPosition:(CGPoint)offset {
    if ([self.scrollDelegate respondsToSelector:@selector(scrollNode:didFinishScrollingAtPosition:)]) {
        [self.scrollDelegate scrollNode:self didFinishScrollingAtPosition:offset];
    }
}


@end
