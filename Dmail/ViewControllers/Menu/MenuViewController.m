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

@interface MenuViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageViewProfile;
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UITableView *tableViewMenuu;

@property NSArray *dataTableViewMenu;

@end

@implementation MenuViewController

#pragma mark - Class Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableViewMenuu.delegate = self;
    self.tableViewMenuu.dataSource = self;
    
    self.dataTableViewMenu = @[ @{@"image" : @"imageInbox",
                                  @"text" : @"Inbox",
                                  @"color" : [UIColor unreadColor]},
                                
                                @{@"image" : @"imageSent",
                                  @"text" : @"Sent",
                                  @"color" : [UIColor whiteColor]}
                              ];
    
    [self setupController];
}


#pragma mark - Action Methods
- (IBAction)logOutButtonHandler:(id)sender {
    
//    [[CoreDataManager sharedCoreDataManager] signOut];
//    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationSignOut object:nil];
}


#pragma mark - Private Methods
- (void)setupController {
    
    self.labelName.text = [[UserService sharedInstance] name];
}

#pragma mark - TableView DataSource & Delegate Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.dataTableViewMenu.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MenuCell *cell = [tableView dequeueReusableCellWithIdentifier:@"menuCellID"];
    [cell configureCell:[self.dataTableViewMenu objectAtIndex:indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case 0: {
            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationInbox object:nil];
            NSLog(@"Inbox Selected");
            break;
        }
        case 1: {
            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationSent object:nil];
            NSLog(@"Sent Selected");
            break;
        }
        default:
            break;
    }
}

@end
