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
#import "CustomAlertView.h"

//colors
#import "UIColor+AppColors.h"

#import <Realm/Realm.h>
#import "RMModelRecipient.h"


@interface SentViewController () <UITableViewDelegate, TableViewDataSourceDelegate, CustomAlertViewDelegate>

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
@property (nonatomic, strong) VMSentMessageItem *destroyedMessageItem;

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
    [self registerNotifications];
    [self loadMessages];
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Private Methods
- (void)registerNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadMessages) name:NotificationGmailMessageFetched object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageDestroyedSuccess:) name:NotificationDestroySuccess object:nil];
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
    
    if (!self.viewDeactivateScreen.hidden) {
        [self.revealViewController revealToggle:self];
    }
}

- (void)setupController {
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
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
    self.dataSourceInbox.editing = YES;
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

- (void)messageDestroyedSuccess:(NSNotification *)notification {
    
    NSString *messageId = [[notification userInfo] valueForKey:@"messageId"];
    for (NSInteger i = 0; i <[self.arrayMesages count]; i++) {
        VMSentMessageItem *item = [self.arrayMesages objectAtIndex:i];
        if ([item.messageId isEqualToString:messageId]) {
            [self.arrayMesages removeObject:item];
            self.dataSourceInbox.items = self.arrayMesages;
            NSArray *paths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:i inSection:0]];
            [self.tableViewSent beginUpdates];
            [self.tableViewSent deleteRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationTop];
            [self.tableViewSent endUpdates];
        }
    }
    
    [self hideLoadingView];
    [self showPanelMessageDestroyedSuccess];
}

- (void)messageDestroyedFailed {
    
    [self hideLoadingView];
    [self showErrorAlertWithTitle:@"Error!" message:@"Unable to destroy the message at this time. Please try again."];
}

- (void)messageSentSuccess {
    
    [self showMessageSentSuccess];
}

- (void)updateInboxScreen:(id)messageItem {
    
    [self hideLoadingView];
    [self loadMessages];
}

- (void)showDestroyAlert {
    
    CustomAlertView *alertView = [[CustomAlertView alloc] initWithTitle:@"Destroy message"
                                                               withFont:@"ProximaNova-Semibold"
                                                               withSize:20
                                                            withMessage:@"Are you sure you want to destroy this message?"
                                                        withMessageFont:@"ProximaNova-Regular"
                                                    withMessageFontSize:15
                                                         withDeactivate:NO];
    NSDictionary *cancelButton = @{@"title" : @"Cancel",
                                   @"titleColor" : [UIColor whiteColor],
                                   @"backgroundColor" : [UIColor colorWithRed:120.0/255.0 green:132.0/255.0 blue:140.0/255.0 alpha:1],
                                   @"font" : @"ProximaNova-Regular",
                                   @"fontSize" : @"15"};
    NSDictionary *destroyButton = @{@"title" : @"Destroy",
                                    @"titleColor" : [UIColor whiteColor],
                                    @"backgroundColor" : [UIColor colorWithRed:215.0/255.0 green:34.0/255.0 blue:106.0/255.0 alpha:1],
                                    @"font" : @"ProximaNova-Regular",
                                    @"fontSize" : @"15"};
    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:cancelButton,destroyButton, nil]];
    [alertView setDelegate:self];
    [alertView setOnButtonTouchUpInside:^(CustomAlertView *alertView, int buttonIndex) {
        [alertView close];
    }];
    [alertView setUseMotionEffects:true];
    [alertView show];
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

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewRowAction *button = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Destroy" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        self.destroyedMessageItem = [self.arrayMesages objectAtIndex:indexPath.row];
        [self showDestroyAlert];
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


#pragma mark - CustomAlertViewDelegate Methods
- (void)customIOS7dialogButtonTouchUpInside: (CustomAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    [self showLoadingView];
    [alertView close];
    if (buttonIndex == 1) {
        [self.serviceMessage destroyMessageWithMessageId:self.destroyedMessageItem.messageId fromSentList:YES];
    }
    else {
        [self hideLoadingView];
    }
}

@end
