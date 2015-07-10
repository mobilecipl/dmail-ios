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
#import "ModelDmailMessage.h"


// local
#import <Realm.h>
#import "RMModelDmailMessage.h"

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
                    ModelDmailMessage *message = [[ModelDmailMessage alloc] initWithDictionary:dict];
                    if (message) {
                        NSLog(@"message.position ==== %@",message.position);
                        [dataArray addObject:message];
                    }
                }
                [self saveRecipientsInRealm:dataArray];
                completionBlock(nil, error);
            }
            
        } else {
            completionBlock(nil, error);
        }
    }];
}

- (void)saveRecipientsInRealm:(NSArray *)dataArray {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    for (ModelDmailMessage *model in dataArray) {
        if ([model.access isEqualToString:@"GRANTED"]) {
            RMModelDmailMessage *realmModel = [[RMModelDmailMessage alloc] initWithModel:model];
            // Add
            [realm beginWriteTransaction];
            [RMModelDmailMessage createOrUpdateInRealm:realm withValue:realmModel];
            [realm commitWriteTransaction];
        } else {
            RMModelDmailMessage *realmModel = [RMModelDmailMessage objectInRealm:realm forPrimaryKey:model.serverId];
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
