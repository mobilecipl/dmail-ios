//
//  LoginViewController.m
//  Dmail
//
//  Created by Karen Petrosyan on 6/12/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "LoginViewController.h"

// service
#import "ServiceProfile.h"
#import "ServiceSync.h"

// google
#import <GoogleSignIn/GoogleSignIn.h>

@interface LoginViewController () <GIDSignInDelegate>

@property (nonatomic, strong) ServiceSync *serviceSync;

@end

@implementation LoginViewController

#pragma mark - IBAction Methods
- (IBAction)gmailLoginClicked:(id)sender {
    
    [self showLoadingView];

    [GIDSignInButton class];
    
    GIDSignIn *googleSignIn = [GIDSignIn sharedInstance];
    googleSignIn.scopes = @[@"https://www.google.com/m8/feeds/", @"https://mail.google.com/", @"https://apps-apis.google.com/a/feeds/emailsettings/2.0/"];
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
        [[ServiceProfile sharedInstance] updateUserDetails:user];
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"onboardingWasShowed"]) {
            [self performSegueWithIdentifier:@"fromLoginToOnboarding" sender:self];
        }
        else {
            self.serviceSync = [[ServiceSync alloc] init];
            [self.serviceSync sync];
            [self performSegueWithIdentifier:@"fromLoginToInbox" sender:self];
        }
    }
}

@end
