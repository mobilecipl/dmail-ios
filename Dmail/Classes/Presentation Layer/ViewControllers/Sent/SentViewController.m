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

//dao
#import "DAOMessage.h"

// data source
#import "TableViewDataSource.h"

// view model
#import "VMSentMessageItem.h"

// view
#import "SentCell.h"

// sdwebimage

//colors
#import "UIColor+AppColors.h"

#import <Realm/Realm.h>
#import "RMModelRecipient.h"


@interface SentViewController () <UITableViewDelegate, TableViewDataSourceDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableViewSent;
@property (nonatomic, weak) IBOutlet UIView *viewDeactivateScreen;
@property (nonatomic, weak) IBOutlet UILabel *labelNavigationTitle;
@property (nonatomic, weak) IBOutlet UIButton *buttonRevealMenu;
@property (nonatomic, weak) IBOutlet BaseNavigationController *viewNavigation;

@property (nonatomic, strong) DAOMessage *daoMessage;
@property (nonatomic, strong) ServiceMessage *serviceMessage;
@property (nonatomic, strong) TableViewDataSource *dataSourceInbox;
@property (nonatomic, strong) VMSentMessageItem *selectedMessage;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSMutableArray *arrayMesages;

@end

@implementation SentViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        _daoMessage = [[DAOMessage alloc] init];
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageDestroyedSuccess) name:NotificationDestroySuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageDestroyedFailed) name:NotificationDestroyFailed object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageSentSuccess) name:NotificationNewMessageSent object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuOpened) name:NotificationMenuOpened object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuClosed) name:NotificationMenuClosed object:nil];
}

- (void)menuOpened {
    
    self.viewDeactivateScreen.hidden = NO;
}

- (void)menuClosed {
    
    self.viewDeactivateScreen.hidden = YES;
}

- (void)tapOnView {
    
    [self.revealViewController revealToggle:self];
}

- (void)setupController {
    
    UITapGestureRecognizer *tapOnView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnView)];
    [self.viewDeactivateScreen addGestureRecognizer:tapOnView];
    UITapGestureRecognizer *tapOnNavigation = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnView)];
    [self.viewNavigation addGestureRecognizer:tapOnNavigation];
    [self.buttonRevealMenu addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupTableView {
    
    // Initilaize collection view.
    TableViewCellBlock configureCell = ^(SentCell *cell, VMSentMessageItem *item, NSIndexPath *indexPath) {
        [cell configureCell:item];
    };
    
    self.dataSourceInbox = [[TableViewDataSource alloc] initWithItems:@[] cellIdentifier:SentCellIdentifier configureCellBlock:configureCell];
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

- (void)messageDestroyedSuccess {
    
    [self hideLoadingView];
    [self showMessageDestroyedSuccess:NO];
}

- (void)messageDestroyedFailed {
    
    [self hideLoadingView];
}

- (void)messageSentSuccess {
    
    [self showMessageSentSuccess];
}

- (void)updateInboxScreen:(id)messageItem {
    
    [self hideLoadingView];
    [self loadMessages];
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
        [self showLoadingView];
        VMSentMessageItem *messageItem = [self.arrayMesages objectAtIndex:indexPath.row];
        [self.serviceMessage destroyMessageWithMessageId:messageItem.messageId participant:nil];
    }];
    button.backgroundColor = [UIColor cellDeleteButtonColor];
    
    return @[button];
}


#pragma mark - UIStoryboardSegue Methods
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"fromSentToSentView"]) {
        SentMessageViewController *sentMessageVC = (SentMessageViewController *)segue.destinationViewController;
        if ([sentMessageVC isKindOfClass:[SentMessageViewController class]]) {
            sentMessageVC.messageIdentifier = self.selectedMessage.messageIdentifier;
            sentMessageVC.messageId = self.selectedMessage.messageId;
        }
    }
}

@end
