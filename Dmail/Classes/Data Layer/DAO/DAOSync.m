//
//  DAOSync.m
//  Dmail
//
//  Created by Armen Mkrtchian on 7/7/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "DAOSync.h"

//DAO
#import "DAOProfile.h"

// network
#import "NetworkMessage.h"
#import "NetworkProfileAuth.h"

// model
#import "ModelMessage.h"
#import "ModelRecipient.h"


// local
#import <Realm.h>
#import "RMModelMessage.h"
#import "RMModelRecipient.h"
#import "RMModelProfile.h"

@interface DAOSync ()

@property (nonatomic, strong) NetworkMessage *networkMessage;
@property (nonatomic, strong) NetworkProfileAuth *networkProfileAuth;
@property (nonatomic, strong) DAOProfile *daoProfile;

@end

@implementation DAOSync
#pragma mark - Intsance Methods
- (instancetype)init {
    
    self = [super init];
    if (self) {
        _networkMessage = [[NetworkMessage alloc] init];
        _networkProfileAuth = [[NetworkProfileAuth alloc] init];
        _daoProfile = [[DAOProfile alloc] init];
    }
    
    return self;
}

- (void)syncMessagesForEmail:(NSString *)recipientEmail position:(NSNumber *)position count:(NSNumber *)count completionBlock:(CompletionBlock)completionBlock {
    
    [self.networkMessage syncMessagesForEmail:recipientEmail position:position count:count completionBlock:^(NSDictionary *data, ErrorDataModel *error) {
        if (!error) {
            RLMRealm *realm = [RLMRealm defaultRealm];
            RLMResults *resultsProfiles = [RMModelProfile allObjectsInRealm:realm];
            RMModelProfile *profile = [resultsProfiles firstObject];
            if (profile.email) {
                NSArray *recipients = data[@"recipients"];
                if ([recipients isKindOfClass:[NSArray class]]) {
                    BOOL hasNewData = NO;
                    for (NSDictionary *dict in recipients) {
                        ModelRecipient *recipient = [[ModelRecipient alloc] initWithDictionary:dict];
                        recipient.profile = recipientEmail;
                        [self saveRecipient:recipient];
                        RLMRealm *realm = [RLMRealm defaultRealm];
                        ModelMessage *message = [[ModelMessage alloc] initWithDictionary:dict];
                        message.profile = recipientEmail;//[self.daoProfile getSelectedProfileEmail];
                        RMModelMessage *tempMessage = [RMModelMessage objectInRealm:realm forPrimaryKey:message.messageId];
                        if (!tempMessage) {
                            hasNewData = YES;
                            [self saveMessage:message];
                        }
                    }
                    completionBlock(@(hasNewData), nil);
                } else {
                    completionBlock(nil, error);
                }
            }
        } else {
            completionBlock(nil, error);
        }
    }];
}

- (void)saveMessage:(ModelMessage *)modelMessage {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    if ([modelMessage.access isEqualToString:@"GRANTED"]) {
        RMModelMessage *realmModel = [[RMModelMessage alloc] initWithModel:modelMessage];
        // Add
        [realm beginWriteTransaction];
        [RMModelMessage createInRealm:realm withValue:realmModel];
        [realm commitWriteTransaction];
    } else {
        RMModelMessage *realmModel = [RMModelMessage objectInRealm:realm forPrimaryKey:modelMessage.messageId];
        // Delete all object with a transaction
        if (realmModel) {
            [realm beginWriteTransaction];
            if (realmModel) {
                [realm deleteObject:realmModel];
            }
            [realm commitWriteTransaction];
        }
    }
}

- (void)saveRecipient:(ModelRecipient *)moderlrecipient {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    RMModelRecipient *realmModel = [[RMModelRecipient alloc] initWithModel:moderlrecipient];
    // Add
    [realm beginWriteTransaction];
    [RMModelRecipient createOrUpdateInRealm:realm withValue:realmModel];
    [realm commitWriteTransaction];
}

- (void)refreshTokenWith:(NSString *)refreshToken completion:(CompletionBlock)completion {
    
    [self.networkProfileAuth refreshTokenWith:refreshToken completionBlock:^(id data, ErrorDataModel *error) {
        completion (data, error);
    }];
}

@end
