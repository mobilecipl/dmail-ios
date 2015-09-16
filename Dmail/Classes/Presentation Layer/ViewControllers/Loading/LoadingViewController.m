//
//  LoadingViewController.m
//  Dmail
//
//  Created by Karen Petrosyan on 6/12/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "LoadingViewController.h"
#import "AppDelegate.h"

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
@property (nonatomic, strong) ServiceProfile *serviceProfile;

@end

@implementation LoadingViewController


#pragma mark - Class Methods
- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        _serviceSync = [[ServiceSync alloc] init];
        _serviceProfile = [[ServiceProfile alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self.indicator startAnimating];
    if ([[AppDelegate sharedDelegate].serviceProfilesSyncing hasProfile]) {
        [self autoSignIn];
        [[AppDelegate sharedDelegate].serviceProfilesSyncing sync];
        [self performSegueWithIdentifier:@"fromLoadingToRoot" sender:self];
    }
    else {
        [self performSegueWithIdentifier:@"fromLoadingToLogin" sender:self];
    }
    
//    if ([self.serviceProfilesSyncing hasProfile]) {
//        [self.serviceProfilesSyncing sync];
//    }
//    else {
//        [self performSegueWithIdentifier:@"fromLoadingToLogin" sender:self];
//    }
//    self.serviceProfile = [[ServiceProfile alloc] init];
    
//    if (self.serviceProfile.googleId) {
//        [self autoSignIn];
//    }
//    else {  
//        [self performSegueWithIdentifier:@"fromLoadingToLogin" sender:self];
//    }
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
        [self.serviceProfile updateUserDetails:user];
        [self.serviceSync sync];
        if (![[NSUserDefaults standardUserDefaults] boolForKey:OnboardingWasShowed]) {
            [self performSegueWithIdentifier:@"fromLodaingToOnboarding" sender:self];
        }
        else {
            [self performSegueWithIdentifier:@"fromLoadingToRoot" sender:self];
        }
    }
}

@end
