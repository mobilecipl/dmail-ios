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

@interface MenuViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageViewProfile;
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UITableView *tableViewMenuu;

@property NSArray *dataTableViewMenu;

@end

@implementation MenuViewController

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
}

#pragma mark TableView DataSource & Delegate
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
            NSLog(@"Inbox Selected");
            break;
        }
        case 1: {
            NSLog(@"Sent Selected");
            break;
        }
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)logOutButtonHandler:(id)sender {
    NSLog(@"Log out");
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
