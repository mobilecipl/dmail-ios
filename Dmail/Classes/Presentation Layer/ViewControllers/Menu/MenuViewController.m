//
//  MenuViewController.m
//  Dmail
//
//  Created by Gevorg Ghukasyan on 6/15/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "MenuViewController.h"
#import "MenuCell.h"
#import "UIColor+AppColors.h"
#import "LoadingViewController.h"
#import "LoginViewController.h"
#import "SWRevealViewController.h"
#import "UIImageView+WebCache.h"
#import "MenuSectionView.h"
#import "ProfileModel.h"

// Services
#import "ServiceProfile.h"
#import "ServiceMessage.h"
#import "ServiceContact.h"
#import "ServiceSync.h"

// google
//#import <GoogleSignIn/GoogleSignIn.h>

// GoogleOauth2
#import "GTMOAuth2ViewControllerTouch.h"
#import "GTMOAuth2SignIn.h"


@interface MenuViewController () <UITableViewDataSource, UITableViewDelegate, MenuSectionViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableViewMenu;
@property (weak, nonatomic) IBOutlet UIButton *buttonSettings;
@property (weak, nonatomic) IBOutlet UIButton *buttonSettingsIcon;
@property (weak, nonatomic) IBOutlet UIButton *buttonAddAccount;

@property (nonatomic, strong) ServiceProfile *serviceProfile;
@property (nonatomic, strong) ServiceMessage *serviceMessage;
@property (nonatomic, strong) ServiceSync *serviceSync;
@property (nonatomic, strong) ServiceContact *serviceContact;
@property (nonatomic, strong) NSArray *arrayProfiles;
@property (nonatomic, strong) NSMutableArray *arraySectionViews;
@property (nonatomic, strong) NSMutableArray *arrayDataTableViewMenu;
@property (nonatomic, strong) NSArray *arrayCellIds;
@property (nonatomic, assign) NSInteger selectedCellIndex;
@property (nonatomic, assign) NSInteger selectedSection;

@end

@implementation MenuViewController

#pragma mark - Class Methods
- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        _serviceProfile = [[ServiceProfile alloc] init];
        _serviceMessage = [[ServiceMessage alloc] init];
        _serviceContact = [[ServiceContact alloc] init];
        _serviceSync = [[ServiceSync alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.tableViewMenu.delegate = self;
    self.tableViewMenu.dataSource = self;
    
    self.selectedCellIndex = 0;
    self.selectedSection = -1;
    
    [self createProfilesTable];
    self.tableViewMenu.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.tableViewMenu.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
}

#pragma mark - Action Methods
- (IBAction)buttonSettingsClicked:(id)sender {

    [self performSegueWithIdentifier:@"fromMenuToSettings" sender:self];
}

- (IBAction)addAccount:(id)sender {
    
    [self signInToGoogle];
}


#pragma mark - Private Methods
- (void)createProfilesTable {
    
    self.arrayProfiles = [self.serviceProfile getAllProfiles];
    self.arraySectionViews = [[NSMutableArray alloc] init];
    for (ProfileModel *profileModel in self.arrayProfiles) {
        MenuSectionView *menuSectionView = [[MenuSectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 65) email:profileModel.email profileImageUrl:profileModel.imageUrl selected:profileModel.selected];
        menuSectionView.delegate = self;
        [self.arraySectionViews addObject:menuSectionView];
    }
}

- (void)changeSelectedCellWith:(NSInteger)selecetdCell {
    
    NSDictionary *dict = [self.arrayDataTableViewMenu objectAtIndex:selecetdCell];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    for (NSString *key in [dict allKeys]) {
        if ([key isEqualToString:@"image"]) {
            [dictionary setObject:dict[key] forKey:key];
        }
        if ([key isEqualToString:@"text"]) {
            [dictionary setObject:dict[key] forKey:key];
        }
        if ([key isEqualToString:@"color"]) {
            [dictionary setObject:[UIColor cellSelected] forKey:key];
        }
    }
    [self.arrayDataTableViewMenu replaceObjectAtIndex:selecetdCell withObject:dictionary];
    
    dict = [self.arrayDataTableViewMenu objectAtIndex:self.selectedCellIndex];
    dictionary = [[NSMutableDictionary alloc] init];
    for (NSString *key in [dict allKeys]) {
        if ([key isEqualToString:@"image"]) {
            [dictionary setObject:dict[key] forKey:key];
        }
        if ([key isEqualToString:@"text"]) {
            [dictionary setObject:dict[key] forKey:key];
        }
        if ([key isEqualToString:@"color"]) {
            [dictionary setObject:[UIColor whiteColor] forKey:key];
        }
    }
    [self.arrayDataTableViewMenu replaceObjectAtIndex:self.selectedCellIndex withObject:dictionary];
}

- (void)clearAllDBAndRedirectInLoginScreen {
    
    //Clear all info.
    [self.serviceSync stopSync];
    [self.serviceContact cancelAllRequests];
    [self.serviceMessage clearAllData];
    
    UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *reserveViewController = [storyBoard instantiateViewControllerWithIdentifier:@"reserveView"];
//    LoadingViewController *loadingViewController = (LoadingViewController *)[storyBoard instantiateViewControllerWithIdentifier:@"loadingView"];
    [self.navigationController setViewControllers:@[reserveViewController]];
    [self.navigationController popViewControllerAnimated:YES];
}

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
            NSString *str = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            NSLog(@"%@", str);
        }
    } else {
        NSMutableDictionary *userInfoDict = [NSMutableDictionary dictionaryWithDictionary:auth.parameters];
        NSLog(@"auth success %@", auth);
        NSLog(@"auth.parameters success %@", auth.parameters);
        NSURL *url = [NSURL URLWithString:@"https://www.googleapis.com/plus/v1/people/me/activities/public"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [auth authorizeRequest:request completionHandler:^(NSError *error) {
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
                        
                        [self createProfilesTable];
                        [self.tableViewMenu reloadData];
                    }
                }
            }
        }];
    }
}

- (void)closeAllProfileSectionsExept:(NSString *)email {
    
    for (MenuSectionView *sectionView in self.arraySectionViews) {
        if (![sectionView.email isEqualToString:email]) {
            [sectionView closeSection];
        }
    }
}


#pragma mark - TableView DataSource & Delegate Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return [self.arraySectionViews count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 65;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    return [self.arraySectionViews objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger rows = 0;
    if (self.selectedSection == section) {
        rows = self.arrayDataTableViewMenu.count;;
    }
    else {
        rows = 0;
    }
    
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.selectedSection != -1 && self.selectedSection == indexPath.section) {
        NSString *cellId = [self.arrayCellIds objectAtIndex:indexPath.row];
        MenuCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        [cell configureCell:[self.arrayDataTableViewMenu objectAtIndex:indexPath.row]];
        return cell;
    }
    else {
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.selectedCellIndex != indexPath.row) {
        [self changeSelectedCellWith:indexPath.row];
        NSIndexPath *indexPathSelected = [NSIndexPath indexPathForRow:self.selectedCellIndex inSection:indexPath.section];
        [self.tableViewMenu beginUpdates];
        [self.tableViewMenu reloadRowsAtIndexPaths:@[indexPath, indexPathSelected] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableViewMenu endUpdates];
        self.selectedCellIndex = indexPath.row;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    MenuSectionView *profileSection = [self.arraySectionViews objectAtIndex:self.selectedSection];
    [self.serviceProfile selectProfileWithEmail:profileSection.email];
    
    if ([segue isKindOfClass:[SWRevealViewControllerSegue class]]) {
        SWRevealViewControllerSegue *swSegue = (SWRevealViewControllerSegue *)segue;
        swSegue.performBlock = ^(SWRevealViewControllerSegue *rvc_segue, UIViewController *svc, UIViewController *dvc) {
            UINavigationController *navController = (UINavigationController *)self.revealViewController.frontViewController;
            [navController setViewControllers:@[dvc] animated:NO];
            [self.revealViewController setFrontViewPosition:FrontViewPositionLeft animated:YES];
        };
    }
}


#pragma mark - MenuSectionViewDelegate Methods 
- (void)onArrowClicked:(id)menuSection {
    
    MenuSectionView *menuSectionView = (MenuSectionView *)menuSection;
    if (menuSectionView.arrowUp) {
        NSArray *deletedRows;
        if (self.selectedSection != -1) {
            deletedRows = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:self.selectedSection],[NSIndexPath indexPathForRow:1 inSection:self.selectedSection],nil];
            MenuSectionView *closedSection = [self.arraySectionViews objectAtIndex:self.selectedSection];
            [closedSection closeSection];
        }
        self.selectedSection = [self.arraySectionViews indexOfObject:menuSectionView];
        self.arrayDataTableViewMenu = [[NSMutableArray alloc] initWithObjects:
                                       @{@"image" : @"imageInbox", @"text" : @"Dmails Received", @"color" : [UIColor cellSelected]},
                                       @{@"image" : @"imageSent", @"text" : @"Dmails Sent", @"color" : [UIColor whiteColor]}, nil];
        
        self.arrayCellIds = @[@"InboxCellID", @"SentCellID"];
        NSArray *paths = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:self.selectedSection],[NSIndexPath indexPathForRow:1 inSection:self.selectedSection],nil];
        [self.tableViewMenu beginUpdates];
        if (deletedRows) {
            [self.tableViewMenu deleteRowsAtIndexPaths:deletedRows withRowAnimation:UITableViewRowAnimationFade];
        }
        else {
            MenuSectionView *menuSectionViewAddAccount = [[MenuSectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 65)];
            [self.arraySectionViews addObject:menuSectionViewAddAccount];
            [self.tableViewMenu insertSections:[NSIndexSet indexSetWithIndex:[self.arraySectionViews count]-1] withRowAnimation:UITableViewRowAnimationFade];
        }
        [self.tableViewMenu insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationFade];
        [self.tableViewMenu endUpdates];
        
        [self showSettingsIconWithAnimation];
    }
    else {
        self.arrayDataTableViewMenu = nil;
        self.arrayCellIds = nil;
        [self.arraySectionViews removeObjectAtIndex:[self.arraySectionViews count]-1];
        
        NSArray *paths = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:self.selectedSection],[NSIndexPath indexPathForRow:1 inSection:self.selectedSection],nil];
        [self.tableViewMenu beginUpdates];
        [self.tableViewMenu deleteRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationFade];
        [self.tableViewMenu deleteSections:[NSIndexSet indexSetWithIndex:[self.arraySectionViews count]] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableViewMenu endUpdates];
        self.selectedSection = -1;
        
        [self hideSettingsIconWithAnimation];
    }
    [self closeAllProfileSectionsExept:menuSectionView.email];
}

- (void)showSettingsIconWithAnimation {
    
    [UIView animateWithDuration:0.3 animations:^{
        self.buttonAddAccount.alpha = 0;
        self.buttonSettings.alpha = 1;
        self.buttonSettingsIcon.alpha = 0;
    }];
}

- (void)hideSettingsIconWithAnimation {
    
    [UIView animateWithDuration:0.3 animations:^{
        self.buttonAddAccount.alpha = 1;
        self.buttonSettings.alpha = 0;
        self.buttonSettingsIcon.alpha = 1;
    }];
}

- (void)onAddAccountClicked {
    
}


//#pragma mark - GIDSignInDelegate Methods
//- (void)signIn:(GIDSignIn *)signIn didDisconnectWithUser:(GIDGoogleUser *)user withError:(NSError *)error {
//    
//    if (error) {
//        
//    } else {
//        [self clearAllDBAndRedirectInLoginScreen];
//    }
//}
//
//- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
//    
//    if (error) {
//        [self showErrorAlertWithTitle:@"Error!" message:@"Unable to sign in to Google. Please try again."];
//    }
//    else {
//        // TODO: sync
//        [self.serviceProfile updateUserDetails:user];
//        [self.serviceSync sync];
//        if (![[NSUserDefaults standardUserDefaults] boolForKey:OnboardingWasShowed]) {
////            [self performSegueWithIdentifier:@"fromLodaingToOnboarding" sender:self];
//        }
//        else {
////            [self performSegueWithIdentifier:@"fromLoadingToRoot" sender:self];
//        }
//    }
//
//}
//
//// a spinner or other "please wait" element.
//- (void)signInWillDispatch:(GIDSignIn *)signIn error:(NSError *)error {
//    
//    
//}
//
//// If implemented, this method will be invoked when sign in needs to display a view controller.
//// The view controller should be displayed modally (via UIViewController's |presentViewController|
//// method, and not pushed unto a navigation controller's stack.
//- (void)signIn:(GIDSignIn *)signIn presentViewController:(UIViewController *)viewController {
//    
//    [self presentViewController:viewController animated:YES completion:^{
//        
//    }];
//}
//
//// If implemented, this method will be invoked when sign in needs to dismiss a view controller.
//// Typically, this should be implemented by calling |dismissViewController| on the passed
//// view controller.
//- (void)signIn:(GIDSignIn *)signIn dismissViewController:(UIViewController *)viewController {
//    
//    
//}
//


@end
