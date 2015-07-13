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
                NSMutableArray *dataArray = [@[] mutableCopy];
                for (NSDictionary *dict in recipients) {
                    ModelMessage *message = [[ModelMessage alloc] initWithDictionary:dict];
                    message.status = MessageFetchedOnlyDmailIds;
                    RLMRealm *realm = [RLMRealm defaultRealm];
                    RMModelMessage *tempModel = [RMModelMessage objectInRealm:realm forPrimaryKey:message.serverId];
                    if (tempModel) {
                        ModelMessage *tempMessage = [[ModelMessage alloc] initWithRealm:tempModel];
                        message.gmailId = tempMessage.gmailId;
                        if (message) {
                            [dataArray addObject:tempMessage];
                        }
                    } else {
                        if (message) {
                            [dataArray addObject:message];
                        }
                    }
                }
                if (dataArray.count > 0) {
                    [self saveRecipientsInRealm:dataArray];
                    completionBlock(@(YES), nil);
                } else {
                    completionBlock(@(NO), nil);
                }
            }
        } else {
            completionBlock(nil, error);
        }
    }];
}

- (void)saveRecipientsInRealm:(NSArray *)dataArray {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    for (ModelMessage *model in dataArray) {
        if ([model.access isEqualToString:@"GRANTED"]) {
            RMModelMessage *realmModel = [[RMModelMessage alloc] initWithModel:model];
            // Add
            [realm beginWriteTransaction];
            [RMModelMessage createOrUpdateInRealm:realm withValue:realmModel];
            [realm commitWriteTransaction];
        } else {
            RMModelMessage *realmModel = [RMModelMessage objectInRealm:realm forPrimaryKey:model.serverId];
            // Delete all object with a transaction
            if (realmModel) {
                [realm beginWriteTransaction];
                [realm deleteObject:realmModel];
                [realm commitWriteTransaction];
            }
        }
    }
}

@end
