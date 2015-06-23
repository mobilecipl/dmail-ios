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
#import "DmailMessage.h"
#import "UserService.h"


@interface InboxModel ()

@property (nonatomic, strong) NSMutableArray *arrayMessages;

@end

@implementation InboxModel

- (id)initWithMessageType:(MessageType)messageType {
    
    self = [super init];
    if (self != nil) {
        self.messageType = messageType;
    }
    
    return  self;
}

#pragma mark - Private Methods
- (MessageItem *)dmailMessageToMessageItem:(DmailMessage *)dmailMessage {
    
    MessageItem *messageItem = [[MessageItem alloc] init];
    messageItem.type = [dmailMessage.type integerValue];
    messageItem.identifier = dmailMessage.identifier;
    messageItem.dmailId = dmailMessage.dmailId;
    messageItem.subject = dmailMessage.subject;
    messageItem.senderName = dmailMessage.senderName;
    messageItem.status = [dmailMessage.status integerValue];
    
    return messageItem;
}

#pragma mark - Public Methods
- (NSMutableArray *)getArrayMessageItems {
    
    NSArray *arrayDmailMessages = [[CoreDataManager sharedCoreDataManager] getMessagesWithType:self.messageType];
    NSMutableArray *arrayMessageItems = [[NSMutableArray alloc] init];
    for (DmailMessage *dmailMessage in arrayDmailMessages) {
        MessageItem *messageItem = [self dmailMessageToMessageItem:dmailMessage];
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
