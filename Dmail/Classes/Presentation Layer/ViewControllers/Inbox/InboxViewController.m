//
//  InboxViewController.m
//  Dmail
//
//  Created by Gevorg Ghukasyan on 6/12/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "InboxViewController.h"
#import "SWRevealViewController.h"

// controller
#import "ComposeViewController.h"
#import "InboxMessageViewController.h"
#import "SentMessageViewController.h"

// service
#import "ServiceMessage.h"

// data source
#import "TableViewDataSource.h"

// model
#import "MessageItem.h"

// view
#import "InboxCell.h"

@interface InboxViewController () <UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableViewInbox;
@property (weak, nonatomic) IBOutlet UILabel *labelNavigationTitle;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewNavigationIcon;
@property (weak, nonatomic) IBOutlet UIButton *buttonRevealMenu;

@property (strong, nonatomic) ServiceMessage *serviceMessage;

@property (strong, nonatomic) TableViewDataSource *dataSourceInbox;

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (nonatomic, strong) MessageItem *selectedMessageItem;

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(inboxClicked)
                                                 name:NotificationMessageInbox
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sentClicked)
                                                 name:NotificationMessageSent
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadMessages)
                                                 name:NotificationNewMessageFetched
                                               object:nil];
}

- (void)setupTableView {
    
    [self.buttonRevealMenu addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    // Initilaize collection view.
    TableViewCellBlock configureCell = ^(InboxCell *cell, MessageItem *item) {
        [cell configureCell:item];
    };
    
    
    self.dataSourceInbox = [[TableViewDataSource alloc] initWithItems:@[] cellIdentifier:InboxCellIdentifier configureCellBlock:configureCell];
    
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
    
    self.dataSourceInbox.items = [[self.serviceMessage getInboxMessages] mutableCopy];
    [self.tableViewInbox reloadData];
}

- (void)inboxClicked {
    
    [self setupController];
    [self loadMessages];
}

- (void)sentClicked {
    
    [self setupController];
    [self loadMessages];
}

- (void)setupController {
    
//    if (self.messageType == Inbox) {
//        self.imageViewNavigationIcon.hidden = NO;
//        self.labelNavigationTitle.hidden = YES;
//    }
//    else {
//        self.imageViewNavigationIcon.hidden = YES;
//        self.labelNavigationTitle.hidden = NO;
//    }
}


#pragma mark - Action Methods
- (IBAction)buttonHandlerMenu:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationMenuButton object:nil];
}

- (IBAction)buttonHandlerCompose:(id)sender {
    
    [self performSegueWithIdentifier:@"fromInboxToCompose" sender:self];
}


#pragma mark - Delegate Methods -
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.selectedMessageItem = [self.dataSourceInbox itemAtIndexPath:indexPath];
    if (self.selectedMessageItem.label == Inbox) {
        
        [self performSegueWithIdentifier:@"fromInboxToInboxMessageView" sender:self];
    }
    else {
        
        [self performSegueWithIdentifier:@"fromInboxToSentView" sender:self];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //TODO:
//    [self.inboxModel deleteMessageWithMessageItem:[self.arrayMessgaeItems objectAtIndex:indexPath.row]];
    [self.dataSourceInbox removeItemAtIndex:indexPath];
    [self.tableViewInbox reloadData];
}


#pragma mark - UIStoryboardSegue Methods
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"fromInboxToInboxMessageView"]) {
        InboxMessageViewController *inboxMessageViewController = (InboxMessageViewController *)segue.destinationViewController;
        if ([inboxMessageViewController isKindOfClass:[InboxMessageViewController class]]) {
            inboxMessageViewController.messageItem = self.selectedMessageItem;
        }
    }
    else if ([segue.identifier isEqualToString:@"fromInboxToSentView"]) {
        SentMessageViewController *sentMessageVC = (SentMessageViewController *)segue.destinationViewController;
        if ([SentMessageViewController isKindOfClass:[SentMessageViewController class]]) {
            sentMessageVC.messageItem = self.selectedMessageItem;
        }
    }
}

- (void)updateInboxScreen:(MessageItem *)messageItem {
    
    [self hideLoadingView];
    [self loadMessages];
}

@end
