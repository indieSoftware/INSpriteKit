// INSKButton.m
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


#import "INSKButton.h"
#import "SKNode+INExtension.h"
#import <objc/message.h>


@interface INSKButton ()

@property (nonatomic, assign, readwrite) SEL actionTouchUpInside;
@property (nonatomic, weak, readwrite) id targetTouchUpInside;
@property (nonatomic, assign, readwrite) SEL actionTouchDown;
@property (nonatomic, weak, readwrite) id targetTouchDown;
@property (nonatomic, assign, readwrite) SEL actionTouchUp;
@property (nonatomic, weak, readwrite) id targetTouchUp;

@end


@implementation INSKButton

#pragma mark - initializer

+ (INSKButton *)buttonNodeWithSize:(CGSize)size {
    return [[INSKButton alloc] initWithSize:size];
}

- (instancetype)initWithSize:(CGSize)size {
    self = [super initWithColor:[UIColor clearColor] size:size];
    if (self == nil) return self;
    
    [self setUserInteractionEnabled:YES];

    _enabled = YES;
    _highlighted = NO;
    _selected = NO;
    self.updateSelectedStateAutomatically = NO;
    
    return self;
}


#pragma mark - public methods

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


#pragma mark - setting target-action pairs

- (void)setTouchUpInsideTarget:(id)target action:(SEL)action {
    self.targetTouchUpInside = target;
    self.actionTouchUpInside = action;
}

- (void)setTouchDownTarget:(id)target action:(SEL)action {
    self.targetTouchDown = target;
    self.actionTouchDown = action;
}

- (void)setTouchUpTarget:(id)target action:(SEL)action {
    self.targetTouchUp = target;
    self.actionTouchUp = action;
}


#pragma mark - private methods

- (void)removeAllSubnodes {
    [self.nodeDisabled removeFromParent];
    [self.nodeNormal removeFromParent];
    [self.nodeHighlighted removeFromParent];
    [self.nodeSelectedNormal removeFromParent];
    [self.nodeSelectedHighlighted removeFromParent];
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


#pragma mark - touch handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.isEnabled) {
        objc_msgSend(self.targetTouchDown, self.actionTouchDown);
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
            objc_msgSend(self.targetTouchUpInside, self.actionTouchUpInside);
        }
        objc_msgSend(self.targetTouchUp, self.actionTouchUp);
    }
}

@end

