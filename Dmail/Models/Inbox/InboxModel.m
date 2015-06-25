//
//  InboxModel.m
//  Dmail
//
//  Created by Karen Petrosyan on 6/18/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "InboxModel.h"
#import "NetworkManager.h"
#import "MessageService.h"
#import "CoreDataManager.h"
#import "MessageItem.h"
#import "GmailMessage.h"
#import "UserService.h"


@interface InboxModel ()

@property (nonatomic, strong) NSMutableArray *arrayMessages;

@end

@implementation InboxModel

- (id)initWithMessageLabel:(MessageLabel)messageLabel {
    
    self = [super init];
    if (self != nil) {
        self.messageLabel = messageLabel;
    }
    
    return  self;
}

#pragma mark - Private Methods
- (MessageItem *)gmailMessageToMessageItem:(GmailMessage *)gmailMessage {
    
    MessageItem *messageItem = [[MessageItem alloc] init];
    messageItem.identifier = gmailMessage.identifier;
    messageItem.dmailId = gmailMessage.dmailId;
    messageItem.subject = gmailMessage.subject;
    messageItem.senderName = gmailMessage.senderName;
    messageItem.senderEmail = gmailMessage.senderEmail;
    messageItem.status = [gmailMessage.status integerValue];
    messageItem.type = [gmailMessage.type integerValue];
    messageItem.label = [gmailMessage.label integerValue];
    
    return messageItem;
}

#pragma mark - Public Methods
- (NSMutableArray *)getArrayMessageItems {
    
    NSArray *arrayDmailMessages = [[CoreDataManager sharedCoreDataManager] getGmailMessagesWithType:self.messageLabel];
    NSMutableArray *arrayMessageItems = [[NSMutableArray alloc] init];
    for (GmailMessage *gmailMessage in arrayDmailMessages) {
        MessageItem *messageItem = [self gmailMessageToMessageItem:gmailMessage];
        [arrayMessageItems addObject:messageItem];
    }
    
    return arrayMessageItems;
}


#pragma mark - Delegate Methods
- (void)updateInboxScreen:(MessageItem *)messageItem {
    
    if ([self.delegate respondsToSelector:@selector(updateInboxScreen:)]) {
        [self.delegate updateInboxScreen:messageItem];
    }
}

@end
