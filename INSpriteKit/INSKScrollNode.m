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
#import "INSKOSBridge.h"
#import "INSKMath.h"
#import "SKNode+INExtension.h"


static NSString * const ScrollContentMoveActionName = @"INSKScrollNodeMoveScrollContent";
static CGFloat const ScrollContentMoveActionDuration = 0.3;
static NSUInteger const MaxNumberOfVelocities = 5;


@interface INSKScrollNode ()

@property (nonatomic, strong, readwrite) SKSpriteNode *scrollBackgroundNode;
@property (nonatomic, strong, readwrite) SKNode *scrollContentNode;

@property (nonatomic, assign) NSTimeInterval lastTouchTimestamp;
@property (nonatomic, strong) NSMutableArray *lastVelocities; // NSValue of CGPoint for avegate calculations

// The number of mouse buttons this node is currently tracking. OS X only.
@property (nonatomic, assign) NSUInteger numberOfMouseButtonsPressed;
// The last mouse event's position. OS X only.
@property (nonatomic, assign) CGPoint positionOfLastMouseEvent;

@end


@implementation INSKScrollNode

#pragma mark - public methods

+ (instancetype)scrollNodeWithSize:(CGSize)scrollNodeSize {
    return [[self alloc] initWithSize:scrollNodeSize];
}

- (instancetype)initWithSize:(CGSize)scrollNodeSize {
    self = [super init];
    if (self == nil) return self;

    _scrollNodeSize = scrollNodeSize;
    _scrollContentSize = CGSizeZero;
    self.pageSize = CGSizeZero;
    self.deceleration = 10000;
    self.decelerationMode = INSKScrollNodeDecelerationModeNone;
    self.userInteractionEnabled = YES;
    self.scrollingEnabled = YES;
    self.lastVelocities = [NSMutableArray arrayWithCapacity:MaxNumberOfVelocities];
    _clipContent = NO;
    
    self.numberOfMouseButtonsPressed = 0;

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
    if (_clipContent == clipContent) {
        return;
    }
    _clipContent = clipContent;
    
    // Create crop node if needed
    if (_clipContent && _contentCropNode == nil) {
        SKSpriteNode *maskNode = [SKSpriteNode spriteNodeWithColor:[SKColor blackColor] size:self.scrollBackgroundNode.size];
        maskNode.anchorPoint = CGPointMake(0.0, 1.0);
        SKCropNode *cropNode = [SKCropNode node];
        cropNode.maskNode = maskNode;
        _contentCropNode = cropNode;
    }
    
    // Add content and crop node
    [self stopScrollAnimations];
    if (_clipContent) {
        [self.contentCropNode changeParent:self];
        [self.scrollContentNode changeParent:self.contentCropNode];
    } else {
        [self.scrollContentNode changeParent:self];
        [self.contentCropNode removeFromParent];
    }
}

- (void)setContentCropNode:(SKCropNode *)contentCropNode {
    // First disable clipping so the old crop node will be disabled
    BOOL oldClipFlag = self.clipContent;
    self.clipContent = NO;
    // Exchange the crop node, which also may be nil
    _contentCropNode = contentCropNode;
    // Restore the clipping flag to add the content to the new crop node and create a default one if nil
    self.clipContent = oldClipFlag;
}

- (void)setScrollNodeSize:(CGSize)scrollNodeSize {
    _scrollNodeSize = scrollNodeSize;
    self.scrollBackgroundNode.size = scrollNodeSize;
    if (self.contentCropNode != nil) {
        ((SKSpriteNode *)self.contentCropNode.maskNode).size = scrollNodeSize;
    }
}

- (void)setScrollContentSize:(CGSize)scrollContentSize {
    _scrollContentSize = scrollContentSize;

    [self stopScrollAnimations];
    [self applyScrollLimits];
}

- (void)setScrollContentPosition:(CGPoint)scrollContentPosition {
    if (self.scrollContentNode.parent != self) {
        scrollContentPosition = [self convertPoint:scrollContentPosition toNode:self.scrollContentNode.parent];
    }
    self.scrollContentNode.position = scrollContentPosition;
    [self stopScrollAnimations];
    [self applyScrollLimits];
}

- (CGPoint)scrollContentPosition {
    CGPoint position = self.scrollContentNode.position;
    if (self.scrollContentNode.parent != self) {
        return [self convertPoint:position fromNode:self.scrollContentNode.parent];
    }
    return position;
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
    
    CGPoint startPosition = self.scrollContentPosition;
    
    SKAction *move = [SKAction customActionWithDuration:duration actionBlock:^(SKNode *node, CGFloat elapsedTime) {
        CGFloat distance = (deceleration / 2) * (elapsedTime * elapsedTime) + velocity * elapsedTime;
        CGPoint translation = CGPointMake(distance * differenceNormalized.x, distance * differenceNormalized.y);
        CGPoint currentPosition = CGPointAdd(startPosition, translation);
        currentPosition = [self positionWithScrollLimitsApplyed:currentPosition];
        if (node.parent != self) {
            currentPosition = [self convertPoint:currentPosition toNode:node.parent];
        }
        node.position = currentPosition;
    }];
    SKAction *callback = [SKAction runBlock:^{
        [self didFinishScrollingAtPosition:self.scrollContentPosition];
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
        return roundf(-self.scrollContentPosition.x / self.pageSize.width);
    }
    return 0;
}

- (NSUInteger)currentPageY {
    if (self.pageSize.height > 0) {
        return roundf(self.scrollContentPosition.y / self.pageSize.height);
    }
    return 0;
}


#pragma mark - private methods

// Position has to be in the coordinate system of self (INSKScrollNode).
// Get the position via scrollContentPosition or convert manually if the crop node is active.
- (CGPoint)positionWithScrollLimitsApplyed:(CGPoint)position {
    // Limit scrolling horizontally
    if (self.scrollContentSize.width <= self.scrollNodeSize.width) {
        position = CGPointMake(0, position.y);
    } else  if (position.x > 0.0) {
        position = CGPointMake(0, position.y);
    } else if (position.x < -(self.scrollContentSize.width - self.scrollNodeSize.width)) {
        position = CGPointMake(-(self.scrollContentSize.width - self.scrollNodeSize.width), position.y);
    }
    
    // Limit scrolling vertically
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
    CGPoint currentPosition = [self positionWithScrollLimitsApplyed:self.scrollContentPosition];
    if (self.scrollContentNode.parent != self) {
        currentPosition = [self convertPoint:currentPosition toNode:self.scrollContentNode.parent];
    }
    self.scrollContentNode.position = currentPosition;
}

- (void)stopScrollAnimations {
    [self.scrollContentNode removeActionForKey:ScrollContentMoveActionName];
}

- (void)applyScrollOutWithVelocity:(CGPoint)velocity {
    if (self.decelerationMode == INSKScrollNodeDecelerationModeNone) {
        [self didFinishScrollingAtPosition:self.scrollContentPosition];
        return;
    }
    
    if (self.decelerationMode == INSKScrollNodeDecelerationModeDecelerate) {
        // Any velocity at all?
        if (CGPointNearToPoint(velocity, CGPointZero)) {
            return;
        }
        
        // Calculate and apply animation
        // v(t) = a * t + v0; s(t) = (a/2) * t*t + v0 * t + s0
        CGFloat velocityLength = CGPointLength(velocity);
        CGFloat time = velocityLength / self.deceleration;
        CGPoint velocityNormalized = CGPointMultiplyScalar(velocity, 1.0 / velocityLength);
        
        CGPoint startPosition = self.scrollContentPosition;
        
        SKAction *move = [SKAction customActionWithDuration:time actionBlock:^(SKNode *node, CGFloat elapsedTime) {
            CGFloat distance = -self.deceleration * elapsedTime * elapsedTime / 2 + velocityLength * elapsedTime;
            CGPoint translation = CGPointMake(distance * velocityNormalized.x, distance * velocityNormalized.y);
            CGPoint currentPosition = CGPointAdd(startPosition, translation);
            currentPosition = [self positionWithScrollLimitsApplyed:currentPosition];
            if (node.parent != self) {
                currentPosition = [self convertPoint:currentPosition toNode:node.parent];
            }
            node.position = currentPosition;
        }];
        SKAction *callback = [SKAction runBlock:^{
            [self didFinishScrollingAtPosition:self.scrollContentPosition];
        }];
        [self.scrollContentNode runActions:@[move, callback] withKey:ScrollContentMoveActionName];

        return;
    }
    
    // Calculate translation for page snapping
    CGPoint translation = CGPointZero;
    
    if (self.pageSize.width > 0) {
        CGFloat translationX = (NSInteger)self.scrollContentPosition.x % (NSInteger)self.pageSize.width;
        BOOL snappingOccured = NO;
        if (self.decelerationMode == INSKScrollNodeDecelerationModePagingDirection) {
            if (velocity.x < 0) {
                translation.x = -self.pageSize.width - translationX;
                snappingOccured = YES;
            } else if (velocity.x > 0) {
                translation.x = -translationX;
                snappingOccured = YES;
            } else {
                // Use INSKScrollNodeDecelerationModePagingHalfPage behavior
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
        CGFloat translationY = (NSInteger)self.scrollContentPosition.y % (NSInteger)self.pageSize.height;
        BOOL snappingOccured = NO;
        if (self.decelerationMode == INSKScrollNodeDecelerationModePagingDirection) {
            if (velocity.y > 0) {
                translation.y = self.pageSize.height - translationY;
                snappingOccured = YES;
            } else if (velocity.y < 0) {
                translation.y = -translationY;
                snappingOccured = YES;
            } else {
                // Use INSKScrollNodeDecelerationModePagingHalfPage behavior
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

    // Apply scroll bounds for destination position
    CGPoint destinationPosition = CGPointAdd(self.scrollContentPosition, translation);
    destinationPosition = [self positionWithScrollLimitsApplyed:destinationPosition];
    
    // Apply snap animation
    if (!CGPointNearToPoint(destinationPosition, self.scrollContentPosition)) {
        SKAction *move = [SKAction moveTo:destinationPosition duration:ScrollContentMoveActionDuration];
        move.timingMode = SKActionTimingEaseOut;
        SKAction *callback = [SKAction runBlock:^{
            [self didFinishScrollingAtPosition:destinationPosition];
        }];
        [self.scrollContentNode runActions:@[move, callback] withKey:ScrollContentMoveActionName];
    }
}

- (void)addVelocityToAverage:(CGPoint)velocity {
    if (self.lastVelocities.count == MaxNumberOfVelocities) {
        [self.lastVelocities removeObjectAtIndex:0];
    }
    NSValue *value = [NSValue valueWithCGPoint:velocity];
    [self.lastVelocities addObject:value];
}

- (CGPoint)getAveragedVelocity {
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


#if TARGET_OS_IPHONE
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

    // Find touch location
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self.scene];
    
    // Ignore touches outside of scroll node if clipping is on
    if (self.clipContent) {
        CGPoint locationInBounds = [self.scene convertPoint:location toNode:self];
        CGRect frame = CGRectMake(0, 0, self.scrollNodeSize.width, -self.scrollNodeSize.height);
        if (!CGRectContainsPoint(frame, locationInBounds)) {
            return;
        }
    }
    
    // Calculate and apply translation
    CGPoint lastLocation = [touch previousLocationInNode:self.scene];
    CGPoint translation = CGPointSubtract(location, lastLocation);
    CGPoint oldPosition = self.scrollContentNode.position;
    self.scrollContentNode.position = CGPointAdd(self.scrollContentNode.position, translation);

    // Calculate velocity
    NSTimeInterval timeDifferecne = touch.timestamp - self.lastTouchTimestamp;
    self.lastTouchTimestamp = touch.timestamp;
    CGPoint scrollVelocity = CGPointDivideScalar(translation, timeDifferecne);
    [self addVelocityToAverage:scrollVelocity];

    [self applyScrollLimits];
    
    // Inform subclasses and delegate
    [self didScrollFromOffset:oldPosition toOffset:self.scrollContentPosition velocity:[self getAveragedVelocity]];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.scrollingEnabled) return;

    if (event.allTouches.count == touches.count) {
        [self applyScrollOutWithVelocity:[self getAveragedVelocity]];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.scrollingEnabled) return;

    [self applyScrollOutWithVelocity:[self getAveragedVelocity]];
}

#else // OSX
#pragma mark - mouse events

- (void)mouseDown:(NSEvent *)theEvent {
    [self processMouseDown:theEvent];
}

- (void)rightMouseDown:(NSEvent *)theEvent {
    [self processMouseDown:theEvent];
}

- (void)otherMouseDown:(NSEvent *)theEvent {
    [self processMouseDown:theEvent];
}

- (void)processMouseDown:(NSEvent *)theEvent {
    // Track total number of mouse buttons
    self.numberOfMouseButtonsPressed++;

    if (!self.scrollingEnabled) return;

    // Start dragging only for the first pressed button
    if (self.numberOfMouseButtonsPressed == 1) {
        [self stopScrollAnimations];
        
        self.lastTouchTimestamp = theEvent.timestamp;
        self.positionOfLastMouseEvent = [theEvent locationInNode:self];
        [self.lastVelocities removeAllObjects];
    }
}

- (void)mouseDragged:(NSEvent *)theEvent {
    [self processMouseDragged:theEvent];
}

- (void)rightMouseDragged:(NSEvent *)theEvent {
    [self processMouseDragged:theEvent];
}

- (void)otherMouseDragged:(NSEvent *)theEvent {
    [self processMouseDragged:theEvent];
}

- (void)processMouseDragged:(NSEvent *)theEvent {
    if (!self.scrollingEnabled) return;
    
    // Ignore touches outside of scroll node if clipping is on
    CGPoint location = [theEvent locationInNode:self];
    if (self.clipContent) {
        CGRect frame = CGRectMake(0, 0, self.scrollNodeSize.width, -self.scrollNodeSize.height);
        if (!CGRectContainsPoint(frame, location)) {
            return;
        }
    }
    
    // Calculate and apply translation
    CGPoint lastLocation = self.positionOfLastMouseEvent;
    CGPoint translation = CGPointSubtract(location, lastLocation);
    CGPoint oldPosition = self.scrollContentNode.position;
    self.scrollContentNode.position = CGPointAdd(self.scrollContentNode.position, translation);

    // Calculate velocity
    NSTimeInterval timeDifferecne = theEvent.timestamp - self.lastTouchTimestamp;
    CGPoint scrollVelocity = CGPointDivideScalar(translation, timeDifferecne);
    [self addVelocityToAverage:scrollVelocity];

    self.lastTouchTimestamp = theEvent.timestamp;
    self.positionOfLastMouseEvent = location;

    [self applyScrollLimits];
    
    // Inform subclasses and delegate
    [self didScrollFromOffset:oldPosition toOffset:self.scrollContentPosition velocity:[self getAveragedVelocity]];
}

- (void)mouseUp:(NSEvent *)theEvent {
    [self processMouseUp:theEvent];
}

- (void)rightMouseUp:(NSEvent *)theEvent {
    [self processMouseUp:theEvent];
}

- (void)otherMouseUp:(NSEvent *)theEvent {
    [self processMouseUp:theEvent];
}

- (void)processMouseUp:(NSEvent *)theEvent {
    // Track total number of mouse buttons
    self.numberOfMouseButtonsPressed--;

    if (!self.scrollingEnabled) return;
    
    // Apply deceleration only when the last button has been lifted
    if (self.numberOfMouseButtonsPressed == 0) {
        [self applyScrollOutWithVelocity:[self getAveragedVelocity]];
    }
}

#endif


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
