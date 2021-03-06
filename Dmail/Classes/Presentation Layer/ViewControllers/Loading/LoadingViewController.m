//
//  LoadingViewController.m
//  Dmail
//
//  Created by Karen Petrosyan on 6/12/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "LoadingViewController.h"

// controller
#import "LoginViewController.h"

// service
#import "ServiceSync.h"
#import "ServiceProfile.h"

// google
#import <GoogleSignIn/GoogleSignIn.h>

@interface LoadingViewController () <GIDSignInDelegate>

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *indicator;
@property (nonatomic, strong) ServiceSync *serviceSync;

@end

@implementation LoadingViewController


#pragma mark - Class Methods
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self.indicator startAnimating];
    
    if ([[ServiceProfile sharedInstance] googleId]) {
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
    googleSignIn.scopes = @[@"https://www.google.com/m8/feeds/", @"https://mail.google.com/", @"https://apps-apis.google.com/a/feeds/emailsettings/2.0/"];
    googleSignIn.delegate = self;
    [googleSignIn signInSilently];
}


#pragma mark - GIDSignInDelegate Methods
- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    
    [self.indicator stopAnimating];
    if (error) {
        [self showErrorAlertWithTitle:@"Error!" message:@"Unable to sign in to Google. Please try again."];
    }
    else {
        // TODO: sync
        [[ServiceProfile sharedInstance] updateUserDetails:user];
        self.serviceSync = [[ServiceSync alloc] init];
        [self.serviceSync sync];
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"onboardingWasShowed"]) {
            [self performSegueWithIdentifier:@"fromLodaingToOnboarding" sender:self];
        }
        else {
            [self performSegueWithIdentifier:@"fromLoadingToRoot" sender:self];
        }
    }
}

@end
