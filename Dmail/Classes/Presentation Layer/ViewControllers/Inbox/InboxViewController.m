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
#import "ServiceGmailMessage.h"
#import "ServiceMessage.h"

// data source
#import "TableViewDataSource.h"

// view model
#import "VMInboxMessageItem.h"

// RM model
#import "RMModelMessage.h"

// view
#import "InboxCell.h"

//colors
#import "UIColor+AppColors.h"

@interface InboxViewController () <UITableViewDelegate, TableViewDataSourceDelegate, InboxCellDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableViewInbox;
@property (nonatomic, weak) IBOutlet UIView *viewInboxZero;
@property (nonatomic, weak) IBOutlet UIView *viewDeactivateScreen;
@property (nonatomic, weak) IBOutlet UIImageView *imageViewNavigationIcon;
@property (nonatomic, weak) IBOutlet UIButton *buttonRevealMenu;
@property (nonatomic, weak) IBOutlet BaseNavigationController *viewNavigation;

@property (nonatomic, strong) ServiceMessage *serviceMessage;
@property (nonatomic, strong) ServiceGmailMessage *serviceGmailMessage;
@property (nonatomic, strong) TableViewDataSource *dataSourceInbox;
@property (nonatomic, strong) InboxCell *editedCell;
@property (nonatomic, strong) VMInboxMessageItem *selectedMessage;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSMutableArray *arrayMesages;

@property (nonatomic, assign) BOOL menuHasBeenOpened;

@end

@implementation InboxViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        _serviceMessage = [[ServiceMessage alloc] init];
        _serviceGmailMessage = [[ServiceGmailMessage alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setupController];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self setupTableView];
    [self registerNotifications];
    [self loadMessages];
}


#pragma mark - Private Methods
- (void)registerNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageFetchedFromGmail) name:NotificationGmailMessageFetched object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageSentSuccess) name:NotificationNewMessageSent object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuOpened) name:NotificationMenuOpened object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuClosed) name:NotificationMenuClosed object:nil];
}

- (void)menuOpened {
    
    self.viewDeactivateScreen.hidden = NO;
}

- (void)menuClosed {
    
    if (!self.viewDeactivateScreen.hidden) {
        self.viewDeactivateScreen.hidden = YES;
    }
}

- (void)tapOnView {
    
    if (!self.viewDeactivateScreen.hidden) {
        [self.revealViewController revealToggle:self];
    }
}

- (void)setupController {
    
    UITapGestureRecognizer *tapOnView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnView)];
    [self.viewDeactivateScreen addGestureRecognizer:tapOnView];
    UITapGestureRecognizer *tapOnNavigation = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnView)];
    [self.viewNavigation addGestureRecognizer:tapOnNavigation];
    
    self.arrayMesages = [[NSMutableArray alloc] init];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [self.buttonRevealMenu addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    
    BOOL success = [self.serviceMessage hasInboxMessages];
    if (success) {
        [self showLoadingView];
        self.viewInboxZero.hidden = YES;
    }
    else {
        self.viewInboxZero.hidden = NO;
    }
}

- (void)setupTableView {
    
    // Initilaize collection view.
    TableViewCellBlock configureCell = ^(InboxCell *cell, VMInboxMessageItem *item, NSIndexPath *indexPath) {
        [cell configureCell:item];
        cell.delegate = self;
        cell.row = indexPath.row;
    };
    
    self.dataSourceInbox = [[TableViewDataSource alloc] initWithItems:@[] cellIdentifier:InboxCellIdentifier configureCellBlock:configureCell];
    self.dataSourceInbox.editing = NO;
    self.dataSourceInbox.delegate = self;
    self.tableViewInbox.allowsMultipleSelectionDuringEditing = NO;
    
    [self.tableViewInbox setDataSource:self.dataSourceInbox];
    [self.tableViewInbox setDelegate:self];
    
    // creating refresh control
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.tableViewInbox addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(loadMessages) forControlEvents:UIControlEventValueChanged];
}

- (void)loadMessages {
    
    [self.refreshControl endRefreshing];
    
    self.arrayMesages = [[self.serviceMessage getInboxMessages] mutableCopy];
    if ([self.arrayMesages count] > 0) {
        self.viewInboxZero.hidden = YES;
        self.dataSourceInbox.items = self.arrayMesages;
        [self.tableViewInbox reloadData];
    }
    [self hideLoadingView];
}

- (void)messageFetchedFromGmail {
    
    self.viewInboxZero.hidden = YES;
    NSArray *arrayNewMessages = [self.serviceMessage getInboxMessages];
    NSInteger itemIndex = 0;
    for (NSInteger i = 0; i<[arrayNewMessages count]; i++) {
        VMInboxMessageItem *item = [arrayNewMessages objectAtIndex:i];
        if ([self.arrayMesages count] > 0) {
            BOOL itemExist = NO;
            for (VMInboxMessageItem *_item in self.arrayMesages) {
                if ([item.messageId isEqualToString:_item.messageId]) {
                    itemExist = YES;
                    break;
                }
            }
            if (!itemExist) {
                itemIndex = i;
                [self.arrayMesages insertObject:item atIndex:i];
                self.dataSourceInbox.items = self.arrayMesages;
                NSArray *paths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:itemIndex inSection:0]];
                [self.tableViewInbox beginUpdates];
                [self.tableViewInbox insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationTop];
                [self.tableViewInbox endUpdates];
            }
        }
        else {
            [self.arrayMesages addObject:item];
            self.dataSourceInbox.items = self.arrayMesages;
            NSArray *paths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:itemIndex inSection:0]];
            [self.tableViewInbox beginUpdates];
            [self.tableViewInbox insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationTop];
            [self.tableViewInbox endUpdates];
        }
    }
}

- (void)messageSentSuccess {
    
    [self showMessageSentSuccess];
}


#pragma mark - Action Methods
- (IBAction)buttonHandlerCompose:(id)sender {
    
    [self performSegueWithIdentifier:@"fromInboxToCompose" sender:self];
}


#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.editedCell) {
        [self.editedCell movePanelToLeft];
    }
    self.selectedMessage = [self.dataSourceInbox itemAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"fromInboxToInboxView" sender:self];
}


#pragma mark - InboxCellDelegate Methods
- (void)messageDelete:(id)cell {
    
    NSIndexPath *indexPath = [self.tableViewInbox indexPathForCell:(InboxCell *)cell];
    VMInboxMessageItem *messageItem = [self.arrayMesages objectAtIndex:indexPath.row];
    [self.serviceMessage deleteMessageWithMessageId:messageItem.messageId completionBlock:^(id data, ErrorDataModel *error) {
        [self hideLoadingView];
        if ([data isEqual:@(YES)]) {
            [self.arrayMesages removeObjectAtIndex:indexPath.row];
            self.dataSourceInbox.items = self.arrayMesages;
            [self.tableViewInbox reloadData];
        }
        else {
            [self showErrorAlertWithTitle:@"Error!" message:@"Unable to destroy the message at this time. Please try again."];
        }
    }];
}

- (void)messageArchive:(id)cell {
    
    NSIndexPath *indexPath = [self.tableViewInbox indexPathForCell:cell];
    VMInboxMessageItem *messageItem = [self.arrayMesages objectAtIndex:indexPath.row];
    NSString *gmailID = [self.serviceMessage getGmailIDWithMessageId:messageItem.messageId];
    
    [self.serviceGmailMessage archiveMessageWithMessageId:gmailID completionBlock:^(id data, ErrorDataModel *error) {
        if (data) {
            [self messageDelete:cell];
        } else {
            [self showErrorAlertWithTitle:@"Error!" message:@"Unable to archive this message at this time. Please try again."];
        }
    }];
}

- (void)messageUnread:(id)cell {
    
    NSIndexPath *indexPath = [self.tableViewInbox indexPathForCell:cell];
    VMInboxMessageItem *messageItem = [self.arrayMesages objectAtIndex:indexPath.row];
    [self.serviceMessage unreadMessageWithMessageId:messageItem.messageId];
}

- (void)panelMovedOnRight:(id)cell {
    
    InboxCell *selectedCell = (InboxCell *)cell;
    if (self.editedCell && selectedCell.row != self.editedCell.row) {
        [self.editedCell movePanelToLeft];
        self.editedCell = (InboxCell *)cell;
    }
    if (!self.editedCell) {
        self.editedCell = (InboxCell *)cell;
    }
}


#pragma mark - UIStoryboardSegue Methods
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"fromInboxToInboxView"]) {
        InboxMessageViewController *inboxMessageViewController = (InboxMessageViewController *)segue.destinationViewController;
        if ([inboxMessageViewController isKindOfClass:[InboxMessageViewController class]]) {
            inboxMessageViewController.messageId = self.selectedMessage.messageId;
        }
    }
}

- (void)updateInboxScreen:(id)messageItem {
    
    [self hideLoadingView];
    [self loadMessages];
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
