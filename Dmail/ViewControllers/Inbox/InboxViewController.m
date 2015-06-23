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
#import "CoreDataManager.h"

@class MessageItem;


@interface InboxViewController () <InboxModelDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableVIewInbox;
@property (nonatomic, strong) NSMutableArray *arrayMessgaeItems;
@property (nonatomic, strong) MessageItem *selectedMessageItem;
@property (nonatomic, strong) InboxModel *inboxModel;
@property (nonatomic, assign) MessageType messageType;

@end

@implementation InboxViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.messageType = Inbox;
//    [self getMessages];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(inboxClicked)
                                                 name:NotificationMessageInbox
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sentClicked)
                                                 name:NotificationMessageSent
                                               object:nil];
    
    self.inboxModel = [[InboxModel alloc] initWithMessageType:self.messageType];
    self.inboxModel.delegate = self;
    [self getMessages];
    [self.inboxModel getNewMessages];
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Private Methods
- (void)getMessages {
    
    [self showLoadingView];
    self.arrayMessgaeItems = [self.inboxModel getArrayMessageItems];
    if ([self.arrayMessgaeItems count] > 0) {
        [self hideLoadingView];
    }
    [self.tableVIewInbox reloadData];
}

- (void)inboxClicked {
    
    self.messageType = Inbox;
    self.inboxModel.messageType = Inbox;
    [self getMessages];
}

- (void)sentClicked {
    
    self.messageType = Sent;
    self.inboxModel.messageType = Sent;
    [self getMessages];
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
    [self performSegueWithIdentifier:@"fromInboxToInboxMessageView" sender:self];
}


#pragma mark - UIStoryboardSegue Methods
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"fromInboxToInboxMessageView"]) {
        InboxMessageViewController *inboxMessageViewController = (InboxMessageViewController *)segue.destinationViewController;
        if ([inboxMessageViewController isKindOfClass:[InboxMessageViewController class]]) {
            inboxMessageViewController.messageItem = self.selectedMessageItem;
        }
    }
}

- (void)updateInboxScreen:(MessageItem *)messageItem {
    
    [self hideLoadingView];
    [self getMessages];
}

@end
