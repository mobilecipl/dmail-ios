//
//  SentViewController.m
//  Dmail
//
//  Created by Armen Mkrtchian on 7/7/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "SentViewController.h"
// controller
#import "ComposeViewController.h"
#import "InboxMessageViewController.h"
#import "SentMessageViewController.h"
#import "SWRevealViewController.h"

// service
#import "ServiceMessage.h"

// data source
#import "TableViewDataSource.h"

// view model
#import "VMSentMessageItem.h"

// view
#import "SentCell.h"

// sdwebimage

//colors
#import "UIColor+AppColors.h"

@interface SentViewController () <UITableViewDelegate, TableViewDataSourceDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableViewSent;
@property (weak, nonatomic) IBOutlet UILabel *labelNavigationTitle;
@property (weak, nonatomic) IBOutlet UIButton *buttonRevealMenu;

@property (strong, nonatomic) ServiceMessage *serviceMessage;
@property (strong, nonatomic) TableViewDataSource *dataSourceInbox;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (nonatomic, strong) VMSentMessageItem *selectedMessage;
@property (nonatomic, strong) NSMutableArray *arrayMesages;

@end

@implementation SentViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        _serviceMessage = [[ServiceMessage alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setupController];
    [self setupTableView];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self registerNotifications];
    [self loadMessages];
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Private Methods
- (void)registerNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadMessages) name:NotificationGMailMessageFetched object:nil];
}

- (void)setupController {
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [self.buttonRevealMenu addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
}

- (void)setupTableView {
    
    // Initilaize collection view.
    TableViewCellBlock configureCell = ^(SentCell *cell, VMSentMessageItem *item) {
        [cell configureCell:item];
    };
    
    self.dataSourceInbox = [[TableViewDataSource alloc] initWithItems:@[]
                                                       cellIdentifier:SentCellIdentifier
                                                   configureCellBlock:configureCell];
    self.dataSourceInbox.delegate = self;
    self.tableViewSent.allowsMultipleSelectionDuringEditing = NO;
    
    [self.tableViewSent setDataSource:self.dataSourceInbox];
    [self.tableViewSent setDelegate:self];

    
    // creating refresh control
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.tableViewSent addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(loadMessages) forControlEvents:UIControlEventValueChanged];
}

- (void)loadMessages {
    
    [self.refreshControl endRefreshing];
    
    self.arrayMesages = [[self.serviceMessage getSentMessages] mutableCopy];
    self.dataSourceInbox.items = self.arrayMesages;
    [self.tableViewSent reloadData];
}


#pragma mark - Action Methods
- (IBAction)buttonHandlerCompose:(id)sender {
    
    [self performSegueWithIdentifier:@"fromSentToCompose" sender:self];
}


#pragma mark - Delegate Methods -
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.selectedMessage = [self.dataSourceInbox itemAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"fromSentToSentView" sender:self];
}


- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return @"Destroy";
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewRowAction *button = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Destroy" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        NSLog(@"Action to perform with Button 1");
    }];
    button.backgroundColor = [UIColor cellDeleteButtonColor];
    
    return @[button];
}


#pragma mark - TableViewDataSourceDelegate Methods
- (void)destroyMessageWithIndexPath:(NSIndexPath *)indexPath {
    
//    VMInboxMessageItem *messageItem = [self.arrayMesages objectAtIndex:indexPath.row];
    //TODO:
//    [self.serviceMessage destroyMessageWithMessageItem:messageItem];
}


#pragma mark - UIStoryboardSegue Methods
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"fromSentToSentView"]) {
        SentMessageViewController *sentMessageVC = (SentMessageViewController *)segue.destinationViewController;
        if ([sentMessageVC isKindOfClass:[SentMessageViewController class]]) {
            sentMessageVC.messageIdentifier = self.selectedMessage.messageIdentifier;
        }
    }
}

- (void)updateInboxScreen:(id)messageItem {
    
    [self hideLoadingView];
    [self loadMessages];
}

@end
