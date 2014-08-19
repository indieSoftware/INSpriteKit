// TouchHandlingScene2.m
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


#import "TouchHandlingScene2.h"


// The alpha value for all buttons in the scene.
static CGFloat const ButtonAlpha = 1.0;
// The alpha value for the sprites in the scene.
static CGFloat const SpriteAlpha = 0.4;


@interface TouchHandlingScene2 () <INSKButtonNodeDelegate>

@property (nonatomic, strong) SKSpriteNode *globalTouchVisualization;

@end


@implementation TouchHandlingScene2

- (id)initWithSize:(CGSize)size {
    self = [super initWithSize:size];
    if (self == nil) return self;
    
    self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
    self.anchorPoint = CGPointMake(0.5, 0.5);
    
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
    label.text = @"The white view is added as a child to the red button. When using SKView the child will extend the";
    label.fontSize = 14;
    label.position = CGPointMake(0, (self.size.height/2)-100);
    [layer addChild:label];
    label = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Regular"];
    label.text = @"button's touch receiving area, but INSKView will take only the button's frame without any children.";
    label.fontSize = 14;
    label.position = CGPointMake(0, (self.size.height/2)-130);
    [layer addChild:label];
    
    // Create overlapped button
    button = [INSKButtonNode buttonNodeWithColor:[SKColor colorWithRed:1 green:0 blue:0 alpha:ButtonAlpha] size:CGSizeMake(200, 100)];
    button.position = CGPointMake(0, (self.size.height/2)-260);
    button.name = @"button1 red";
    button.nodeHighlighted = [button.nodeNormal copy];
    button.nodeHighlighted.xScale = 2;
    button.nodeHighlighted.yScale = 1.2;
    button.inskButtonNodeDelegate = self;
    [layer addChild:button];
    
    // A child sprite
    spriteNode = [SKSpriteNode spriteNodeWithColor:[SKColor colorWithRed:1 green:1 blue:1 alpha:SpriteAlpha] size:CGSizeMake(300, 200)];
    spriteNode.name = @"sprite1 white";
    [button addChild:spriteNode];

    
    // Layer 2
    layer = [SKNode node];
    layer.name = @"layer2";
    [self addChild:layer];
    
    // Info output
    label = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Regular"];
    label.text = @"The green button is rotated so the button's frame is extended which is visualized by a white background sprite.";
    label.fontSize = 14;
    label.position = CGPointMake(0, (self.size.height/2)-430);
    [layer addChild:label];
    label = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Regular"];
    label.text = @"SKView uses the extended frame for touch detection, but INSKView uses the rotated frame of SKSpriteNodes.";
    label.fontSize = 14;
    label.position = CGPointMake(0, (self.size.height/2)-460);
    [layer addChild:label];
    
    // Create rotated button
    button = [INSKButtonNode buttonNodeWithColor:[SKColor colorWithRed:0 green:1 blue:0 alpha:ButtonAlpha] size:CGSizeMake(200, 100)];
    button.position = CGPointMake(0, (self.size.height/2)-600);
    button.zRotation = DegreesToRadians(-45);
    button.name = @"green2 red";
    button.nodeHighlighted = [button.nodeNormal copy];
    [button.nodeHighlighted setScale:1.2];
    button.inskButtonNodeDelegate = self;
    [layer addChild:button];
    
    // The background sprite for the a visual border
    spriteNode = [SKSpriteNode spriteNodeWithColor:[SKColor colorWithRed:1 green:1 blue:1 alpha:SpriteAlpha] size:button.frame.size];
    spriteNode.name = @"sprite2 white";
    spriteNode.position = button.position;
    spriteNode.zPosition = -1;
    [layer addChild:spriteNode];
    
    
    // Info output
    label = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Regular"];
    label.text = @"The blue sprite is scaled when a button receives a touch. However, the state is also logged to the console.";
    label.fontSize = 14;
    label.position = CGPointMake(0, (self.size.height/2)-780);
    [self addChild:label];

    label = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Regular"];
    label.text = @"You may change the class name from INSKView to SKView in the Storyboard/Xib-File to see the differences.";
    label.fontSize = 14;
    label.position = CGPointMake(0, (self.size.height/2)-810);
    [self addChild:label];
    
    // Create a sprite node for the button delegate visualization
    spriteNode = [SKSpriteNode spriteNodeWithColor:[SKColor colorWithRed:0 green:0 blue:1 alpha:ButtonAlpha] size:CGSizeMake(200, 100)];
    spriteNode.position = CGPointMake(0, (self.size.height/2)-885);
    [self addChild:spriteNode];
    self.globalTouchVisualization = spriteNode;

    
    return self;
}

- (void)buttonNode:(INSKButtonNode *)button touchUp:(BOOL)touchUp inside:(BOOL)touchInside {
    NSLog(@"button: %@  %@ %@", button.name, (touchUp ? @"up" : @"down"), (touchInside ? @"inside" : @"outside"));
    
    if (touchUp) {
        [self.globalTouchVisualization setScale:1];
    } else {
        [self.globalTouchVisualization setScale:1.2];
    }
}


@end
