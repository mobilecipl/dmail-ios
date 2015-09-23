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
#import "AppDelegate.h"

// Services
#import "ServiceProfile.h"
#import "ServiceMessage.h"
#import "ServiceContact.h"
#import "ServiceSync.h"
#import "ServiceGoogleOauth2.h"

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
@property (nonatomic, strong) ServiceGoogleOauth2 *serviceGoogleOauth2;

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
        _serviceGoogleOauth2 = [[ServiceGoogleOauth2 alloc] init];
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

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(profileRemoved) name:@"ProfileRemoved" object:nil];
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
- (void)profileRemoved {
    
    [self createProfilesTable];
    [self.tableViewMenu reloadData];
    self.tableViewMenu.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
}

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

- (void)signInToGoogle {
    
    SEL finishedSel = @selector(viewController:finishedWithAuth:error:);
    
    NSString *keychainName = [self.serviceProfile getLastProfileKeychanName];
    GTMOAuth2ViewControllerTouch *viewController;
    viewController = [GTMOAuth2ViewControllerTouch controllerWithScope:kGoogleClientScope
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
        NSLog(@"Authentication error: %@", error);
        NSData *responseData = [[error userInfo] objectForKey:@"data"]; // kGTMHTTPFetcherStatusDataKey
        if ([responseData length] > 0) {
            NSString *str = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            NSLog(@"ERROR === %@", str);
        }
    } else {
        [self.serviceGoogleOauth2 authorizeRequestWithAuth:auth completion:^(id data, ErrorDataModel *error) {
            [self createProfilesTable];
            [self.tableViewMenu reloadData];
            [[AppDelegate sharedDelegate].serviceProfilesSyncing addProfileWithEmail:data[@"email"] googleId:data[@"userID"]];
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
    
    MenuSectionView *profileSection;
    if (self.selectedSection != -1) {
        profileSection = [self.arraySectionViews objectAtIndex:self.selectedSection];
        
    }
    else {
        profileSection = [self.arraySectionViews firstObject];
    }
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
            menuSectionViewAddAccount.delegate = self;
            [self.arraySectionViews addObject:menuSectionViewAddAccount];
            [self.tableViewMenu insertSections:[NSIndexSet indexSetWithIndex:[self.arraySectionViews count]-1] withRowAnimation:UITableViewRowAnimationFade];
        }
        [self.tableViewMenu insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationFade];
        [self.tableViewMenu endUpdates];
        
//        [self showSettingsIconWithAnimation];
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
        
//        [self hideSettingsIconWithAnimation];
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
    
    [self signInToGoogle];
}


@end
