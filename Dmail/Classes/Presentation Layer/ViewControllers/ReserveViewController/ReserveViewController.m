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

// GoogleOauth2
#import "GTMOAuth2ViewControllerTouch.h"
#import "GTMOAuth2SignIn.h"

@interface ReserveViewController ()

@property (nonatomic, strong) ServiceProfile *serviceProfile;

@property (nonatomic, strong) NSMutableArray *arrProfileInfo;
@property (nonatomic, strong) NSMutableArray *arrProfileInfoLabel;

@property (nonatomic, retain) GTMOAuth2Authentication *auth;

@end

@implementation ReserveViewController

//static NSString *kGoogleClientId = @"YOUR_CLIENT_ID";
//static NSString *kGoogleClientSecret = @"YOUR_SECRET_KEY";


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
- (void)signInToGoogle {
    
    // For Google APIs, the scope strings are available
    // in the service constant header files.
    NSString *scope = kGoogleClientScope;
    
    // Typically, applications will hardcode the client ID and client secret
    // strings into the source code; they should not be user-editable or visible.
    //
    // But for this sample code, they are editable.
    NSString *clientID = kGoogleClientID;
    NSString *clientSecret = kGoogleClientSecret;
    
    // Note:
    // GTMOAuth2ViewControllerTouch is not designed to be reused. Make a new
    // one each time you are going to show it.
    
    // Display the autentication view.
    SEL finishedSel = @selector(viewController:finishedWithAuth:error:);
    
    GTMOAuth2ViewControllerTouch *viewController;
    viewController = [GTMOAuth2ViewControllerTouch controllerWithScope:scope
                                                              clientID:clientID
                                                          clientSecret:clientSecret
                                                      keychainItemName:nil
                                                              delegate:self
                                                      finishedSelector:finishedSel];
    viewController.signIn.shouldFetchGoogleUserProfile = YES;
    // You can set the title of the navigationItem of the controller here, if you
    // want.
    
    // If the keychainItemName is not nil, the user's authorization information
    // will be saved to the keychain. By default, it saves with accessibility
    // kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly, but that may be
    // customized here. For example,
    //
    //   viewController.keychainItemAccessibility = kSecAttrAccessibleAlways;
    
    // During display of the sign-in window, loss and regain of network
    // connectivity will be reported with the notifications
    // kGTMOAuth2NetworkLost/kGTMOAuth2NetworkFound
    //
    // See the method signInNetworkLostOrFound: for an example of handling
    // the notification.
    
    // Optional: Google servers allow specification of the sign-in display
    // language as an additional "hl" parameter to the authorization URL,
    // using BCP 47 language codes.
    //
    // For this sample, we'll force English as the display language.
    NSDictionary *params = [NSDictionary dictionaryWithObject:@"en" forKey:@"hl"];
    viewController.signIn.additionalAuthorizationParameters = params;
    
    // By default, the controller will fetch the user's email, but not the rest of
    // the user's profile.  The full profile can be requested from Google's server
    // by setting this property before sign-in:
    //
    //   viewController.signIn.shouldFetchGoogleUserProfile = YES;
    //
    // The profile will be available after sign-in as
    //
    //   NSDictionary *profile = viewController.signIn.userProfile;
    
    // Optional: display some html briefly before the sign-in page loads
    NSString *html = @"<html><body bgcolor=silver><div align=center>Loading sign-in page...</div></body></html>";
    viewController.initialHTMLString = html;
    
    [[self navigationController] pushViewController:viewController animated:YES];
    
    // The view controller will be popped before signing in has completed, as
    // there are some additional fetches done by the sign-in controller.
    // The kGTMOAuth2UserSignedIn notification will be posted to indicate
    // that the view has been popped and those additional fetches have begun.
    // It may be useful to display a temporary UI when kGTMOAuth2UserSignedIn is
    // posted, just until the finished selector is invoked.
}

- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController finishedWithAuth:(GTMOAuth2Authentication *)auth error:(NSError *)error {
    
    if (error != nil) {
        // Authentication failed (perhaps the user denied access, or closed the
        // window before granting access)
        NSLog(@"Authentication error: %@", error);
        NSData *responseData = [[error userInfo] objectForKey:@"data"]; // kGTMHTTPFetcherStatusDataKey
        if ([responseData length] > 0) {
            // show the body of the server's authentication failure response
            NSString *str = [[NSString alloc] initWithData:responseData
                                                  encoding:NSUTF8StringEncoding];
            NSLog(@"%@", str);
        }
        
        self.auth = nil;
    } else {
        // Authentication succeeded
        //
        // At this point, we either use the authentication object to explicitly
        // authorize requests, like
        //
        //  [auth authorizeRequest:myNSURLMutableRequest
        //       completionHandler:^(NSError *error) {
        //         if (error == nil) {
        //           // request here has been authorized
        //         }
        //       }];
        //
        // or store the authentication object into a fetcher or a Google API service
        // object like
        //
        //   [fetcher setAuthorizer:auth];
        
        // save the authentication object
        self.auth = auth;
        NSMutableDictionary *userInfoDict = [NSMutableDictionary dictionaryWithDictionary:auth.parameters];

        NSLog(@"auth success %@", auth);
        NSLog(@"auth.parameters success %@", auth.parameters);
        
        NSURL *url = [NSURL URLWithString:@"https://www.googleapis.com/plus/v1/people/me/activities/public"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [self.auth authorizeRequest:request completionHandler:^(NSError *error) {
            NSString *output = nil;
            if (error) {
                output = [error description];
            } else {
                NSURLResponse *response = nil;
                NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
                if (data) {
                    // API fetch succeeded
                    output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    NSError* error;
                    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                    
                    NSArray *array=[json objectForKey:@"items"];
                    if (array.count > 0) {
                        NSDictionary *dict = [array objectAtIndex:0];
                        NSDictionary *userInfo = dict[@"actor"];
                        [userInfoDict setObject:userInfo[@"displayName"] forKey:@"fullName"];
                        [userInfoDict setObject:userInfo[@"image"][@"url"] forKey:@"imageUrl"];
                        [self.serviceProfile updateUserDetails:userInfoDict];
                        [self performSegueWithIdentifier:@"fromReserveToQueu" sender:self];
                    }
                }
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
    
//    self.googleOAuth = [[GoogleOAuth alloc] initWithFrame:self.view.frame];
//    [self.googleOAuth setGOAuthDelegate:self];
//    [self.googleOAuth authorizeUserWithClienID:kGoogleClientID
//                           andClientSecret:kGoogleClientSecret
//                             andParentView:self.view
//                                 andScopes:@[@"https://www.google.com/m8/feeds/", @"https://mail.google.com/", @"https://apps-apis.google.com/a/feeds/emailsettings/2.0/"]
//     ];
    
//    [GIDSignInButton class];
//    GIDSignIn *googleSignIn = [GIDSignIn sharedInstance];
//    googleSignIn.scopes = @[@"https://www.google.com/m8/feeds/", @"https://mail.google.com/", @"https://apps-apis.google.com/a/feeds/emailsettings/2.0/"];
//    googleSignIn.clientID = kGoogleClientID;
//    googleSignIn.shouldFetchBasicProfile = YES;
//    googleSignIn.allowsSignInWithWebView = NO;
//    googleSignIn.delegate = self;
//    [googleSignIn signIn];
    
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

//#pragma mark - GIDSignInDelegate Methods
//- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
//    
//    [self hideLoadingView];
//    if (error) {
//        [self showErrorAlertWithTitle:@"Error!" message:@"Unable to sign in to Google. Please try again."];
//        return;
//    }
//    else {
//        [self.serviceProfile updateUserDetails:user];
//        [self performSegueWithIdentifier:@"fromReserveToQueu" sender:self];
//    }
//}
//
//- (void)signInWillDispatch:(GIDSignIn *)signIn error:(NSError *)error {
//    
//    [self hideLoadingView];
//}
//
//- (void)signIn:(GIDSignIn *)signIn presentViewController:(UIViewController *)viewController {
//    
//    [self presentViewController:viewController animated:YES completion:^{
//        
//    }];
//}
//
//- (void)signIn:(GIDSignIn *)signIn dismissViewController:(UIViewController *)viewController {
//    
//    [self dismissViewControllerAnimated:YES completion:^{
//        
//    }];
//}


@end
