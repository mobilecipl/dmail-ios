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
#import "ModelMessage.h"
#import "MessageItem.h"

// view model
#import "VMInboxMessage.h"

//RealmModel
#import <Realm/Realm.h>
#import "RMModelMessage.h"
#import "RMModelDmailMessage.h"
#import "RMModelGmailMessage.h"
#import "RMModelContact.h"
//#import "RMModelProfile.h"


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
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    // TODO: get only inbox messages
    RLMResults *messages = [RMModelMessage allObjectsInRealm:realm];
    
    NSMutableArray *arrayItems = [@[] mutableCopy];
    
    for (RMModelMessage *rmMessage in messages) {
        
        ModelMessage *modelMessage = [self getMessageWithIdentifier:rmMessage.messageIdentifier];
        if (modelMessage) {
            [arrayItems addObject:modelMessage];
        }
    }
    
    return arrayItems;
}


- (NSArray *)getSentMessages {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    // TODO: get only sent messages
    RLMResults *messages = [RMModelMessage allObjectsInRealm:realm];
    
    NSMutableArray *arrayItems = [@[] mutableCopy];
    
    for (RMModelMessage *rmMessage in messages) {
        
        ModelMessage *modelMessage = [self getMessageWithIdentifier:rmMessage.messageIdentifier];
        if (modelMessage) {
            [arrayItems addObject:modelMessage];
        }
    }
    
    return arrayItems;
}



- (ModelMessage *)getMessageWithIdentifier:(NSString *)identifier {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    RLMResults *resultsGmailMessages = [RMModelGmailMessage objectsInRealm:realm where:@"messageIdentifier = %@", identifier];
    RMModelGmailMessage *gmailMessage = [resultsGmailMessages firstObject];
    
    RLMResults *resultsDmailMessages = [RMModelDmailMessage objectsInRealm:realm where:@"messageIdentifier = %@", identifier];
    RMModelDmailMessage *dmailMessage = [resultsDmailMessages firstObject];
    
    RMModelContact *contact = [RMModelContact objectInRealm:realm forPrimaryKey:gmailMessage.fromEmail];
    
    ModelMessage *modelMessage = [[ModelMessage alloc] init];
    modelMessage.messageIdentifier = identifier;
    modelMessage.internalDate = gmailMessage.internalDate;
    modelMessage.dmailId = dmailMessage.dmailId;
    modelMessage.gmailId = dmailMessage.gmailId;
    modelMessage.type = dmailMessage.type;
    modelMessage.read = gmailMessage.read;
    modelMessage.to = gmailMessage.to;
//        self.cc = gmailMessage.cc;
//        self.bcc = gmailMessage.bcc;
    
    modelMessage.subject = gmailMessage.subject;
    modelMessage.from = gmailMessage.fromName;
    
    if (contact.imageUrl) {
        modelMessage.imageUrl = contact.imageUrl;
    }
    
    return modelMessage;
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
