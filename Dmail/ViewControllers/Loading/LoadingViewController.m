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
#import <GoogleSignIn/GoogleSignIn.h>

@interface LoadingViewController ()<GIDSignInDelegate>

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *indicator;

@end

@implementation LoadingViewController


#pragma mark - Class Methods
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self.indicator startAnimating];
    
    if ([[UserService sharedInstance] userID]) {
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
        [self performSegueWithIdentifier:@"fromLoadingToInbox" sender:self];
    }
}

- (void)signIn:(GIDSignIn *)signIn didDisconnectWithUser:(GIDGoogleUser *)user withError:(NSError *)error {
    
    if (error) {
        //        _signInAuthStatus.text = [NSString stringWithFormat:@"Status: Failed to disconnect: %@", error];
    } else {
        //        _signInAuthStatus.text = [NSString stringWithFormat:@"Status: Disconnected"];
    }
    //    [self reportAuthStatus];
    //    [self updateButtons];
}

- (void)signIn:(GIDSignIn *)signIn presentViewController:(UIViewController *)viewController {
    
}

- (void)signIn:(GIDSignIn *)signIn dismissViewController:(UIViewController *)viewController {
    
}

@end
