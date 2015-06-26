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
#import "CoreDataManager.h"
#import "LoadingViewController.h"
#import "LoginViewController.h"
#import <GoogleSignIn/GoogleSignIn.h>


@interface MenuViewController () <UITableViewDataSource, UITableViewDelegate, GIDSignInDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageViewProfile;
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UITableView *tableViewMenuu;

@property NSArray *arrayDataTableViewMenu;

@end

@implementation MenuViewController

#pragma mark - Class Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableViewMenuu.delegate = self;
    self.tableViewMenuu.dataSource = self;
    
    self.arrayDataTableViewMenu = @[ @{@"image" : @"imageInbox",
                                  @"text" : @"Inbox",
                                  @"color" : [UIColor cellSelected]},
                                
                                @{@"image" : @"imageSent",
                                  @"text" : @"Sent",
                                  @"color" : [UIColor whiteColor]}
                              ];
    
    [self setupController];
}


#pragma mark - Action Methods
- (IBAction)logOutButtonHandler:(id)sender {
    
    [GIDSignInButton class];
    
    GIDSignIn *googleSignIn = [GIDSignIn sharedInstance];
    googleSignIn.delegate = self;
    [googleSignIn disconnect];
}


#pragma mark - Private Methods
- (void)setupController {
    
    self.labelName.text = [[UserService sharedInstance] name];
}

- (void)clearAllDBAndRedirectInLoginScreen {
    
    [[CoreDataManager sharedCoreDataManager] signOut];
    
    UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginViewController = [storyBoard instantiateViewControllerWithIdentifier:@"loginView"];
    LoadingViewController *loadingViewController = (LoadingViewController *)[storyBoard instantiateViewControllerWithIdentifier:@"loadingView"];
    [self.navigationController setViewControllers:@[loadingViewController,loginViewController]];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)deselectAllCellItems {
    
    for (NSMutableDictionary *dict in self.arrayDataTableViewMenu) {
        dict[@"color"] = [UIColor whiteColor];
    }
}


#pragma mark - TableView DataSource & Delegate Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.arrayDataTableViewMenu.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MenuCell *cell = [tableView dequeueReusableCellWithIdentifier:@"menuCellID"];
    [cell configureCell:[self.arrayDataTableViewMenu objectAtIndex:indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    [self deselectAllCellItems];
//    NSMutableDictionary *dict = [self.arrayDataTableViewMenu objectAtIndex:indexPath.row];
//    dict[@"color"] = [UIColor cellSelected];
    switch (indexPath.row) {
        case 0: {
            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationInbox object:nil];
            break;
        }
        case 1: {
            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationSent object:nil];
            break;
        }
        default:
            break;
    }
}


#pragma mark - GIDSignInDelegate Methods
- (void)signIn:(GIDSignIn *)signIn didDisconnectWithUser:(GIDGoogleUser *)user withError:(NSError *)error {
    
    if (error) {
        
    } else {
        [self clearAllDBAndRedirectInLoginScreen];
    }
}

@end
