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
#import "ProfileService.h"


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
    messageItem.gmailId = gmailMessage.gmailId;
    messageItem.internalDate = gmailMessage.internalDate;
    messageItem.subject = gmailMessage.subject;
    messageItem.fromEmail = gmailMessage.from;
    messageItem.type = [gmailMessage.type integerValue];
    messageItem.fromEmail = gmailMessage.from;
    messageItem.arrayTo = [gmailMessage.to componentsSeparatedByString:@","];
    messageItem.arrayCc = [gmailMessage.cc componentsSeparatedByString:@","];
    messageItem.arrayBcc = [gmailMessage.bcc componentsSeparatedByString:@","];
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

- (void)deleteMessageWithMessageItem:(MessageItem *)item {
    
    [[CoreDataManager sharedCoreDataManager] removeGmailMessageWithDmailId:item.dmailId];
    [[CoreDataManager sharedCoreDataManager] removeDmailMessageWithDmailId:item.dmailId];
    [[MessageService sharedInstance] deleteMessageWithGmailId:item.gmailId completionBlock:^(BOOL success) {
        
    }];
}

@end
