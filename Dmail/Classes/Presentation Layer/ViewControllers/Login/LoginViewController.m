//
//  LoginViewController.m
//  Dmail
//
//  Created by Karen Petrosyan on 6/12/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "LoginViewController.h"
#import <GoogleSignIn/GoogleSignIn.h>
#import "UserService.h"
#import "SyncService.h"


@interface LoginViewController ()<GIDSignInDelegate>

@end

@implementation LoginViewController


#pragma mark - Class Methods
- (void)viewDidLoad {
    
    [super viewDidLoad];
}


#pragma mark - IBAction Methods
- (IBAction)gmailLoginClicked:(id)sender {
    
    [self showLoadingView];

    [GIDSignInButton class];
    
    GIDSignIn *googleSignIn = [GIDSignIn sharedInstance];
    googleSignIn.shouldFetchBasicProfile = YES;
    googleSignIn.allowsSignInWithWebView = NO;
    googleSignIn.delegate = self;
    [googleSignIn signIn];
}


#pragma mark - Private Methods
- (void)presentSignInViewController:(UIViewController *)viewController {
    
    [self.navigationController pushViewController:viewController animated:YES];
}


#pragma mark - GIDSignInDelegate Methods
- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    
    [self hideLoadingView];
    if (error) {
        // TO DO Handle error
        return;
    }
    else {
        [[UserService sharedInstance] updateUserDetails:user];
        [[SyncService sharedInstance] getMessageIds];
        [self performSegueWithIdentifier:@"fromLoginToRoot" sender:self];
    }
}

@end