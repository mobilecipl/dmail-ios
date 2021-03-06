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

// Services
#import "ServiceProfile.h"
#import "ServiceMessage.h"
#import "ServiceContact.h"
#import "ServiceSync.h"


@interface MenuViewController () <UITableViewDataSource, UITableViewDelegate, GIDSignInDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageViewProfile;
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UITableView *tableViewMenuu;

@property (nonatomic, strong) ServiceProfile *serviceProfile;
@property (nonatomic, strong) ServiceMessage *serviceMessage;
@property (nonatomic, strong) ServiceSync *serviceSync;
@property (nonatomic, strong) ServiceContact *serviceContact;
@property (nonatomic, strong) NSMutableArray *arrayDataTableViewMenu;
@property (nonatomic, strong) NSArray *arrayCellIds;
@property (nonatomic, assign) NSInteger selectedCellIndex;

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
    
    self.tableViewMenuu.delegate = self;
    self.tableViewMenuu.dataSource = self;
    
    self.arrayDataTableViewMenu = [[NSMutableArray alloc] initWithObjects:
                                   @{@"image" : @"imageInbox", @"text" : @"Inbox", @"color" : [UIColor cellSelected]},
                                   @{@"image" : @"imageSent", @"text" : @"Sent", @"color" : [UIColor whiteColor]}, nil];
    
    self.arrayCellIds = @[@"InboxCellID", @"SentCellID"];
    
    [self setupController];
    self.selectedCellIndex = 0;
    
    [self getProfileImage];
}


#pragma mark - Action Methods
- (IBAction)logOutButtonHandler:(id)sender {
    
    [GIDSignInButton class];
    
    GIDSignIn *googleSignIn = [GIDSignIn sharedInstance];
    googleSignIn.delegate = self;
    [googleSignIn disconnect];
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

- (void)setupController {
    
    self.labelName.text = [[ServiceProfile sharedInstance] fullName];
    self.imageViewProfile.layer.masksToBounds = YES;
    self.imageViewProfile.layer.cornerRadius = self.imageViewProfile.frame.size.width/2;
}

- (void)clearAllDBAndRedirectInLoginScreen {
    
    //Clear all info.
    [self.serviceSync stopSync];
    [self.serviceContact cancelAllRequests];
    [self.serviceMessage clearAllData];
    
    UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginViewController = [storyBoard instantiateViewControllerWithIdentifier:@"loginView"];
    LoadingViewController *loadingViewController = (LoadingViewController *)[storyBoard instantiateViewControllerWithIdentifier:@"loadingView"];
    [self.navigationController setViewControllers:@[loadingViewController,loginViewController]];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)getProfileImage {
    
    NSString *urlString = [[ServiceProfile sharedInstance] imageUrl];
    [SDWebImageManager.sharedManager downloadImageWithURL:[NSURL URLWithString:urlString] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        if (image) {
            [self.imageViewProfile setImage:image];
        }
    }];
}


#pragma mark - TableView DataSource & Delegate Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.arrayDataTableViewMenu.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellId = [self.arrayCellIds objectAtIndex:indexPath.row];
    MenuCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    [cell configureCell:[self.arrayDataTableViewMenu objectAtIndex:indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.selectedCellIndex != indexPath.row) {
        [self changeSelectedCellWith:indexPath.row];
        NSIndexPath *indexPathSelected = [NSIndexPath indexPathForRow:self.selectedCellIndex inSection:0];
        [self.tableViewMenuu beginUpdates];
        [self.tableViewMenuu reloadRowsAtIndexPaths:@[indexPath, indexPathSelected] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableViewMenuu endUpdates];
        self.selectedCellIndex = indexPath.row;
    }
//    switch (indexPath.row) {
//        case 0: {
//            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationInbox object:nil];
//            break;
//        }
//        case 1: {
//            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationSent object:nil];
//            break;
//        }
//        default:
//            break;
//    }
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


#pragma mark - GIDSignInDelegate Methods
- (void)signIn:(GIDSignIn *)signIn didDisconnectWithUser:(GIDGoogleUser *)user withError:(NSError *)error {
    
    if (error) {
        
    } else {
        [self clearAllDBAndRedirectInLoginScreen];
    }
}

- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    
}

@end
