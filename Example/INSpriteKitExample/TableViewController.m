//
//  TableViewController.m
//  INSpriteKitExample
//
//  Created by Sven Korset on 09.04.14.
//  Copyright (c) 2014 indie-Software. All rights reserved.
//

#import "TableViewController.h"
#import "ViewController.h"


static NSString * const SceneControllerSeque = @"SceneControllerSeque";


@interface TableViewController ()

@property (nonatomic, strong) NSArray *tableContent;

@end


@implementation TableViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self == nil) return self;

    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Scenes" ofType:@"plist"];
    self.tableContent = [NSArray arrayWithContentsOfFile:plistPath];
    
    return self;
}


#pragma mark - Table view delegate & data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableContent.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BasicCell" forIndexPath:indexPath];
    
    cell.textLabel.text = [self.tableContent objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self performSegueWithIdentifier:SceneControllerSeque sender:[self.tableContent objectAtIndex:indexPath.row]];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:SceneControllerSeque]) {
        ViewController *controller = segue.destinationViewController;
        controller.sceneName = sender;
    }
}


@end
