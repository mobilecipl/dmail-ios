//
//  GmailService.m
//  Dmail
//
//  Created by Karen Petrosyan on 6/15/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "GmailService.h"

@interface GmailService ()

@property (nonatomic, strong) GIDSignIn *googleSignIn;

@end

@implementation GmailService


#pragma mark - Public Methods
- (id)init {
    
    self = [super init];
    if (self != nil) {

    }
    
    return  self;
}

- (void)gmailSignIn {
    
    [GIDSignInButton class];
    
    self.googleSignIn = [GIDSignIn sharedInstance];
    self.googleSignIn.shouldFetchBasicProfile = YES;
    self.googleSignIn.allowsSignInWithWebView = NO;
    self.googleSignIn.delegate = self;
    [self.googleSignIn signIn];
}


#pragma mark - GIDSignInDelegate Methods
- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    
    if (error) {
        // TO DO Handle error
        return;
    }
    else {
        if ([self.delegate respondsToSelector:@selector(gmailSignedInWithUser:)]) {
            [self.delegate gmailSignedInWithUser:user];
        }
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
