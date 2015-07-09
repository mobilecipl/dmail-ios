//
//  InboxViewController.m
//  Dmail
//
//  Created by Gevorg Ghukasyan on 6/12/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "InboxViewController.h"

// controller
#import "ComposeViewController.h"
#import "InboxMessageViewController.h"
#import "SentMessageViewController.h"
#import "SWRevealViewController.h"

// service
#import "ServiceMessage.h"

// data source
#import "TableViewDataSource.h"

// model
#import "MessageItem.h"

// view
#import "InboxCell.h"

//colors
#import "UIColor+AppColors.h"

@interface InboxViewController () <UITableViewDelegate, TableViewDataSourceDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableViewInbox;
@property (weak, nonatomic) IBOutlet UILabel *labelNavigationTitle;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewNavigationIcon;
@property (weak, nonatomic) IBOutlet UIButton *buttonRevealMenu;

@property (strong, nonatomic) ServiceMessage *serviceMessage;
@property (strong, nonatomic) TableViewDataSource *dataSourceInbox;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (nonatomic, strong) MessageItem *selectedMessageItem;
@property (nonatomic, strong) NSMutableArray *arrayMesages;

@end

@implementation InboxViewController

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadMessages) name:NotificationNewMessageFetched object:nil];
}

- (void)setupController {
    
    self.arrayMesages = [[NSMutableArray alloc] init];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [self.buttonRevealMenu addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
}

- (void)setupTableView {
    
    // Initilaize collection view.
    TableViewCellBlock configureCell = ^(InboxCell *cell, MessageItem *item) {
        [cell configureCell:item];
    };
    
    
    self.dataSourceInbox = [[TableViewDataSource alloc] initWithItems:@[] cellIdentifier:InboxCellIdentifier configureCellBlock:configureCell];
    self.dataSourceInbox.delegate = self;
    self.tableViewInbox.allowsMultipleSelectionDuringEditing = NO;
    
    [self.tableViewInbox setDataSource:self.dataSourceInbox];
    [self.tableViewInbox setDelegate:self];
    self.tableViewInbox.scrollsToTop = NO;
    
    // creating refresh control
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.tableViewInbox addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(loadMessages) forControlEvents:UIControlEventValueChanged];
}

- (void)loadMessages {
    
    [self.refreshControl endRefreshing];
    
    self.arrayMesages = [[self.serviceMessage getInboxMessages] mutableCopy];
    self.dataSourceInbox.items = self.arrayMesages;
    [self.tableViewInbox reloadData];
}


#pragma mark - Action Methods
- (IBAction)buttonHandlerCompose:(id)sender {
    
    [self performSegueWithIdentifier:@"fromInboxToCompose" sender:self];
}


#pragma mark - Delegate Methods -
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.selectedMessageItem = [self.dataSourceInbox itemAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"fromInboxToInboxView" sender:self];
}


#pragma mark - TableViewDataSourceDelegate Methods
- (void)deleteMessageWithIndexPath:(NSIndexPath *)indexPath {
    
    MessageItem *messageItem = [self.arrayMesages objectAtIndex:indexPath.row];
    [self.serviceMessage deleteMessageWithMessageItem:messageItem];
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewRowAction *button = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Destroy" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        NSLog(@"Action to perform with Button 1");
    }];
    button.backgroundColor = [UIColor cellDeleteButtonColor];
    
    return @[button];
}

#pragma mark - UIStoryboardSegue Methods
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"fromInboxToInboxView"]) {
        InboxMessageViewController *inboxMessageViewController = (InboxMessageViewController *)segue.destinationViewController;
        if ([inboxMessageViewController isKindOfClass:[InboxMessageViewController class]]) {
            inboxMessageViewController.messageItem = self.selectedMessageItem;
        }
    }
}

- (void)updateInboxScreen:(MessageItem *)messageItem {
    
    [self hideLoadingView];
    [self loadMessages];
}

@end
