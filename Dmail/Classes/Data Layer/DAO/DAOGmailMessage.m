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

// local storage
#import <Realm/Realm.h>

#import "RMModelDmailMessage.h"

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

- (void)updateMessageWithUniqueId:(NSString *)uniqueId gmailId:(NSString *)gmailId {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    RLMResults *results = [RMModelDmailMessage objectsInRealm:realm where:@"messageIdentifier = %@", uniqueId];
    
    
    [realm beginWriteTransaction];
    
    for (RMModelDmailMessage *realmModel in results) {
        realmModel.gmailId = gmailId;
    }
    
    [realm commitWriteTransaction];

}

- (void)getMessageWithMessageId:(NSString *)messageId
                         userId:(NSString *)userID
                completionBlock:(CompletionBlock)completionBlock {
    
    [self.networkGmailMessage getMessageWithMessageId:messageId
                                               userId:userID
                                      completionBlock:^(id data, ErrorDataModel *error) {
                                          
                                          if (!error) {
                                              NSArray *messages = data[@"messages"];
                                              
                                              if ([messages isKindOfClass:[NSArray class]]) {
                                                  
                                                  for (NSDictionary *dict in messages) {
                                                      
                                                      ModelGmailMessage *model = [[ModelGmailMessage alloc] initWithDictionary:dict];
//                                                      NSString *gmailId = dict[@"id"];
//                                                      if (gmailId) {
////                                                          [self updateMessageWithUniqueId:uniqueId gmailId:gmailId];
//                                                      }
                                                  }
                                                  completionBlock(nil, error);
                                              }
                                              
                                          } else {
                                              completionBlock(nil, error);
                                          }
                                          
                                          
                                          completionBlock(data, error);
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

- (ModelGmailMessage *)parseGmailMessageContent:(NSDictionary *)dictionary {
    
    ModelGmailMessage *modelGmailMessage = [[ModelGmailMessage alloc] initWithDictionary:dictionary];
    
    
//    modelGmailMessage.publicKey = [self getPublicKeyFromSnippet:dictionary[Snippet]];
//    modelGmailMessage.gmailId = dictionary[@"id"];
    NSLog(@"modelGmailMessage.gmailId === %@", dictionary);
    if ([[dictionary allKeys] containsObject:Payload]) {
        modelGmailMessage.internalDate = [dictionary[InternalDate] doubleValue];
        NSDictionary *payload = dictionary[Payload];
        if ([[payload allKeys] containsObject:Headers]) {
            NSArray *headers = payload[Headers];
            for (NSDictionary *dict in headers) {
                if ([dict[Name] isEqualToString:From]) {
//                    modelGmailMessage.fromEmail = [self getEmailFromValue:dict[Value]];
//                    modelGmailMessage.fromName = [self getNameFromvalue:dict[Value]];
//                    ProfileItem *profileItem = [[ProfileItem alloc] initWithEmail:modelGmailMessage.fromEmail name:modelGmailMessage.fromName];
//                    [[CoreDataManager sharedCoreDataManager] writeOrUpdateParticipantWith:profileItem];
                }
                if ([dict[Name] isEqualToString:To]) {
                    NSArray *array = [dict[Value] componentsSeparatedByString:@","];
                    for (NSString *string in array) {
//                        NSString *toEmail = [self getEmailFromValue:string];
//                        if (toEmail) {
//                            [modelGmailMessage.arrayTo addObject:toEmail];
//                        }
//                        NSString *toName = [self getNameFromvalue:string];
//                        ProfileItem *profileItem = [[ProfileItem alloc] initWithEmail:toEmail name:toName];
//                        [[CoreDataManager sharedCoreDataManager] writeOrUpdateParticipantWith:profileItem];
                    }
                }
                
                if ([dict[Name] isEqualToString:Subject]) {
                    modelGmailMessage.subject = dict[Value];
                }
                if ([dict[Name] isEqualToString:Message_Id]) {
                    modelGmailMessage.identifier = dict[Value];
                }
//                modelGmailMessage.status = MessageFetchedFull;
            }
        }
    }
    
    return modelGmailMessage;
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
