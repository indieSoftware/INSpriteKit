//
//  ViewController.m
//  INSpriteKitExample
//
//  Created by Sven Korset on 09.04.14.
//  Copyright (c) 2014 indie-Software. All rights reserved.
//

#import "ViewController.h"
#import <SpriteKit/SpriteKit.h>


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    skView.showsDrawCount = YES;
    
    // Create and configure the scene.
    Class sceneClass = [[NSBundle mainBundle] classNamed:self.sceneName];
    SKScene *scene = [sceneClass sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];
}


@end
