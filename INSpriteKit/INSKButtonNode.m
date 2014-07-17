// INSKButtonNode.m
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


#import "INSKButtonNode.h"
#import "SKNode+INExtension.h"
#import "SKSpriteNode+INExtension.h"


@interface INSKButtonNode ()

// A subnode where the visible node*-representations are added to.
@property (nonatomic, strong) SKNode *subnodeLayer;

// The number of touches this button is tracking.
@property (nonatomic, assign) NSUInteger numberOfTouches;
// The number of touches this button is tracking and are currently inside of it's frame.
@property (nonatomic, assign) NSUInteger numberOfTouchesInside;
// The last mouse event's position. OS X only.
@property (nonatomic, assign) CGPoint positionOfLastMouseEvent;

// The touch targets and their selectors.
@property (nonatomic, assign, readwrite) SEL touchUpInsideSelector;
@property (nonatomic, weak, readwrite) id touchUpInsideTarget;
@property (nonatomic, assign, readwrite) SEL touchDownSelector;
@property (nonatomic, weak, readwrite) id touchDownTarget;
@property (nonatomic, assign, readwrite) SEL touchUpSelector;
@property (nonatomic, weak, readwrite) id touchUpTarget;

@end


@implementation INSKButtonNode

#pragma mark - initializer

+ (instancetype)buttonNodeWithSize:(CGSize)size {
    return [[self alloc] initWithSize:size];
}

- (instancetype)initWithSize:(CGSize)size {
    self = [super initWithColor:[SKColor clearColor] size:size];
    if (self == nil) return self;
    
    [self setupINSKButton];

    return self;
}

+ (instancetype)buttonNodeWithColor:(SKColor *)color size:(CGSize)size {
    return [[self alloc] initWithColor:color size:size];
}

- (instancetype)initWithColor:(SKColor *)color size:(CGSize)size {
    self = [self initWithSize:size];
    if (self == nil) return self;
    
    SKSpriteNode *spriteNode = [SKSpriteNode spriteNodeWithColor:color size:size];
    spriteNode.name = @"INSKButtonNodeDefaultRepresentation"; // only for debugging
    _nodeNormal = spriteNode;
    _nodeHighlighted = spriteNode;
    _nodeSelectedNormal = spriteNode;
    _nodeSelectedHighlighted = spriteNode;
    _nodeDisabled = spriteNode;
    [self updateSubnodes];

    return self;
}

+ (instancetype)buttonNodeWithImageNamed:(NSString *)imageName {
    return [[self alloc] initWithImageNamed:imageName];
}

- (instancetype)initWithImageNamed:(NSString *)imageName {
    self = [self initWithSize:CGSizeZero];
    if (self == nil) return self;
    
    SKSpriteNode *spriteNode = [SKSpriteNode spriteNodeWithImageNamed:imageName];
    spriteNode.name = @"INSKButtonNodeDefaultRepresentation"; // only for debugging
    self.size = spriteNode.size;
    _nodeNormal = spriteNode;
    _nodeHighlighted = spriteNode;
    _nodeSelectedNormal = spriteNode;
    _nodeSelectedHighlighted = spriteNode;
    _nodeDisabled = spriteNode;
    [self updateSubnodes];
    
    return self;
}

+ (instancetype)buttonNodeWithImageNamed:(NSString *)imageName highlightImageNamed:(NSString *)highlightImageName {
    return [[self alloc] initWithImageNamed:imageName highlightImageNamed:highlightImageName];
}

- (instancetype)initWithImageNamed:(NSString *)imageName highlightImageNamed:(NSString *)highlightImageName {
    self = [self initWithSize:CGSizeZero];
    if (self == nil) return self;
    
    SKSpriteNode *normalSprite = [SKSpriteNode spriteNodeWithImageNamed:imageName];
    normalSprite.name = @"INSKButtonNodeDefaultRepresentation"; // only for debugging
    SKSpriteNode *highlightedSprite = [SKSpriteNode spriteNodeWithImageNamed:highlightImageName];
    highlightedSprite.name = @"INSKButtonNodeDefaultRepresentation"; // only for debugging
    self.size = normalSprite.size;
    _nodeNormal = normalSprite;
    _nodeHighlighted = highlightedSprite;
    _nodeSelectedNormal = highlightedSprite;
    _nodeSelectedHighlighted = normalSprite;
    _nodeDisabled = normalSprite;
    [self updateSubnodes];
    
    return self;
}

- (instancetype)initWithTexture:(SKTexture *)texture {
    self = [super initWithTexture:texture];
    if (self == nil) return self;
    
    [self setupINSKButton];

    return self;
}

- (instancetype)initWithTexture:(SKTexture *)texture color:(SKColor *)color size:(CGSize)size {
    self = [super initWithTexture:texture color:color size:size];
    if (self == nil) return self;
    
    [self setupINSKButton];

    return self;
}

+ (instancetype)buttonNodeWithToggleImageNamed:(NSString *)imageName highlightImageNamed:(NSString *)highlightImageName selectedImageNamed:(NSString *)selectedImageName selectedHighlightImageNamed:(NSString *)selectedHighlightImageName {
    return [[self alloc] initWithToggleImageNamed:imageName highlightImageNamed:highlightImageName selectedImageNamed:selectedImageName selectedHighlightImageNamed:selectedHighlightImageName];
}

- (instancetype)initWithToggleImageNamed:(NSString *)imageName highlightImageNamed:(NSString *)highlightImageName selectedImageNamed:(NSString *)selectedImageName selectedHighlightImageNamed:(NSString *)selectedHighlightImageName {
    self = [self initWithSize:CGSizeZero];
    if (self == nil) return self;
    
    _nodeNormal = [SKSpriteNode spriteNodeWithImageNamed:imageName];
    _nodeNormal.name = @"INSKButtonNodeDefaultRepresentationNormal"; // only for debugging
    _nodeHighlighted = [SKSpriteNode spriteNodeWithImageNamed:highlightImageName];
    _nodeHighlighted.name = @"INSKButtonNodeDefaultRepresentationHighlighted"; // only for debugging
    _nodeSelectedNormal = [SKSpriteNode spriteNodeWithImageNamed:selectedImageName];
    _nodeSelectedNormal.name = @"INSKButtonNodeDefaultRepresentationSelected"; // only for debugging
    _nodeSelectedHighlighted = [SKSpriteNode spriteNodeWithImageNamed:selectedHighlightImageName];
    _nodeSelectedHighlighted.name = @"INSKButtonNodeDefaultRepresentationSelectedHighlighted"; // only for debugging
    _nodeDisabled = _nodeNormal;

    self.size = ((SKSpriteNode *)_nodeNormal).size;
    self.updateSelectedStateAutomatically = YES;

    [self updateSubnodes];

    return self;
}

+ (instancetype)buttonNodeWithTitle:(NSString *)title fontSize:(CGFloat)fontSize {
    return [[self alloc] initWithTitle:title fontSize:fontSize];
}

- (instancetype)initWithTitle:(NSString *)title fontSize:(CGFloat)fontSize {
    // get title size, add some border and use it as button size
    SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Regular"];
    label.text = title;
    if (fontSize > 0.0) {
        label.fontSize = fontSize;
    }
    CGSize titleSize = label.frame.size;
    titleSize.width += 20;
    titleSize.height += 20;
    self = [self initWithSize:titleSize];
    if (self == nil) return self;

    // normale state
    label.color = [SKColor blackColor];
    label.colorBlendFactor = 1;
    label.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;

    SKSpriteNode *labelBackground = [SKSpriteNode spriteNodeWithColor:[SKColor whiteColor] size:titleSize];
    labelBackground.name = @"INSKButtonNodeDefaultRepresentation"; // only for debugging
    [labelBackground addChild:label];
    _nodeNormal = labelBackground;
    
    // highlight state
    SKLabelNode *highlightLabel = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Regular"];
    highlightLabel.text = title;
    if (fontSize > 0.0) {
        highlightLabel.fontSize = fontSize;
    }
    highlightLabel.color = [SKColor blackColor];
    highlightLabel.colorBlendFactor = 1;
    highlightLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;

    SKSpriteNode *highlightBackground = [SKSpriteNode spriteNodeWithColor:[SKColor lightGrayColor] size:titleSize];
    highlightBackground.name = @"INSKButtonNodeDefaultRepresentation"; // only for debugging
    [highlightBackground addChild:highlightLabel];
    _nodeHighlighted = highlightBackground;

    // disabled state
    SKLabelNode *disabledLabel = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Regular"];
    disabledLabel.text = title;
    if (fontSize > 0.0) {
        disabledLabel.fontSize = fontSize;
    }
    disabledLabel.color = [SKColor whiteColor];
    disabledLabel.colorBlendFactor = 1;
    disabledLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    
    SKSpriteNode *disabledBackground = [SKSpriteNode spriteNodeWithColor:[SKColor darkGrayColor] size:titleSize];
    disabledBackground.name = @"INSKButtonNodeDefaultRepresentation"; // only for debugging
    [disabledBackground addChild:disabledLabel];
    _nodeDisabled = disabledBackground;
    
    [self updateSubnodes];
    
    return self;
}

- (void)setupINSKButton {
    self.userInteractionEnabled = YES;
    
    _enabled = YES;
    _highlighted = NO;
    _selected = NO;
    self.updateSelectedStateAutomatically = NO;
    self.numberOfTouches = 0;
    self.numberOfTouchesInside = 0;
    
    self.subnodeLayer = [SKNode node];
    self.subnodeLayer.name = @"INSKButtonNodeSubnodeLayer"; // only for debugging
    [self addChild:self.subnodeLayer];
}


#pragma mark - private methods

- (void)removeAllSubnodes {
    [self.nodeDisabled removeFromParent];
    [self.nodeNormal removeFromParent];
    [self.nodeHighlighted removeFromParent];
    [self.nodeSelectedNormal removeFromParent];
    [self.nodeSelectedHighlighted removeFromParent];
}

- (void)updateSubnodes {
    [self removeAllSubnodes];
    if (self.enabled) {
        if (self.selected) {
            if (self.highlighted) {
                [self.subnodeLayer addChildOrNil:self.nodeSelectedHighlighted];
            } else {
                [self.subnodeLayer addChildOrNil:self.nodeSelectedNormal];
            }
        } else {
            if (self.highlighted) {
                [self.subnodeLayer addChildOrNil:self.nodeHighlighted];
            } else {
                [self.subnodeLayer addChildOrNil:self.nodeNormal];
            }
        }
    } else {
        [self.subnodeLayer addChildOrNil:self.nodeDisabled];
    }
}

- (void)informTarget:(id)target withSelector:(SEL)selector {
    // A replacement for performSelector:withObject:
    NSMethodSignature *methodSig = [[target class] instanceMethodSignatureForSelector:selector];
    if (methodSig != nil) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
        invocation.target = target;
        invocation.selector = selector;
        if (methodSig.numberOfArguments == 3) {
            INSKButtonNode *caller = self;
            [invocation setArgument:&caller atIndex:2];
        }
        [invocation invoke];
    }
}


#pragma mark - properties

- (void)setEnabled:(BOOL)enabled {
    if (_enabled == enabled) return;
    
    _enabled = enabled;
    self.userInteractionEnabled = enabled;
    if (!enabled) {
        _highlighted = NO;
    }
    [self updateSubnodes];
}

- (void)setHighlighted:(BOOL)highlighted {
    if (_highlighted == highlighted) return;
    
    _highlighted = highlighted;
    [self updateSubnodes];
}

- (void)setSelected:(BOOL)selected {
    if (_selected == selected) return;
    
    _selected = selected;
    [self updateSubnodes];
}

- (void)setNodeDisabled:(SKNode *)nodeDisabled {
    _nodeDisabled = nodeDisabled;
    [self updateSubnodes];
}

- (void)setNodeNormal:(SKNode *)nodeNormal {
    _nodeNormal = nodeNormal;
    [self updateSubnodes];
}

- (void)setNodeHighlighted:(SKNode *)nodeHighlighted {
    _nodeHighlighted = nodeHighlighted;
    [self updateSubnodes];
}

- (void)setNodeSelectedNormal:(SKNode *)nodeSelectedNormal {
    _nodeSelectedNormal = nodeSelectedNormal;
    [self updateSubnodes];
}

- (void)setNodeSelectedHighlighted:(SKNode *)nodeSelectedHighlighted {
    _nodeSelectedHighlighted = nodeSelectedHighlighted;
    [self updateSubnodes];
}


#pragma mark - setting target-selector pairs

- (void)setTouchUpInsideTarget:(id)target selector:(SEL)selector {
    self.touchUpInsideTarget = target;
    self.touchUpInsideSelector = selector;
}

- (void)setTouchDownTarget:(id)target selector:(SEL)selector {
    self.touchDownTarget = target;
    self.touchDownSelector = selector;
}

- (void)setTouchUpTarget:(id)target selector:(SEL)selector {
    self.touchUpTarget = target;
    self.touchUpSelector = selector;
}


#if TARGET_OS_IPHONE
#pragma mark - touch handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // Update detected touches
    self.numberOfTouches += touches.count;
    for (UITouch *touch in touches) {
        CGPoint touchPoint = [touch locationInNode:self];
        if ([self isPointInside:touchPoint]) {
            self.numberOfTouchesInside++;
        }
    }

    // Update state for first touch only
    if (self.enabled && self.numberOfTouches == touches.count) {
        BOOL touchInside = self.numberOfTouchesInside > 0;
        self.highlighted = touchInside;
        if ([self.inskButtonNodeDelegate respondsToSelector:@selector(buttonNode:touchUp:inside:)]) {
            [self.inskButtonNodeDelegate buttonNode:self touchUp:NO inside:touchInside];
        }
        [self informTarget:self.touchDownTarget withSelector:self.touchDownSelector];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    // Update detected touches
    for (UITouch *touch in touches) {
        CGPoint oldTouchPoint = [touch previousLocationInNode:self];
        CGPoint newTouchPoint = [touch locationInNode:self];
        BOOL wasInside = [self isPointInside:oldTouchPoint];
        BOOL isInside = [self isPointInside:newTouchPoint];
        if (wasInside && !isInside) {
            self.numberOfTouchesInside--;
        } else if (!wasInside && isInside) {
            self.numberOfTouchesInside++;
        }
    }
    
    // Update state
    if (self.enabled) {
        BOOL oldHighlightedState = self.highlighted;
        if (self.numberOfTouchesInside > 0) {
            self.highlighted = YES;
        } else {
            self.highlighted = NO;
        }
        if (oldHighlightedState != self.highlighted) {
            if ([self.inskButtonNodeDelegate respondsToSelector:@selector(buttonNode:touchMoveUpdatesHighlightState:)]) {
                [self.inskButtonNodeDelegate buttonNode:self touchMoveUpdatesHighlightState:self.highlighted];
            }
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // Update detected touches
    BOOL lastTouchWasInside = self.numberOfTouchesInside > 0;
    self.numberOfTouches -= touches.count;
    for (UITouch *touch in touches) {
        CGPoint touchPoint = [touch locationInNode:self];
        if ([self isPointInside:touchPoint]) {
            self.numberOfTouchesInside--;
        }
    }
    
    // Update state for last touch only
    if (self.enabled && self.numberOfTouches == 0) {
        self.highlighted = NO;
        if (lastTouchWasInside) {
            if (self.updateSelectedStateAutomatically) {
                self.selected = !self.selected;
            }
            if ([self.inskButtonNodeDelegate respondsToSelector:@selector(buttonNode:touchUp:inside:)]) {
                [self.inskButtonNodeDelegate buttonNode:self touchUp:YES inside:YES];
            }
            [self informTarget:self.touchUpInsideTarget withSelector:self.touchUpInsideSelector];
        } else {
            if ([self.inskButtonNodeDelegate respondsToSelector:@selector(buttonNode:touchUp:inside:)]) {
                [self.inskButtonNodeDelegate buttonNode:self touchUp:YES inside:NO];
            }
        }
        [self informTarget:self.touchUpTarget withSelector:self.touchUpSelector];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    // Update detected touches
    self.numberOfTouches -= touches.count;
    for (UITouch *touch in touches) {
        CGPoint touchPoint = [touch locationInNode:self];
        if ([self isPointInside:touchPoint]) {
            self.numberOfTouchesInside--;
        }
    }

    if (self.enabled) {
        self.highlighted = NO;
        if ([self.inskButtonNodeDelegate respondsToSelector:@selector(buttonNodeTouchCancelled:)]) {
            [self.inskButtonNodeDelegate buttonNodeTouchCancelled:self];
        }
    }
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
    // Update detected touches
    self.numberOfTouches++;
    self.positionOfLastMouseEvent = [theEvent locationInNode:self];
    if ([self isPointInside:self.positionOfLastMouseEvent]) {
        self.numberOfTouchesInside = 1;
    } else {
        self.numberOfTouchesInside = 0;
    }

    // Update state for first touch only
    if (self.enabled && self.numberOfTouches == 1) {
        BOOL touchInside = self.numberOfTouchesInside > 0;
        self.highlighted = touchInside;
        if ([self.inskButtonNodeDelegate respondsToSelector:@selector(buttonNode:touchUp:inside:)]) {
            [self.inskButtonNodeDelegate buttonNode:self touchUp:NO inside:touchInside];
        }
        [self informTarget:self.touchDownTarget withSelector:self.touchDownSelector];
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
    // Update detected touches
    self.positionOfLastMouseEvent = [theEvent locationInNode:self];
    if ([self isPointInside:self.positionOfLastMouseEvent]) {
        self.numberOfTouchesInside = 1;
    } else {
        self.numberOfTouchesInside = 0;
    }
    
    // Update state
    if (self.enabled) {
        BOOL oldHighlightedState = self.highlighted;
        if (self.numberOfTouchesInside > 0) {
            self.highlighted = YES;
        } else {
            self.highlighted = NO;
        }
        if (oldHighlightedState != self.highlighted) {
            if ([self.inskButtonNodeDelegate respondsToSelector:@selector(buttonNode:touchMoveUpdatesHighlightState:)]) {
                [self.inskButtonNodeDelegate buttonNode:self touchMoveUpdatesHighlightState:self.highlighted];
            }
        }
    }
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
    // Update detected touches
    BOOL lastTouchWasInside = self.numberOfTouchesInside > 0;
    self.numberOfTouches--;
    if (self.numberOfTouches == 0) {
        self.numberOfTouchesInside = 0;
    }
    self.positionOfLastMouseEvent = [theEvent locationInNode:self];
    
    // Update state for last touch only
    if (self.enabled && self.numberOfTouches == 0) {
        self.highlighted = NO;
        if (lastTouchWasInside) {
            if (self.updateSelectedStateAutomatically) {
                self.selected = !self.selected;
            }
            if ([self.inskButtonNodeDelegate respondsToSelector:@selector(buttonNode:touchUp:inside:)]) {
                [self.inskButtonNodeDelegate buttonNode:self touchUp:YES inside:YES];
            }
            [self informTarget:self.touchUpInsideTarget withSelector:self.touchUpInsideSelector];
        } else {
            if ([self.inskButtonNodeDelegate respondsToSelector:@selector(buttonNode:touchUp:inside:)]) {
                [self.inskButtonNodeDelegate buttonNode:self touchUp:YES inside:NO];
            }
        }
        [self informTarget:self.touchUpTarget withSelector:self.touchUpSelector];
    }
}

#endif // OS X


@end

