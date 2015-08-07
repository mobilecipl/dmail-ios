//
//  DAOGmailMessage.m
//  Dmail
//
//  Created by Gevorg Ghukasyan on 7/7/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "DAOGmailMessage.h"

// google
#import <GoogleSignIn/GoogleSignIn.h>

// network
#import "NetworkGmailMessage.h"

// model
#import "ModelGmailMessage.h"
#import "ModelMessage.h"

// local storage
#import <Realm/Realm.h>

#import "RMModelMessage.h"
#import "RMModelRecipient.h"

@interface DAOGmailMessage ()

@property (nonatomic, strong) NetworkGmailMessage *networkGmailMessage;

@end

@implementation DAOGmailMessage

- (instancetype)init {
    
    if (self) {
        _networkGmailMessage = [[NetworkGmailMessage alloc] init];
    }
    
    return self;
}

- (void)getMessageIdWithUniqueId:(NSString *)messageIdentifier userId:(NSString *)userID serverId:(NSString *)serverId completionBlock:(CompletionBlock)completionBlock {
    
    [self.networkGmailMessage getMessageIdWithUniqueId:messageIdentifier userId:userID completionBlock:^(id data, ErrorDataModel *error) {
        if (!error) {
            NSArray *messages = data[@"messages"];
            if ([messages isKindOfClass:[NSArray class]]) {
                for (NSDictionary *dict in messages) {
                    NSString *gmailId = dict[@"id"];
                    if (gmailId) {
                        [self updateMessageWithUniqueId:messageIdentifier gmailId:gmailId serverId:serverId];
                    }
                }
                completionBlock(nil, nil);
            } else {
                [self deleteMessageWithIdentifier:messageIdentifier];
                [self deleterecipientsWithIdentifier:messageIdentifier];
                completionBlock(nil, nil);
            }
        } else {
            completionBlock(nil, error);
        }
    }];
}

- (void)getMessageWithMessageId:(NSString *)messageId userId:(NSString *)userID completionBlock:(CompletionBlock)completionBlock {
    
    [self.networkGmailMessage getMessageWithMessageId:messageId userId:userID completionBlock:^(NSDictionary *data, ErrorDataModel *error) {
        if (!error) {
            ModelGmailMessage *modelGmailMessage = [[ModelGmailMessage alloc] initWithDictionary:data];
            [self updateMessageWithGmailId:messageId gmailModel:modelGmailMessage];
            completionBlock(modelGmailMessage.payload.messageIdentifier, nil);
        } else {
            completionBlock(nil, error);
        }
    }];
}

- (void)sendWithEncodedBody:(NSString *)encodedBody userId:(NSString *)userID completionBlock:(CompletionBlock)completionBlock {
    
    [self.networkGmailMessage sendWithEncodedBody:encodedBody userId:userID completionBlock:^(id data, ErrorDataModel *error) {
        completionBlock(data, error);
    }];
}


- (void)updateMessageWithUniqueId:(NSString *)uniqueId gmailId:(NSString *)gmailId serverId:(NSString *)serverId {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    RLMResults *results = [RMModelMessage objectsInRealm:realm where:@"serverId = %@", serverId];
    [realm beginWriteTransaction];
    for (RMModelMessage *realmModel in results) {
        realmModel.gmailId = gmailId;
        realmModel.status = MessageFetchedOnlyGmailIds;
    }
    [realm commitWriteTransaction];
}

- (void)deleteMessageWithIdentifier:(NSString *)identifier {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    RLMResults *results = [RMModelMessage objectsInRealm:realm where:@"messageIdentifier = %@", identifier];
    [realm beginWriteTransaction];
    [realm deleteObjects:results];
    [realm commitWriteTransaction];
}

- (void)deleterecipientsWithIdentifier:(NSString *)identifier {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    RLMResults *results = [RMModelRecipient objectsInRealm:realm where:@"messageIdentifier = %@", identifier];
    [realm beginWriteTransaction];
    [realm deleteObjects:results];
    [realm commitWriteTransaction];
}

- (void)saveMessageInRealm:(ModelMessage *)modelMessage {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    RMModelMessage *realmModel = [[RMModelMessage alloc] initWithModel:modelMessage];
    [realm beginWriteTransaction];
    [RMModelMessage createOrUpdateInRealm:realm withValue:realmModel];
    [realm commitWriteTransaction];
}

- (void)updateMessageWithGmailId:(NSString *)gmailId gmailModel:(ModelGmailMessage *)modelGmailMessage{
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    RLMResults *results = [RMModelMessage objectsInRealm:realm where:@"gmailId = %@", gmailId];
    RMModelMessage *rmMessage = [results firstObject];
    [realm beginWriteTransaction];
    rmMessage.messageIdentifier = modelGmailMessage.payload.messageIdentifier;
    rmMessage.access = @"GRANTED";
    rmMessage.subject = modelGmailMessage.payload.subject;
    rmMessage.fromName = modelGmailMessage.payload.fromName;
    rmMessage.fromEmail = modelGmailMessage.payload.fromEmail;
    rmMessage.publicKey = modelGmailMessage.publicKey;
    rmMessage.internalDate = [modelGmailMessage.internalDate longLongValue];
    rmMessage.status = MessageFetchedFull;
    [realm commitWriteTransaction];
}

- (void)deleteWithGmailId:(NSString *)gmailId userId:(NSString *)userID completionBlock:(CompletionBlock)completionBlock {
    
    [self.networkGmailMessage deleteWithGmailId:gmailId userId:userID completionBlock:^(id data, ErrorDataModel *error) {
        completionBlock(data, error);
    }];
}

- (void)getMessageLabelsWithMessageId:(NSString *)messageID completionBlock:(CompletionBlock)completionBlock {
    
    NSString *userID = [[[GIDSignIn sharedInstance].currentUser valueForKeyPath:@"userID"] description];
    
    [self.networkGmailMessage getMessageLabelsWithMessageId:messageID userId:userID completionBlock:^(NSDictionary *data, ErrorDataModel *error) {
        if (!error) {
            if ([data[@"labelIds"] isKindOfClass:[NSArray class]]) {
                completionBlock(data[@"labelIds"], nil);
            } else {
                completionBlock(nil, error);
            }
        } else {
            completionBlock(nil, error);
        }
    }];
}

- (void)deleteMessageLabels:(NSArray *)labels messageId:(NSString *)messageID completionBlock:(CompletionBlock)completionBlock {
    
    NSString *userID = [[[GIDSignIn sharedInstance].currentUser valueForKeyPath:@"userID"] description];
    [self.networkGmailMessage deleteMessageLabels:labels messageId:messageID userId:userID completionBlock:^(id data, ErrorDataModel *error) {
        completionBlock(data, error);
    }];
}

@end
