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
#import "ServiceGoogleOauth2.h"

// GoogleOauth2
#import "GTMOAuth2ViewControllerTouch.h"
#import "GTMOAuth2SignIn.h"

@interface ReserveViewController ()

@property (nonatomic, strong) ServiceProfile *serviceProfile;
@property (nonatomic, strong) ServiceGoogleOauth2 *serviceGoogleOauth2;

@property (nonatomic, strong) NSMutableArray *arrProfileInfo;
@property (nonatomic, strong) NSMutableArray *arrProfileInfoLabel;

@end

@implementation ReserveViewController


#pragma mark - Class Methods
- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        _serviceProfile = [[ServiceProfile alloc] init];
        _serviceGoogleOauth2 = [[ServiceGoogleOauth2 alloc] init];
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
- (void)signInToGoogle {
    
    SEL finishedSel = @selector(viewController:finishedWithAuth:error:);
    
    NSString *keychainName = @"1";
    GTMOAuth2ViewControllerTouch *viewController = [GTMOAuth2ViewControllerTouch controllerWithScope:kGoogleClientScope
                                                              clientID:kGoogleClientID
                                                          clientSecret:kGoogleClientSecret
                                                      keychainItemName:keychainName
                                                              delegate:self
                                                      finishedSelector:finishedSel];
    viewController.signIn.shouldFetchGoogleUserProfile = YES;
    NSDictionary *params = [NSDictionary dictionaryWithObject:@"en" forKey:@"hl"];
    viewController.signIn.additionalAuthorizationParameters = params;
    NSString *html = @"<html><body bgcolor=silver><div align=center>Loading sign-in page...</div></body></html>";
    viewController.initialHTMLString = html;
    
    [[self navigationController] pushViewController:viewController animated:YES];
}

- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController finishedWithAuth:(GTMOAuth2Authentication *)auth error:(NSError *)error {
    
    if (error != nil) {
        NSData *responseData = [[error userInfo] objectForKey:@"data"];
        if ([responseData length] > 0) {
            NSString *str = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            NSLog(@"ERROR ==== %@", str);
        }
        
    } else {
        [self.serviceGoogleOauth2 authorizeRequestWithAuth:auth completion:^(id data, ErrorDataModel *error) {
            if (data) {
                [self performSegueWithIdentifier:@"fromReserveToQueu" sender:self];
            }
        }];
    }
}

- (void)presentSignInViewController:(UIViewController *)viewController {
    
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)appWillEnterForeground:(NSNotification *)notification {
    
    [self hideLoadingView];
}


#pragma mark - Action Methods
- (IBAction)reserveMySpotClicked:(id)sender {
    
    [self showLoadingView];
    [self signInToGoogle];
}


#pragma mark - GoogleOAuth Delegate methods
- (void)authorizationWasSuccessful {
    
//    [self.googleOAuth callAPI:@"https://www.googleapis.com/oauth2/v1/userinfo" withHttpMethod:httpMethod_GET postParameterNames:nil postParameterValues:nil];
//    [self.googleOAuth callAPI:@"https://mail.google.com" withHttpMethod:httpMethod_GET postParameterNames:nil postParameterValues:nil];
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

@end
