//
//  DAOGmailMessage.m
//  Dmail
//
//  Created by Gevorg Ghukasyan on 7/7/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "DAOGmailMessage.h"
#import "DAOProfile.h"

// google
//#import <GoogleSignIn/GoogleSignIn.h>

// network
#import "NetworkGmailMessage.h"

// model
#import "ModelGmailMessage.h"
#import "ModelMessage.h"

// local storage
#import <Realm/Realm.h>

#import "RMModelMessage.h"
#import "RMModelRecipient.h"
#import "RMModelProfile.h"

@interface DAOGmailMessage ()

@property (nonatomic, strong) NetworkGmailMessage *networkGmailMessage;
@property (nonatomic, strong) DAOProfile *daoProfile;

@end

@implementation DAOGmailMessage

- (instancetype)init {
    
    self = [super init];
    if (self) {
        _networkGmailMessage = [[NetworkGmailMessage alloc] init];
        _daoProfile = [[DAOProfile alloc] init];
    }
    
    return self;
}

- (void)getMessageIdWithUniqueId:(NSString *)messageIdentifier profileEmail:(NSString *)profileEmail userId:(NSString *)userID serverId:(NSString *)serverId token:(NSString *)token completionBlock:(CompletionBlock)completionBlock {
    
    [self.networkGmailMessage getMessageIdWithUniqueId:messageIdentifier userId:userID token:token completionBlock:^(id data, ErrorDataModel *error) {
        if (!error) {
            NSArray *messages = data[@"messages"];
            if ([messages isKindOfClass:[NSArray class]]) {
                for (NSDictionary *dict in messages) {
                    NSString *gmailId = dict[@"id"];
                    RLMRealm *realm = [RLMRealm defaultRealm];
                    RLMResults *resultsProfiles = [RMModelProfile allObjectsInRealm:realm];
                    RMModelProfile *profile = [resultsProfiles firstObject];
                    if (gmailId && profile.email) {
                        [self updateMessageWithUniqueId:messageIdentifier gmailId:gmailId serverId:serverId profileEmail:profileEmail];
                    }
                }
                completionBlock(@(YES), nil);
            } else {
                [self deleteMessageWithIdentifier:messageIdentifier profileEmail:profileEmail];
                [self deleteRecipientsWithIdentifier:messageIdentifier profileEmail:profileEmail];
                completionBlock(@(NO), nil);
            }
        } else {
            completionBlock(@(NO), error);
        }
    }];
}

- (void)getMessageWithMessageId:(NSString *)messageId profileEmail:(NSString *)profileEmail userId:(NSString *)userID completionBlock:(CompletionBlock)completionBlock {
    
    NSString *token = [self.daoProfile getSelectedProfileToken];
    [self.networkGmailMessage getMessageWithMessageId:messageId userId:userID token:token completionBlock:^(NSDictionary *data, ErrorDataModel *error) {
        RLMRealm *realm = [RLMRealm defaultRealm];
        RLMResults *resultsProfiles = [RMModelProfile allObjectsInRealm:realm];
        RMModelProfile *profile = [resultsProfiles firstObject];
        if(profile.email) {
            if (!error) {
                ModelGmailMessage *modelGmailMessage = [[ModelGmailMessage alloc] initWithDictionary:data];
                NSLog(@"================ profileEmail ==================== %@", profileEmail);
                [self updateMessageWithGmailId:messageId gmailModel:modelGmailMessage profileEmail:profileEmail];
                completionBlock(modelGmailMessage.payload.messageIdentifier, nil);
            } else {
                completionBlock(nil, error);
            }
        }
    }];
}

- (void)sendWithEncodedBody:(NSString *)encodedBody userId:(NSString *)userID token:(NSString *)token completionBlock:(CompletionBlock)completionBlock {
    
    [self.networkGmailMessage sendWithEncodedBody:encodedBody userId:userID token:token completionBlock:^(id data, ErrorDataModel *error) {
        completionBlock(data, error);
    }];
}


- (void)updateMessageWithUniqueId:(NSString *)uniqueId gmailId:(NSString *)gmailId serverId:(NSString *)serverId profileEmail:(NSString *)profileEmail {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    RLMResults *results = [RMModelMessage objectsInRealm:realm where:@"serverId = %@ AND profile = %@", serverId, profileEmail];
    [realm beginWriteTransaction];
    for (RMModelMessage *realmModel in results) {
        realmModel.gmailId = gmailId;
        realmModel.status = MessageFetchedOnlyGmailIds;
    }
    [realm commitWriteTransaction];
}

- (void)deleteMessageWithIdentifier:(NSString *)identifier profileEmail:(NSString *)profileEmail {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    RLMResults *results = [RMModelMessage objectsInRealm:realm where:@"messageIdentifier = %@ AND profile = %@", identifier, profileEmail];
    [realm beginWriteTransaction];
    [realm deleteObjects:results];
    [realm commitWriteTransaction];
}

- (void)deleteRecipientsWithIdentifier:(NSString *)identifier profileEmail:(NSString *)profileEmail {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    RLMResults *results = [RMModelRecipient objectsInRealm:realm where:@"messageIdentifier = %@ AND email = %@", identifier, profileEmail];
    [realm beginWriteTransaction];
    [realm deleteObjects:results];
    [realm commitWriteTransaction];
}

- (void)updateMessageWithGmailId:(NSString *)gmailId gmailModel:(ModelGmailMessage *)modelGmailMessage profileEmail:(NSString *)profileEmail {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    RLMResults *results = [RMModelMessage objectsInRealm:realm where:@"gmailId = %@ AND profile = %@", gmailId, profileEmail];
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
    if ([modelGmailMessage.arrayLabels containsObject:@"UNREAD"]) {
        rmMessage.read = NO;
    }
    else {
        rmMessage.read = YES;
    }
    [realm commitWriteTransaction];
}

- (void)deleteWithGmailId:(NSString *)gmailId userId:(NSString *)userID token:(NSString *)token completionBlock:(CompletionBlock)completionBlock {
    
    [self.networkGmailMessage deleteWithGmailId:gmailId userId:userID token:Token completionBlock:^(id data, ErrorDataModel *error) {
        completionBlock(data, error);
    }];
}

- (void)getMessageLabelsWithMessageId:(NSString *)messageID completionBlock:(CompletionBlock)completionBlock {
    
    NSString *userID = [self.daoProfile getSelectedProfileUserId];//[[[GIDSignIn sharedInstance].currentUser valueForKeyPath:@"userID"] description];
    NSString *token = [self.daoProfile getSelectedProfileToken];
    
    [self.networkGmailMessage getMessageLabelsWithMessageId:messageID userId:userID token:token completionBlock:^(NSDictionary *data, ErrorDataModel *error) {
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
    
    NSString *userID = [self.daoProfile getSelectedProfileUserId];
    NSString *token = [self.daoProfile getSelectedProfileToken];
    [self.networkGmailMessage deleteMessageLabels:labels messageId:messageID userId:userID token:token completionBlock:^(id data, ErrorDataModel *error) {
        completionBlock(data, error);
    }];
}

@end
