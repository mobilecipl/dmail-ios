//
//  InboxViewController.m
//  Dmail
//
//  Created by Gevorg Ghukasyan on 6/12/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "InboxViewController.h"
#import "Configurations.h"
#import "ComposeViewController.h"
#import "InboxModel.h"
#import "InboxCell.h"
#import "InboxMessageViewController.h"
#import "SentViewController.h"
#import "CoreDataManager.h"

@class MessageItem;


@interface InboxViewController () <InboxModelDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableVIewInbox;
@property (weak, nonatomic) IBOutlet UILabel *labelNavigationTitle;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewNavigationIcon;
@property (nonatomic, strong) NSMutableArray *arrayMessgaeItems;
@property (nonatomic, strong) MessageItem *selectedMessageItem;
@property (nonatomic, strong) InboxModel *inboxModel;
@property (nonatomic, assign) MessageLabel messageType;

@end

@implementation InboxViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.messageType = Inbox;
    self.inboxModel = [[InboxModel alloc] initWithMessageLabel:self.messageType];
    self.tableVIewInbox.allowsMultipleSelectionDuringEditing = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self registerNotifications];
    [self getMessages];
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
                                             selector:@selector(getMessages)
                                                 name:NotificationNewMessageFetched
                                               object:nil];
}

- (void)getMessages {
    
    self.arrayMessgaeItems = [self.inboxModel getArrayMessageItems];
    [self.tableVIewInbox reloadData];
}

- (void)inboxClicked {
    
    self.messageType = Inbox;
    self.inboxModel.messageLabel = Inbox;
    [self setupController];
    [self getMessages];
}

- (void)sentClicked {
    
    self.messageType = Sent;
    self.inboxModel.messageLabel = Sent;
    [self setupController];
    [self getMessages];
}

- (void)setupController {
    
    if (self.messageType == Inbox) {
        self.imageViewNavigationIcon.hidden = NO;
        self.labelNavigationTitle.hidden = YES;
    }
    else {
        self.imageViewNavigationIcon.hidden = YES;
        self.labelNavigationTitle.hidden = NO;
    }
}

#pragma mark - Action Methods
- (IBAction)buttonHandlerMenu:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationMenuButton object:nil];
}

- (IBAction)buttonHandlerCompose:(id)sender {
    
    [self performSegueWithIdentifier:@"fromInboxToCompose" sender:self];
}


#pragma mark - TableView DataSource & Delegate Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.arrayMessgaeItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    InboxCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InboxCellID"];
    [cell configureCell:[self.arrayMessgaeItems objectAtIndex:indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.selectedMessageItem = [self.arrayMessgaeItems objectAtIndex:indexPath.row];
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
    
    [self.inboxModel deleteMessageWithMessageItem:[self.arrayMessgaeItems objectAtIndex:indexPath.row]];
    [self.arrayMessgaeItems removeObjectAtIndex:indexPath.row];
    [self.tableVIewInbox reloadData];
//    [tableView beginUpdates];
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationTop];
//    }
//    [tableView endUpdates];
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
        SentViewController *sentViewController = (SentViewController *)segue.destinationViewController;
        if ([sentViewController isKindOfClass:[sentViewController class]]) {
            sentViewController.messageItem = self.selectedMessageItem;
        }
    }
}

- (void)updateInboxScreen:(MessageItem *)messageItem {
    
    [self hideLoadingView];
    [self getMessages];
}

@end
