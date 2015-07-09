//
//  DAOMessage.m
//  Dmail
//
//  Created by Armen Mkrtchian on 6/30/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "DAOMessage.h"
#import "CoreDataManager.h"
#import "GmailMessage.h"

// network
#import "NetworkMessage.h"

// model
#import "MessageItem.h"

//RealmModel
#import <Realm/Realm.h>
#import "RMModelDmailMessage.h"
#import "RMModelGmailMessage.h"

@interface DAOMessage ()
@property (nonatomic, strong) NetworkMessage *networkMessage;
@end

@implementation DAOMessage


#pragma mark - Intsance Methods
- (instancetype)init {
    
    if (self) {
        _networkMessage = [[NetworkMessage alloc] init];
    }
    
    return self;
}


#pragma mark - Public Methods
- (void)sendEncryptedMessage:(NSString *)encryptedMessage senderEmail:(NSString *)senderEmail completionBlock:(CompletionBlock)completionBlock {
    
    [self.networkMessage sendEncryptedMessage:encryptedMessage senderEmail:senderEmail completionBlock:^(id data, ErrorDataModel *error) {
        completionBlock(data, error);
    }];
}

- (void)sendRecipientEmail:(NSString *)recipientEmail key:(NSString *)key recipientType:(NSString *)recipientType messageId:(NSString *)messageId completionBlock:(CompletionBlock)completionBlock {
    
    [self.networkMessage sendRecipientEmail:recipientEmail key:key recipientType:recipientType messageId:messageId completionBlock:^(id data, ErrorDataModel *error) {
        completionBlock(data, error);
    }];
}

- (void)deleteRecipientEmail:(NSString *)recipientEmail messageId:(NSString *)messageId completionBlock:(CompletionBlock)completionBlock {
    
    [self.networkMessage deleteRecipientEmail:recipientEmail messageId:messageId completionBlock:^(id data, ErrorDataModel *error) {
        completionBlock(data, error);
    }];
}

- (void)sentEmail:(NSString *)senderEmail messageId:(NSString *)messageId messageIdentifier:(NSString *)messageIdentifier completionBlock:(CompletionBlock)completionBlock {
    
    [self.networkMessage sentEmail:senderEmail messageId:messageId messageIdentifier:messageIdentifier completionBlock:^(id data, ErrorDataModel *error) {
        completionBlock(data, error);
    }];
}

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
    [messageItem createRecipients];
    
    return messageItem;
}


- (NSArray *)getInboxMessages {
    
//    NSMutableArray *arrayItems = [[NSMutableArray alloc] init];
//    NSPredicate *predicate =  [NSPredicate predicateWithFormat:@"label == %d", Inbox];
//    
//    RLMResults *messages = [RMModelGmailMessage objectsWithPredicate:predicate];
//    for (RMModelGmailMessage *gmailMessage in messages) {
//        MessageItem *item = [[MessageItem alloc] init];
//        item.subject = @"hello dmail";
//        item.senderName = @"sender name";
//        item.fromEmail = @"armen@gmail.com";
//        item.arrayTo = @[@"armen@science.com"];
//        item.arrayCc = @[@"from.email@mail.com"];
//        item.internalDate = @0;
//        [arrayItems addObject:item];
//    }
    NSMutableArray *arrayItems = [[NSMutableArray alloc] init];
    NSPredicate *predicate =  [NSPredicate predicateWithFormat:@"label == %d", Inbox];
    
//    RLMResults *messages = [RMModelGmailMessage objectsWithPredicate:predicate];
//    for (RMModelGmailMessage *gmailMessage in messages) {
//        MessageItem *item = [[MessageItem alloc] init];
//        item.subject = @"hello dmail";
//        item.senderName = @"sender name";
//        item.fromEmail = @"armen@gmail.com";
//        item.arrayTo = @[@"armen@science.com"];
//        item.arrayCc = @[@"from.email@mail.com"];
//        item.internalDate = @0;
//        [arrayItems addObject:item];
//    }

    NSArray *arrayGmailMessages = [[CoreDataManager sharedCoreDataManager] getGmailMessagesWithType:Inbox];
    for (GmailMessage *gmailMessaeg in arrayGmailMessages) {
        MessageItem *item = [self gmailMessageToMessageItem:gmailMessaeg];
        [arrayItems addObject:item];
    }
    
    return [NSArray arrayWithArray:arrayItems];
}

- (NSArray *)getSentMessages {
    
//    MessageItem *item = [[MessageItem alloc] init];
//    item.subject = @"hello dmail";
//    item.senderName = @"sender name";
//    item.fromEmail = @"armen@gmail.com";
//    item.arrayTo = @[@"armen@science.com"];
//    item.arrayCc = @[@"from.email@mail.com"];
//    item.internalDate = @0;
//    //    item.postDate = @0;
    NSMutableArray *arrayItems = [[NSMutableArray alloc] init];
    NSArray *arrayGmailMessages = [[CoreDataManager sharedCoreDataManager] getGmailMessagesWithType:Sent];
    for (GmailMessage *gmailMessaeg in arrayGmailMessages) {
        MessageItem *item = [self gmailMessageToMessageItem:gmailMessaeg];
        [arrayItems addObject:item];
    }
    
    return [NSArray arrayWithArray:arrayItems];
}

- (NSString *)getLastGmailUniqueId {
    
    NSString *gmailUniqueId = nil;
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    NSPredicate *predicate =  [NSPredicate predicateWithFormat:@"access = %@ AND type = %@", @"GRANTED", @"SENDER"];
    RLMResults *messages = [[RMModelDmailMessage objectsInRealm:realm withPredicate:predicate]
                            sortedResultsUsingProperty:@"position" ascending:NO];
    
    for (RMModelDmailMessage *dmailMessage in messages) {
        
        // get first result
        gmailUniqueId = dmailMessage.messageIdentifier;
        break;
    }

    
    return gmailUniqueId;
}

- (NSString *)getLastGmailMessageId {
    
    NSString *gmailMessageId = nil;
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    NSPredicate *predicate =  [NSPredicate predicateWithFormat:@"gmailId != ''"];
    
    RLMResults *messages = [[RMModelDmailMessage objectsInRealm:realm where:@"gmailId != ''"]
                            sortedResultsUsingProperty:@"position" ascending:NO];
    
    for (RMModelDmailMessage *dmailMessage in messages) {
        
        // get first result
        gmailMessageId = dmailMessage.gmailId;
        break;
    }
    
    
    return gmailMessageId;
}
@end
