//
//  ServiceGmailMessage.m
//  Dmail
//
//  Created by Gevorg Ghukasyan on 7/7/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "ServiceGmailMessage.h"

#import "DAOGmailMessage.h"

@interface ServiceGmailMessage ()

@property (nonatomic, strong) DAOGmailMessage *daoGmailMessage;

@end

@implementation ServiceGmailMessage

- (instancetype)init {
    
    if (self) {
        _daoGmailMessage = [[DAOGmailMessage alloc] init];
    }
    
    return self;
}

- (void)getMessageIdWithUniqueId:(NSString *)uniqueId
                          userId:(NSString *)userID
                 completionBlock:(CompletionBlock)completionBlock {
    
    [self.daoGmailMessage getMessageIdWithUniqueId:uniqueId
                                                userId:userID
                                       completionBlock:^(id data, ErrorDataModel *error) {
                                           
                                           completionBlock(data, error);
                                       }];
}

- (void)getMessageWithMessageId:(NSString *)messageId
                         userId:(NSString *)userID
                completionBlock:(CompletionBlock)completionBlock {
    
    [self.daoGmailMessage getMessageWithMessageId:messageId
                                               userId:userID
                                      completionBlock:^(id data, ErrorDataModel *error) {
                                          
                                          completionBlock(data, error);
                                      }];
}

- (void)sendWithEncodedBody:(NSString *)encodedBody
                     userId:(NSString *)userID
            completionBlock:(CompletionBlock)completionBlock {
    
    [self.daoGmailMessage sendWithEncodedBody:encodedBody
                                           userId:userID
                                  completionBlock:^(id data, ErrorDataModel *error) {
                                      
                                      completionBlock(data, error);
                                  }];
}

- (void)deleteWithGmailId:(NSString *)gmailId
                   userId:(NSString *)userID
          completionBlock:(CompletionBlock)completionBlock {
    
    [self.daoGmailMessage deleteWithGmailId:gmailId
                                         userId:userID
                                completionBlock:^(id data, ErrorDataModel *error) {
                                    
                                    completionBlock(data, error);
                                }];
}

@end
