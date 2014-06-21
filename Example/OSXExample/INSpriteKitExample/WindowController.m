// WindowController.m
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


#import "WindowController.h"
#import <SpriteKit/SpriteKit.h>


@interface WindowController () <NSTableViewDataSource, NSTableViewDelegate>

@property (nonatomic, weak) IBOutlet SKView *skView;

@property (nonatomic, strong) NSArray *tableContent;

@end


@implementation WindowController

#pragma mark - private methods

- (void)showSceneNamed:(NSString *)sceneName {
    SKScene *scene = nil;
    if (sceneName != nil) {
        // Create and configure the scene with the size of an iPad.
        Class sceneClass = [[NSBundle mainBundle] classNamed:sceneName];
        scene = [sceneClass sceneWithSize:CGSizeMake(768, 1024)];
        scene.scaleMode = SKSceneScaleModeAspectFit;
    }
    
    [self.skView presentScene:scene];
}


#pragma mark - Table view delegate & data source

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    return self.tableContent.count;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    return [self.tableContent objectAtIndex:rowIndex];
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
    NSTableView *tableView = aNotification.object;
    NSInteger rowIndex = tableView.selectedRow;
    if (rowIndex == -1) {
        // row deselected
        [self showSceneNamed:nil];
    } else {
        // row selected
        NSString *sceneName = [self.tableContent objectAtIndex:rowIndex];
        [self showSceneNamed:sceneName];
    }
}

- (void)tableView:(NSTableView *)tableView didClickTableColumn:(NSTableColumn *)tableColumn {
    self.tableContent = [[self.tableContent reverseObjectEnumerator] allObjects];
    [tableView reloadData];
}


#pragma mark - Window Controller methods

- (id)initWithWindow:(NSWindow *)window {
    self = [super initWithWindow:window];
    if (self == nil) return self;
    
    // Load the plist
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Scenes" ofType:@"plist"];
    self.tableContent = [NSArray arrayWithContentsOfFile:plistPath];
    
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Configure the SKView.
    SKView *skView = self.skView;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    skView.showsDrawCount = YES;
    skView.ignoresSiblingOrder = NO;

    if ([skView isKindOfClass:[INSKView class]]) {
        // Uncomment to support AppKit's default behavior for showing context menus.
        //((INSKView *)skView).deliverRightMouseButtonEventsToScene = NO;
    }
}


@end
