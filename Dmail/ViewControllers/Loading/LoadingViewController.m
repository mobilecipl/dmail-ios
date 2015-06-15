//
//  LoadingViewController.m
//  Dmail
//
//  Created by Karen Petrosyan on 6/12/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "LoadingViewController.h"
#import "UserService.h"
#import "LoginViewController.h"

@interface LoadingViewController ()

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *indicator;

@end

@implementation LoadingViewController


#pragma mark - Class Methods
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self.indicator startAnimating];
    
    [self performSegueWithIdentifier:@"toInboxMessage" sender:self];
//    if ([[UserService sharedInstance] userID]) {
//        [self performSegueWithIdentifier:@"fromLoadingToInbox" sender:self];
//    }
//    else {
//        [self performSegueWithIdentifier:@"fromLoadingToLogin" sender:self];
//    }
}


#pragma mark - Private Methods

@end
