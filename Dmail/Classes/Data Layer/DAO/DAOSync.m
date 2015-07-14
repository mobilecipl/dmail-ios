//
//  DAOSync.m
//  Dmail
//
//  Created by Armen Mkrtchian on 7/7/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "DAOSync.h"

// network
#import "NetworkMessage.h"

// model
//#import "ModelDmailMessage.h"
#import "ModelMessage.h"
#import "ModelRecipient.h"


// local
#import <Realm.h>
#import "RMModelMessage.h"
#import "RMModelRecipient.h"

@interface DAOSync ()
@property (nonatomic, strong) NetworkMessage *networkMessage;
@end

@implementation DAOSync
#pragma mark - Intsance Methods
- (instancetype)init {
    
    if (self) {
        _networkMessage = [[NetworkMessage alloc] init];
    }
    
    return self;
}

- (void)syncMessagesForEmail:(NSString *)recipientEmail position:(NSNumber *)position count:(NSNumber *)count completionBlock:(CompletionBlock)completionBlock {
    
    [self.networkMessage syncMessagesForEmail:recipientEmail position:position count:count completionBlock:^(NSDictionary *data, ErrorDataModel *error) {
        if (!error) {
            NSArray *recipients = data[@"recipients"];
            if ([recipients isKindOfClass:[NSArray class]]) {
                NSMutableArray *arrayRecipients = [@[] mutableCopy];
                NSMutableArray *arrayMessages = [@[] mutableCopy];
                BOOL success = NO;
                for (NSDictionary *dict in recipients) {
                    ModelRecipient *recipient = [[ModelRecipient alloc] initWithDictionary:dict];
                    [self saveRecipient:recipient];
                    
                    RLMRealm *realm = [RLMRealm defaultRealm];
                    ModelMessage *message = [[ModelMessage alloc] initWithDictionary:dict];
                    RMModelMessage *tempMessage = [RMModelMessage objectInRealm:realm forPrimaryKey:message.messageId];
                    if (!tempMessage) {
                        success = YES;
                        [self saveMessage:message];
                    }
                }
                if (arrayRecipients.count > 0 || arrayMessages.count > 0) {
                    completionBlock(@(success), nil);
                } else {
                    completionBlock(@(success), nil);
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
            [realm deleteObject:realmModel];
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
    
//    if ([moderlrecipient.access isEqualToString:@"GRANTED"]) {
//        RMModelRecipient *realmModel = [[RMModelRecipient alloc] initWithModel:moderlrecipient];
//        // Add
//        [realm beginWriteTransaction];
//        [RMModelRecipient createOrUpdateInRealm:realm withValue:realmModel];
//        [realm commitWriteTransaction];
//    } else {
//        RMModelRecipient *realmModel = [RMModelRecipient objectInRealm:realm forPrimaryKey:moderlrecipient.serverId];
//        // Delete all object with a transaction
//        if (realmModel) {
//            [realm beginWriteTransaction];
//            [realm deleteObject:realmModel];
//            [realm commitWriteTransaction];
//        }
//    }
}

@end
