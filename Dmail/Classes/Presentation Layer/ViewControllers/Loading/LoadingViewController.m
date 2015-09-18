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

// GoogleOauth2
#import "GTMOAuth2ViewControllerTouch.h"
#import "GTMOAuth2SignIn.h"
#import "GTMHTTPFetcher.h"


@interface LoadingViewController ()

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *indicator;
@property (nonatomic, strong) ServiceSync *serviceSync;
@property (nonatomic, strong) ServiceProfile *serviceProfile;
@property (nonatomic, retain) GTMOAuth2Authentication *auth;
@property (nonatomic, strong) NSMutableData *data;

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
        [[AppDelegate sharedDelegate].serviceProfilesSyncing sync];
        [self performSegueWithIdentifier:@"fromLoadingToRoot" sender:self];
    }
    else {
        [self performSegueWithIdentifier:@"fromLoadingToLogin" sender:self];
    }
}

@end
