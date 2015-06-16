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
#import "MessageService.h"

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
        NSString *gmailUniqueId = @"7BC73A54-84F6-4C09-B5C1-ECE268C44DD5@science-inc.com";
        [[MessageService sharedInstance] getMessageFromGmailWithGmailUniqueId:gmailUniqueId withCompletionBlock:^(BOOL success, NSError *error) {
            
        }];
//        [self performSegueWithIdentifier:@"fromLoadingToInbox" sender:self];
    }
}

- (void)signIn:(GIDSignIn *)signIn didDisconnectWithUser:(GIDGoogleUser *)user withError:(NSError *)error {
    
    if (error) {
        
    } else {
        
    }
}

- (void)signIn:(GIDSignIn *)signIn presentViewController:(UIViewController *)viewController {
    
}

- (void)signIn:(GIDSignIn *)signIn dismissViewController:(UIViewController *)viewController {
    
}

@end
