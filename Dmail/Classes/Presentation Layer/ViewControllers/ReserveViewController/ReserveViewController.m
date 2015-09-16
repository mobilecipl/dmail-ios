//
//  ReserveViewController.m
//  Dmail
//
//  Created by Karen Petrosyan on 8/27/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "ReserveViewController.h"
#import "AppDelegate.h"

// service
#import "ServiceProfile.h"

// google
#import "GoogleOAuth.h"
#import <GoogleSignIn/GoogleSignIn.h>

@interface ReserveViewController () <GoogleOAuthDelegate, GIDSignInDelegate, GIDSignInUIDelegate>

@property (nonatomic, strong) ServiceProfile *serviceProfile;
@property (nonatomic, strong) GoogleOAuth *googleOAuth;

@property (nonatomic, strong) NSMutableArray *arrProfileInfo;
@property (nonatomic, strong) NSMutableArray *arrProfileInfoLabel;

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

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Private Methods
- (void)presentSignInViewController:(UIViewController *)viewController {
    
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)appWillEnterForeground:(NSNotification *)notification {
    
    [self hideLoadingView];
}


#pragma mark - Action Methods
- (IBAction)reserveMySpotClicked:(id)sender {
    
    [self showLoadingView];
    
//    self.googleOAuth = [[GoogleOAuth alloc] initWithFrame:self.view.frame];
//    [self.googleOAuth setGOAuthDelegate:self];
//    [self.googleOAuth authorizeUserWithClienID:kGoogleClientID
//                           andClientSecret:kGoogleClientSecret
//                             andParentView:self.view
//                                 andScopes:@[@"https://www.google.com/m8/feeds/", @"https://mail.google.com/", @"https://apps-apis.google.com/a/feeds/emailsettings/2.0/"]
//     ];
    
    [GIDSignInButton class];
    GIDSignIn *googleSignIn = [GIDSignIn sharedInstance];
    googleSignIn.scopes = @[@"https://www.google.com/m8/feeds/", @"https://mail.google.com/", @"https://apps-apis.google.com/a/feeds/emailsettings/2.0/"];
    googleSignIn.clientID = kGoogleClientID;
    googleSignIn.shouldFetchBasicProfile = YES;
    googleSignIn.allowsSignInWithWebView = NO;
    googleSignIn.delegate = self;
    [googleSignIn signIn];
}


#pragma mark - GoogleOAuth Delegate methods
- (void)authorizationWasSuccessful {
    
//    [self.googleOAuth callAPI:@"https://www.googleapis.com/oauth2/v1/userinfo" withHttpMethod:httpMethod_GET postParameterNames:nil postParameterValues:nil];
    [self.googleOAuth callAPI:@"https://mail.google.com" withHttpMethod:httpMethod_GET postParameterNames:nil postParameterValues:nil];
}


- (void)accessTokenWasRevoked {
    
    [self showErrorAlertWithTitle:@"Error!" message:@"Your access was revoked!"];
}

- (void)responseFromServiceWasReceived:(NSString *)responseJSONAsString andResponseJSONAsData:(NSData *)responseJSONAsData {
    
    [self hideLoadingView];
    if ([responseJSONAsString rangeOfString:@"family_name"].location != NSNotFound) {
        NSError *error;
        NSMutableDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:responseJSONAsData options:NSJSONReadingMutableContainers error:&error];
        if (error) {
            NSLog(@"An error occured while converting JSON data to dictionary.");
            return;
        }
        else{
            if (_arrProfileInfoLabel != nil) {
                _arrProfileInfoLabel = nil;
                _arrProfileInfo = nil;
                _arrProfileInfo = [[NSMutableArray alloc] init];
            }
            
            _arrProfileInfoLabel = [[NSMutableArray alloc] initWithArray:[dictionary allKeys] copyItems:YES];
            for (int i=0; i<[_arrProfileInfoLabel count]; i++) {
                [_arrProfileInfo addObject:[dictionary objectForKey:[_arrProfileInfoLabel objectAtIndex:i]]];
            }
        }
        NSLog(@"_arrProfileInfo === %@", _arrProfileInfo);
    }
}


-(void)errorOccuredWithShortDescription:(NSString *)errorShortDescription andErrorDetails:(NSString *)errorDetails {
    
    [self hideLoadingView];
    NSLog(@"%@", errorShortDescription);
    NSLog(@"%@", errorDetails);
}


-(void)errorInResponseWithBody:(NSString *)errorMessage {
    
    [self hideLoadingView];
    NSLog(@"%@", errorMessage);
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

- (void)signInWillDispatch:(GIDSignIn *)signIn error:(NSError *)error {
    
    [self hideLoadingView];
}

- (void)signIn:(GIDSignIn *)signIn presentViewController:(UIViewController *)viewController {
    
    [self presentViewController:viewController animated:YES completion:^{
        
    }];
}

- (void)signIn:(GIDSignIn *)signIn dismissViewController:(UIViewController *)viewController {
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


@end
