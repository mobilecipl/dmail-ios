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


@interface InboxViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableVIewInbox;
@property (nonatomic, strong) NSArray *arrayMessgaes;
@property (nonatomic, strong) NSDictionary *dictCurrentCellItem;
@property (nonatomic, assign) MessageType messageType;

@end

@implementation InboxViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.messageType = Inbox;
    
//    [self showLoadingView];
//    InboxModel *inboxModel = [[InboxModel alloc] initWithMessageType:self.messageType];
//    [inboxModel getMessageListWithPosition:0 count:100 senderEmail:[[UserService sharedInstance] email] withCompletionBlock:^(NSArray *arrayMessages, NSInteger statusCode) {
//        [self hideLoadingView];
//        if ([arrayMessages count] > 0) {
//            [self.tableVIewInbox reloadData];
//        }
//        else {
//            // Need to implement
//            switch (statusCode) {
//                case 0:
//                    
//                    break;
//                    
//                default:
//                    break;
//            }
//        }
//    }];

    NSMutableArray *arrayMessageItems = [[NSMutableArray alloc] init];
    for (NSInteger i = 1; i <= 10; ++i) {
        NSDictionary *dictInboxItem = @{SenderName : [NSString stringWithFormat:@"Name %ld", (long)i],
                                        MessageSubject : [NSString stringWithFormat:@"Message subject %ld", (long)i],
                                        MessageDate : [NSString stringWithFormat:@"%ld", (long)i],
                                        MessageGmailUniqueId : [NSString stringWithFormat:@"%ld", (long)i]};
        [arrayMessageItems addObject:dictInboxItem];
    }
    
    self.arrayMessgaes = [NSArray arrayWithArray:arrayMessageItems];
    [self.tableVIewInbox reloadData];
}


#pragma mark - Action Methods
- (IBAction)buttonHandlerMenu:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMenuButton object:nil];
}

- (IBAction)buttonHandlerCompose:(id)sender {
    
    [self performSegueWithIdentifier:@"fromInboxToCompose" sender:self];
}


#pragma mark - TableView DataSource & Delegate Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.arrayMessgaes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    InboxCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InboxCellID"];
    [cell configureCell:[self.arrayMessgaes objectAtIndex:indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.dictCurrentCellItem = [self.arrayMessgaes objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"fromInboxToInboxMessageView" sender:self];
}


#pragma mark - UIStoryboardSegue Methods
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"fromInboxToInboxMessageView"]) {
        InboxMessageViewController *inboxMessageViewController = (InboxMessageViewController *)segue.destinationViewController;
        if ([inboxMessageViewController isKindOfClass:[InboxMessageViewController class]]) {
            inboxMessageViewController.dictionaryMessage = self.dictCurrentCellItem;
        }
    }
}


@end
