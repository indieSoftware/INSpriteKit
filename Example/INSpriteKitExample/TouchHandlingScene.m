// TouchHandlingScene.m
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


#import "TouchHandlingScene.h"


@interface TouchHandlingScene ()

@property (nonatomic, strong) SKSpriteNode *globalTouchVisualization;
@property (nonatomic, assign) NSUInteger globalTouchesActive;

@end


@implementation TouchHandlingScene

- (id)initWithSize:(CGSize)size {
    self = [super initWithSize:size];
    if (self == nil) return self;
    
    self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
    self.anchorPoint = CGPointMake(0.5, 0.5);
    
    self.globalTouchesActive = 0;
    
    INSKButtonNode *button;
    SKLabelNode *label;
    SKSpriteNode *spriteNode;
    SKNode *layer; // layers are not needed and are only used for debugging purposes


    // Layer 1
    layer = [SKNode node];
    layer.name = @"layer1";
    [self addChild:layer];

    // Info output
    label = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Regular"];
    label.text = @"The red button has a higher touch priority, the green button has a higher zPosition,";
    label.fontSize = 14;
    label.position = CGPointMake(0, (self.size.height/2)-100);
    [layer addChild:label];
    label = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Regular"];
    label.text = @"the blue button is added at last to the tree so they all receive touches before the yellow button.";
    label.fontSize = 14;
    label.position = CGPointMake(0, (self.size.height/2)-130);
    [layer addChild:label];
    
    // Create overlapping buttons
    button = [INSKButtonNode buttonNodeWithColor:[SKColor colorWithRed:1 green:0 blue:0 alpha:0.6] size:CGSizeMake(200, 100)];
    button.position = CGPointMake(-75, (self.size.height/2)-240);
    button.name = @"button1 red";
    button.touchPriority = 1;
    button.nodeHighlighted = [button.nodeNormal copy];
    [button.nodeHighlighted setScale:1.2];
    [button setTouchUpInsideTarget:self selector:@selector(buttonTouchedUpInside:)];
    [layer addChild:button];
    
    button = [INSKButtonNode buttonNodeWithColor:[SKColor colorWithRed:0 green:1 blue:0 alpha:0.6] size:CGSizeMake(200, 100)];
    button.position = CGPointMake(75, (self.size.height/2)-240);
    button.name = @"button1 green";
    button.zPosition = 1;
    button.nodeHighlighted = [button.nodeNormal copy];
    [button.nodeHighlighted setScale:1.2];
    [button setTouchUpInsideTarget:self selector:@selector(buttonTouchedUpInside:)];
    [layer addChild:button];
    
    button = [INSKButtonNode buttonNodeWithColor:[SKColor colorWithRed:1 green:1 blue:0 alpha:0.6] size:CGSizeMake(200, 100)];
    button.position = CGPointMake(0, (self.size.height/2)-270);
    button.name = @"button1 yellow";
    button.nodeHighlighted = [button.nodeNormal copy];
    [button.nodeHighlighted setScale:1.2];
    [button setTouchUpInsideTarget:self selector:@selector(buttonTouchedUpInside:)];
    [layer addChild:button];
    
    button = [INSKButtonNode buttonNodeWithColor:[SKColor colorWithRed:0 green:0 blue:1 alpha:0.6] size:CGSizeMake(200, 100)];
    button.position = CGPointMake(75, (self.size.height/2)-300);
    button.name = @"button1 blue";
    button.nodeHighlighted = [button.nodeNormal copy];
    [button.nodeHighlighted setScale:1.2];
    [button setTouchUpInsideTarget:self selector:@selector(buttonTouchedUpInside:)];
    [layer addChild:button];
    
    
    // Layer 2
    layer = [SKNode node];
    layer.name = @"layer2";
    [self addChild:layer];
    
    // Info output
    label = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Regular"];
    label.text = @"The red and green buttons are overlapped by a white non-interacting SKSpriteNode and a disabled blue button.";
    label.fontSize = 14;
    label.position = CGPointMake(0, (self.size.height/2)-430);
    [layer addChild:label];
    label = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Regular"];
    label.text = @"With a normal SKView a overlapped button will not receive any touches, but with INSKView it will.";
    label.fontSize = 14;
    label.position = CGPointMake(0, (self.size.height/2)-460);
    [layer addChild:label];
    
    SKNode *layerRed = [SKNode node];
    layerRed.name = @"layer2 red";
    [layer addChild:layerRed];
    
    SKNode *layerGreen = [SKNode node];
    layerGreen.name = @"layer2 green";
    [layer addChild:layerGreen];
    
    // Create a button under a SKSpriteNodes and another deeper in the tree
    button = [INSKButtonNode buttonNodeWithColor:[SKColor colorWithRed:1 green:0 blue:0 alpha:0.6] size:CGSizeMake(200, 100)];
    button.position = CGPointMake(-75, (self.size.height/2)-550);
    button.name = @"button2 red";
    button.nodeHighlighted = [button.nodeNormal copy];
    [button.nodeHighlighted setScale:1.2];
    [button setTouchUpInsideTarget:self selector:@selector(buttonTouchedUpInside:)];
    [layerRed addChild:button];
    
    button = [INSKButtonNode buttonNodeWithColor:[SKColor colorWithRed:0 green:1 blue:0 alpha:0.6] size:CGSizeMake(200, 100)];
    button.position = CGPointMake(75, (self.size.height/2)-550);
    button.name = @"button2 green";
    button.nodeHighlighted = [button.nodeNormal copy];
    [button.nodeHighlighted setScale:1.2];
    [button setTouchUpInsideTarget:self selector:@selector(buttonTouchedUpInside:)];
    [layerGreen addChild:button];
    
    button = [INSKButtonNode buttonNodeWithColor:[SKColor colorWithRed:0 green:0 blue:1 alpha:0.6] size:CGSizeMake(200, 100)];
    button.position = CGPointMake(-75, (self.size.height/2)-600);
    button.name = @"button2 blue";
    button.nodeHighlighted = [button.nodeNormal copy];
    [button.nodeHighlighted setScale:1.2];
    [button setTouchUpInsideTarget:self selector:@selector(buttonTouchedUpInside:)];
    button.enabled = NO;
    // Add the blue button to the green layer instead of the red so the non interacting green layer node will overlap the whole red area.
    // With a SKView this will prevent the red button to receive any touches because they will be swallowed by the layer node.
    [layerGreen addChild:button];
    
    // The overlappoing sprite
    spriteNode = [SKSpriteNode spriteNodeWithColor:[SKColor colorWithRed:1 green:1 blue:1 alpha:0.6] size:CGSizeMake(200, 100)];
    spriteNode.name = @"layer2 sprite white";
    spriteNode.position = CGPointMake(75, (self.size.height/2)-600);
    [layer addChild:spriteNode];
    
    
    // Layer 3
    layer = [SKNode node];
    layer.name = @"layer3";
    [self addChild:layer];
    
    // Info output
    label = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Regular"];
    label.text = @"Make sure UIKit still works and a UIButton does not pass touches to Sprite Kit.";
    label.fontSize = 14;
    label.position = CGPointMake(0, (self.size.height/2)-730);
    [layer addChild:label];
    label = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Regular"];
    label.text = @"The green sprite gets scaled by the total number of touches plus those on the scene's background";
    label.fontSize = 14;
    label.position = CGPointMake(0, (self.size.height/2)-760);
    [layer addChild:label];
    label = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Regular"];
    label.text = @"and will change its color when the touch goes down over a button instance.";
    label.fontSize = 14;
    label.position = CGPointMake(0, (self.size.height/2)-790);
    [layer addChild:label];
    
    // Create a button under a UIKit button
    button = [INSKButtonNode buttonNodeWithColor:[SKColor colorWithRed:1 green:0 blue:0 alpha:0.6] size:CGSizeMake(200, 100)];
    button.position = CGPointMake(-100, (self.size.height/2)-880);
    button.name = @"button3";
    button.nodeHighlighted = [button.nodeNormal copy];
    [button.nodeHighlighted setScale:1.2];
    [button setTouchUpInsideTarget:self selector:@selector(buttonTouchedUpInside:)];
    [layer addChild:button];
    
    
    // Create sprite node for the touch observer and background touch visualization
    spriteNode = [SKSpriteNode spriteNodeWithColor:[SKColor colorWithRed:0 green:1 blue:0 alpha:0.6] size:CGSizeMake(50, 50)];
    spriteNode.position = CGPointMake(250, (self.size.height/2)-905);
    [self addChild:spriteNode];
    self.globalTouchVisualization = spriteNode;


    return self;
}

- (void)didMoveToView:(SKView *)view {
    // Add a UIKit button over a INSKButtonNode
    UIButton *uikitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    uikitButton.frame = CGRectMake((self.size.width/2)-100, 850, 200, 100);
    [uikitButton setTitle:@"UIKit button" forState:UIControlStateNormal];
    [uikitButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [uikitButton setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    uikitButton.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.6];
    [view addSubview:uikitButton];
    
    // Add the scene node as global touch observer.
    // Comment out for letting the global sprite only scale when pressing on the scene's background
    // or change the class name of the view to SKView to compare with the default Sprite Kit behavior.
    if ([self.view isKindOfClass:[INSKView class]]) {
        INSKView *touchView = (INSKView *)self.view;
        [touchView addTouchObservingNode:self];
    }
}

- (void)willMoveFromView:(SKView *)view {
    INSKView *touchView = (INSKView *)self.view;
    [touchView removeTouchObservingNode:self];
}

- (void)buttonTouchedUpInside:(INSKButtonNode *)button {
    NSLog(@"'%@' pressed", button.name);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // When added as a global touch observer all touch methods may be called twice
    // first for the observer, second for the scene when touching the background.
    self.globalTouchesActive += touches.count;
    [self.globalTouchVisualization setScale:1 + self.globalTouchesActive * 0.1];
    
    // Check whether the touch will go down over a button
    BOOL buttonWillBeTouched = NO;
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        // Check for class before casting, because the view class may be changed to SKView in the storyboard.
        if ([self.view isKindOfClass:[INSKView class]]) {
            buttonWillBeTouched = [[((INSKView *)self.view) topInteractingNodeAtPosition:location] isKindOfClass:[INSKButtonNode class]];
        }
        if (buttonWillBeTouched) break;
    }
    if (buttonWillBeTouched) {
        self.globalTouchVisualization.color = [SKColor colorWithRed:0 green:1 blue:1 alpha:0.6];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    self.globalTouchesActive -= touches.count;
    [self.globalTouchVisualization setScale:1 + self.globalTouchesActive * 0.1];
    self.globalTouchVisualization.color = [SKColor colorWithRed:0 green:1 blue:0 alpha:0.6];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    self.globalTouchesActive -= touches.count;
    [self.globalTouchVisualization setScale:1 + self.globalTouchesActive * 0.1];
}


@end
