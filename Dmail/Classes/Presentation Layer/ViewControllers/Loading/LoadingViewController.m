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

// model

// google
#import <GoogleSignIn/GoogleSignIn.h>

@interface LoadingViewController () <GIDSignInDelegate>

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *indicator;

@property (nonatomic, strong) ServiceSync *serviceSync;

@end

@implementation LoadingViewController
- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        _serviceSync = [[ServiceSync alloc] init];
    }
    return self;
}

#pragma mark - Class Methods
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self.indicator startAnimating];
    
    // TODO: check if signed in
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
        // TODO: Handle error
    }
    else {
        // TODO: sync
        [[ServiceProfile sharedInstance] updateUserDetails:user];
        [self.serviceSync sync];
        [self performSegueWithIdentifier:@"fromLoadingToRoot" sender:self];
    }
}

@end
