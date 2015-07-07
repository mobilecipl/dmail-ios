//
//  LoadingViewController.m
//  Dmail
//
//  Created by Karen Petrosyan on 6/12/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import <GoogleSignIn/GoogleSignIn.h>
#import "LoadingViewController.h"
#import "ProfileService.h"
#import "LoginViewController.h"
#import "MessageService.h"
#import "NetworkManager.h"
#import "SyncService.h"
#import "DAOContact.h"


@interface LoadingViewController ()<GIDSignInDelegate>

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *indicator;

@end

@implementation LoadingViewController


#pragma mark - Class Methods
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self.indicator startAnimating];
    if ([[ProfileService sharedInstance] googleId]) {
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
    googleSignIn.scopes = @[@"https://www.google.com/m8/feeds/", @"https://mail.google.com/"];
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
        [[SyncService sharedInstance] syncGoogleContacts];
        [self performSegueWithIdentifier:@"fromLoadingToRoot" sender:self];
    }
}

@end
