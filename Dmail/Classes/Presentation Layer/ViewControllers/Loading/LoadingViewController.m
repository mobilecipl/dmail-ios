//
//  LoadingViewController.m
//  Dmail
//
//  Created by Karen Petrosyan on 6/12/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import <GoogleSignIn/GoogleSignIn.h>
#import "LoadingViewController.h"
#import "UserService.h"
#import "LoginViewController.h"
#import "MessageService.h"
#import "NetworkManager.h"
#import "SyncService.h"


@interface LoadingViewController ()<GIDSignInDelegate>

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *indicator;

@end

@implementation LoadingViewController


#pragma mark - Class Methods
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self.indicator startAnimating];
    if ([[UserService sharedInstance] gmailId]) {
        [self autoSignIn];
    }
    else {
        [self performSegueWithIdentifier:@"fromLoadingToLogin" sender:self];
    }
}


#pragma mark - Private Methods
- (void)autoSignIn {
    
    [GIDSignInButton class];
    
    GIDSignIn *googleSignIn = [GIDSignIn sharedInstance];
    googleSignIn.shouldFetchBasicProfile = YES;
    googleSignIn.allowsSignInWithWebView = NO;
    googleSignIn.delegate = self;
    [googleSignIn signInSilently];
}


#pragma mark - GIDSignInDelegate Methods
- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    
    [self.indicator stopAnimating];
    if (error) {
        // TO DO Handle error
        return;
    }
    else {
        [[SyncService sharedInstance] getMessageIds];
        [self performSegueWithIdentifier:@"fromLoadingToRoot" sender:self];
    }
}

@end
