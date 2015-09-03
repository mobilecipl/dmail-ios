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
@property (nonatomic, strong) ServiceProfile *serviceProfile;

@end

@implementation LoginViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        _serviceSync = [[ServiceSync alloc] init];
        _serviceProfile = [[ServiceProfile alloc] init];
    }
    return self;
}

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
        [self showErrorAlertWithTitle:@"Error!" message:@"Unable to sign in to Google. Please try again."];
        return;
    }
    else {
        [self.serviceProfile updateUserDetails:user];
        if (![[NSUserDefaults standardUserDefaults] boolForKey:OnboardingWasShowed]) {
            [self performSegueWithIdentifier:@"fromLoginToOnboarding" sender:self];
        }
        else {
            [self.serviceSync sync];
            [self performSegueWithIdentifier:@"fromLoginToInbox" sender:self];
        }
    }
}

@end
