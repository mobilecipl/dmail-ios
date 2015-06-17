//
//  InboxViewController.m
//  Dmail
//
//  Created by Gevorg Ghukasyan on 6/12/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "InboxViewController.h"
#import "Configurations.h"
#import "ComposeViewController.h"


@interface InboxViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableVIewInbox;

@end

@implementation InboxViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
}

- (IBAction)buttonHandlerMenu:(id)sender {
    
    NSLog(@"Menu selected");
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMenuButton object:nil];
}

- (IBAction)buttonHandlerCompose:(id)sender {
    
    [self performSegueWithIdentifier:@"fromInboxToCompose" sender:self];
}

@end
