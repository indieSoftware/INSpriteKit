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


@interface INSKButtonNode ()

// A subnode where the visible node*-representations are added to.
@property (nonatomic, strong) SKNode *subnodeLayer;

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
    [self addSubnodesAccordingState];

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
    [self addSubnodesAccordingState];
    
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
    [self addSubnodesAccordingState];
    
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

- (void)setupINSKButton {
    self.userInteractionEnabled = YES;
    
    _enabled = YES;
    _highlighted = NO;
    _selected = NO;
    self.updateSelectedStateAutomatically = NO;
    
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

- (void)addSubnodesAccordingState {
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
    // a replacement for performSelector:withObject:
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


#pragma mark - properties

- (void)setEnabled:(BOOL)enabled {
    if (_enabled == enabled) return;
    
    _enabled = enabled;
    [self addSubnodesAccordingState];
}

- (void)setHighlighted:(BOOL)highlighted {
    if (_highlighted == highlighted) return;
    
    _highlighted = highlighted;
    [self addSubnodesAccordingState];
}

- (void)setSelected:(BOOL)selected {
    if (_selected == selected) return;
    
    _selected = selected;
    [self addSubnodesAccordingState];
}

- (void)setNodeDisabled:(SKNode *)nodeDisabled {
    _nodeDisabled = nodeDisabled;
    [self addSubnodesAccordingState];
}

- (void)setNodeNormal:(SKNode *)nodeNormal {
    _nodeNormal = nodeNormal;
    [self addSubnodesAccordingState];
}

- (void)setNodeHighlighted:(SKNode *)nodeHighlighted {
    _nodeHighlighted = nodeHighlighted;
    [self addSubnodesAccordingState];
}

- (void)setNodeSelectedNormal:(SKNode *)nodeSelectedNormal {
    _nodeSelectedNormal = nodeSelectedNormal;
    [self addSubnodesAccordingState];
}

- (void)setNodeSelectedHighlighted:(SKNode *)nodeSelectedHighlighted {
    _nodeSelectedHighlighted = nodeSelectedHighlighted;
    [self addSubnodesAccordingState];
}


#pragma mark - touch handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.enabled && !self.hidden) {
        self.highlighted = YES;
        [self informTarget:self.touchDownTarget withSelector:self.touchDownSelector];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.enabled && !self.hidden) {
        UITouch *touch = [touches anyObject];
        CGPoint touchPoint = [touch locationInNode:self.parent];
        
        if (CGRectContainsPoint(self.frame, touchPoint)) {
            self.highlighted = YES;
        } else {
            self.highlighted = NO;
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.enabled && !self.hidden) {
        UITouch *touch = [touches anyObject];
        CGPoint touchPoint = [touch locationInNode:self.parent];
        
        self.highlighted = NO;
        if (CGRectContainsPoint(self.frame, touchPoint)) {
            if (self.updateSelectedStateAutomatically) {
                self.selected = !self.selected;
            }
            [self informTarget:self.touchUpInsideTarget withSelector:self.touchUpInsideSelector];
        }
        [self informTarget:self.touchUpTarget withSelector:self.touchUpSelector];
    }
}

@end

