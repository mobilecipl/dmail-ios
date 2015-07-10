//
//  DAOGmailMessage.m
//  Dmail
//
//  Created by Gevorg Ghukasyan on 7/7/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "DAOGmailMessage.h"

// network
#import "NetworkGmailMessage.h"

// model
#import "ModelGmailMessage.h"
#import "ModelMessage.h"

// local storage
#import <Realm/Realm.h>

#import "RMModelDmailMessage.h"
#import "RMModelGmailMessage.h"
#import "RMModelMessage.h"

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

- (void)getMessageIdWithUniqueId:(NSString *)uniqueId
                          userId:(NSString *)userID
                 completionBlock:(CompletionBlock)completionBlock {
    
    [self.networkGmailMessage getMessageIdWithUniqueId:uniqueId
                                                userId:userID
                                       completionBlock:^(id data, ErrorDataModel *error) {
                                           
                                           if (!error) {
                                               NSArray *messages = data[@"messages"];
                                               
                                               if ([messages isKindOfClass:[NSArray class]]) {
                                                   
                                                   for (NSDictionary *dict in messages) {
                                                       NSString *gmailId = dict[@"id"];
                                                       if (gmailId) {
                                                           [self updateMessageWithUniqueId:uniqueId gmailId:gmailId];
                                                       }
                                                   }
                                                   completionBlock(nil, error);
                                               }
                                               
                                           } else {
                                               completionBlock(nil, error);
                                           }
                                           
                                           
                                           completionBlock(data, error);
                                       }];
}

- (void)getMessageWithMessageId:(NSString *)messageId
                         userId:(NSString *)userID
                completionBlock:(CompletionBlock)completionBlock {
    
    [self.networkGmailMessage getMessageWithMessageId:messageId
                                               userId:userID
                                      completionBlock:^(NSDictionary *data, ErrorDataModel *error) {
                                          if (!error) {
                                              ModelGmailMessage *model = [[ModelGmailMessage alloc] initWithDictionary:data];
                                              
                                              [self saveGmailMessageInRealm:model];
                                              
                                              ModelMessage *modelMessage = [[ModelMessage alloc] init];
                                              modelMessage.messageIdentifier = model.payload.messageIdentifier;
                                              
                                              [self saveMessageInRealm:modelMessage];
                                              completionBlock(nil, error);
                                          } else {
                                              
                                              completionBlock(nil, error);
                                          }
                                      }];
}

- (void)sendWithEncodedBody:(NSString *)encodedBody
                     userId:(NSString *)userID
            completionBlock:(CompletionBlock)completionBlock {
    
    [self.networkGmailMessage sendWithEncodedBody:encodedBody
                                           userId:userID
                                  completionBlock:^(id data, ErrorDataModel *error) {
                                      
                                      completionBlock(data, error);
                                  }];
}


- (void)updateMessageWithUniqueId:(NSString *)uniqueId gmailId:(NSString *)gmailId {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    RLMResults *results = [RMModelDmailMessage objectsInRealm:realm where:@"messageIdentifier = %@", uniqueId];
    
    
    [realm beginWriteTransaction];
    
    for (RMModelDmailMessage *realmModel in results) {
        realmModel.gmailId = gmailId;
    }
    
    [realm commitWriteTransaction];
}

- (void)saveGmailMessageInRealm:(ModelGmailMessage *)gmailMessage {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    RMModelGmailMessage *realmModel = [[RMModelGmailMessage alloc] initWithModel:gmailMessage];

    [realm beginWriteTransaction];
    [RMModelGmailMessage createOrUpdateInRealm:realm withValue:realmModel];
    [realm commitWriteTransaction];
}

- (void)saveMessageInRealm:(ModelMessage *)modelMessage {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    RMModelMessage *realmModel = [[RMModelMessage alloc] initWithModel:modelMessage];
    
    [realm beginWriteTransaction];
    [RMModelMessage createOrUpdateInRealm:realm withValue:realmModel];
    [realm commitWriteTransaction];
}

- (void)deleteWithGmailId:(NSString *)gmailId
                   userId:(NSString *)userID
          completionBlock:(CompletionBlock)completionBlock {
    
    [self.networkGmailMessage deleteWithGmailId:gmailId
                                         userId:userID
                                completionBlock:^(id data, ErrorDataModel *error) {
                                    
                                    completionBlock(data, error);
                                }];
}

@end
