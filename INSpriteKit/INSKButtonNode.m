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
    if ((self = [super initWithColor:[SKColor clearColor] size:size])) {
        [self initINSKButton];
    }
    return self;
}

- (instancetype)initWithColor:(SKColor *)color size:(CGSize)size {
    if ((self = [super initWithColor:color size:size])) {
        [self initINSKButton];
    }
    return self;
}

- (instancetype)initWithImageNamed:(NSString *)name {
    if ((self = [super initWithImageNamed:name])) {
        [self initINSKButton];
    }
    return self;
}

- (instancetype)initWithTexture:(SKTexture *)texture {
    if ((self = [super initWithTexture:texture])) {
        [self initINSKButton];
    }
    return self;
}

- (instancetype)initWithTexture:(SKTexture *)texture color:(SKColor *)color size:(CGSize)size {
    if ((self = [super initWithTexture:texture color:color size:size])) {
        [self initINSKButton];
    }
    return self;
}

- (void)initINSKButton {
    [self setUserInteractionEnabled:YES];
    
    _enabled = YES;
    _highlighted = NO;
    _selected = NO;
    self.updateSelectedStateAutomatically = NO;
}


#pragma mark - private methods

- (void)removeAllSubnodes {
    [self.nodeDisabled removeFromParent];
    [self.nodeNormal removeFromParent];
    [self.nodeHighlighted removeFromParent];
    [self.nodeSelectedNormal removeFromParent];
    [self.nodeSelectedHighlighted removeFromParent];
}

- (void)updateState {
    [self removeAllSubnodes];
    if (self.isEnabled) {
        if (self.isSelected) {
            if (self.isHighlighted) {
                [self addChildOrNil:self.nodeSelectedHighlighted];
            } else {
                [self addChildOrNil:self.nodeSelectedNormal];
            }
        } else {
            if (self.isHighlighted) {
                [self addChildOrNil:self.nodeHighlighted];
            } else {
                [self addChildOrNil:self.nodeNormal];
            }
        }
    } else {
        [self addChildOrNil:self.nodeDisabled];
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
    [self updateState];
}

- (void)setHighlighted:(BOOL)highlighted {
    if (_highlighted == highlighted) return;
    
    _highlighted = highlighted;
    [self updateState];
}

- (void)setSelected:(BOOL)selected {
    if (_selected == selected) return;
    
    _selected = selected;
    [self updateState];
}

- (void)setNodeDisabled:(SKNode *)nodeDisabled {
    _nodeDisabled = nodeDisabled;
    [self updateState];
}

- (void)setNodeNormal:(SKNode *)nodeNormal {
    _nodeNormal = nodeNormal;
    [self updateState];
}

- (void)setNodeHighlighted:(SKNode *)nodeHighlighted {
    _nodeHighlighted = nodeHighlighted;
    [self updateState];
}

- (void)setNodeSelectedNormal:(SKNode *)nodeSelectedNormal {
    _nodeSelectedNormal = nodeSelectedNormal;
    [self updateState];
}

- (void)setNodeSelectedHighlighted:(SKNode *)nodeSelectedHighlighted {
    _nodeSelectedHighlighted = nodeSelectedHighlighted;
    [self updateState];
}


#pragma mark - touch handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.isEnabled) {
        [self informTarget:self.touchDownTarget withSelector:self.touchDownSelector];
        self.highlighted = YES;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.isEnabled) {
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
    if (self.isEnabled) {
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

