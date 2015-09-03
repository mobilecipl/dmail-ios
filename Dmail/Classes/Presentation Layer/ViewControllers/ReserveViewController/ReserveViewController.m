//
//  ReserveViewController.m
//  Dmail
//
//  Created by Karen Petrosyan on 8/27/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "ReserveViewController.h"

// service
#import "ServiceProfile.h"

// google
#import <GoogleSignIn/GoogleSignIn.h>

@interface ReserveViewController () <GIDSignInDelegate>

@property (nonatomic, strong) ServiceProfile *serviceProfile;

@end

@implementation ReserveViewController

#pragma mark - Class Methods
- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        _serviceProfile = [[ServiceProfile alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}


#pragma mark - Private Methods
- (void)presentSignInViewController:(UIViewController *)viewController {
    
    [self.navigationController pushViewController:viewController animated:YES];
}


#pragma mark - Action Methods
- (IBAction)reserveMySpotClicked:(id)sender {
    
    [self showLoadingView];
    
    [GIDSignInButton class];
    
    GIDSignIn *googleSignIn = [GIDSignIn sharedInstance];
    googleSignIn.scopes = @[@"https://www.google.com/m8/feeds/", @"https://mail.google.com/", @"https://apps-apis.google.com/a/feeds/emailsettings/2.0/"];
    googleSignIn.shouldFetchBasicProfile = YES;
    googleSignIn.allowsSignInWithWebView = NO;
    googleSignIn.delegate = self;
    [googleSignIn signIn];
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
        [self performSegueWithIdentifier:@"fromReserveToQueu" sender:self];
    }
}


@end
