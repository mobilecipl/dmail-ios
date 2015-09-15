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
#import <GoogleSignIn/GoogleSignIn.h>


@interface MenuViewController () <UITableViewDataSource, UITableViewDelegate, GIDSignInDelegate, GIDSignInUIDelegate, MenuSectionViewDelegate>

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
@property (nonatomic, assign) BOOL arrowUp;

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
    
    
    self.arrayProfiles = [self.serviceProfile getAllProfiles];
    self.arraySectionViews = [[NSMutableArray alloc] init];
    for (ProfileModel *profileModel in self.arrayProfiles) {
        MenuSectionView *menuSectionView = [[MenuSectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 65) email:profileModel.email profileImageUrl:profileModel.imageUrl selected:profileModel.selected];
        menuSectionView.delegate = self;
        [self.arraySectionViews addObject:menuSectionView];
    }
}


#pragma mark - Action Methods
- (IBAction)buttonSettingsClicked:(id)sender {
    
//    [GIDSignInButton class];
//    
//    GIDSignIn *googleSignIn = [[GIDSignIn alloc] init];
//    googleSignIn.delegate = self;
//    [googleSignIn disconnect];
//
//    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    UIViewController *viewController = [storyBoard instantiateViewControllerWithIdentifier:@"queue"];
//    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [self performSegueWithIdentifier:@"fromMenuToSettings" sender:self];
}

- (IBAction)addAccount:(id)sender {
    
    [GIDSignInButton class];
    
    GIDSignIn *googleSignIn = [[GIDSignIn alloc] init];
    
    googleSignIn.scopes = @[@"https://www.google.com/m8/feeds/", @"https://mail.google.com/", @"https://apps-apis.google.com/a/feeds/emailsettings/2.0/"];
    googleSignIn.shouldFetchBasicProfile = YES;
    googleSignIn.clientID = kGoogleClientID;
    googleSignIn.allowsSignInWithWebView = YES;
    googleSignIn.uiDelegate = self;
    googleSignIn.delegate = self;
    [googleSignIn signIn];
}


#pragma mark - Private Methods
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
    if (self.arrowUp) {
        if (section == [self.arraySectionViews count] - 1) {
            rows = 0;
        }
        else {
            rows = self.arrayDataTableViewMenu.count;
        }
    }
    else {
        rows = self.arrayDataTableViewMenu.count;
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
        NSIndexPath *indexPathSelected = [NSIndexPath indexPathForRow:self.selectedCellIndex inSection:0];
        [self.tableViewMenu beginUpdates];
        [self.tableViewMenu reloadRowsAtIndexPaths:@[indexPath, indexPathSelected] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableViewMenu endUpdates];
        self.selectedCellIndex = indexPath.row;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
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
        self.arrowUp = YES;
        self.selectedSection = [self.arraySectionViews indexOfObject:menuSectionView];
        self.arrayDataTableViewMenu = [[NSMutableArray alloc] initWithObjects:
                                       @{@"image" : @"imageInbox", @"text" : @"Dmails Received", @"color" : [UIColor cellSelected]},
                                       @{@"image" : @"imageSent", @"text" : @"Dmails Sent", @"color" : [UIColor whiteColor]}, nil];
        
        self.arrayCellIds = @[@"InboxCellID", @"SentCellID"];
        MenuSectionView *menuSectionView = [[MenuSectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 65)];
        [self.arraySectionViews addObject:menuSectionView];
        
        NSArray *paths = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:self.selectedSection],[NSIndexPath indexPathForRow:1 inSection:self.selectedSection],nil];
        [self.tableViewMenu beginUpdates];
        [self.tableViewMenu insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationFade];
        [self.tableViewMenu insertSections:[NSIndexSet indexSetWithIndex:[self.arraySectionViews count]-1] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableViewMenu endUpdates];
        
        [self showSettingsIconWithAnimation];
    }
    else {
        self.arrowUp = NO;
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


#pragma mark - GIDSignInDelegate Methods
- (void)signIn:(GIDSignIn *)signIn didDisconnectWithUser:(GIDGoogleUser *)user withError:(NSError *)error {
    
    if (error) {
        
    } else {
        [self clearAllDBAndRedirectInLoginScreen];
    }
}

- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    
    if (error) {
        [self showErrorAlertWithTitle:@"Error!" message:@"Unable to sign in to Google. Please try again."];
    }
    else {
        // TODO: sync
        [self.serviceProfile updateUserDetails:user];
        [self.serviceSync sync];
        if (![[NSUserDefaults standardUserDefaults] boolForKey:OnboardingWasShowed]) {
//            [self performSegueWithIdentifier:@"fromLodaingToOnboarding" sender:self];
        }
        else {
//            [self performSegueWithIdentifier:@"fromLoadingToRoot" sender:self];
        }
    }

}

// a spinner or other "please wait" element.
- (void)signInWillDispatch:(GIDSignIn *)signIn error:(NSError *)error {
    
    
}

// If implemented, this method will be invoked when sign in needs to display a view controller.
// The view controller should be displayed modally (via UIViewController's |presentViewController|
// method, and not pushed unto a navigation controller's stack.
- (void)signIn:(GIDSignIn *)signIn presentViewController:(UIViewController *)viewController {
    
    [self presentViewController:viewController animated:YES completion:^{
        
    }];
}

// If implemented, this method will be invoked when sign in needs to dismiss a view controller.
// Typically, this should be implemented by calling |dismissViewController| on the passed
// view controller.
- (void)signIn:(GIDSignIn *)signIn dismissViewController:(UIViewController *)viewController {
    
    
}



@end
