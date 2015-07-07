//
//  DAOGmailMessage.m
//  Dmail
//
//  Created by Gevorg Ghukasyan on 7/7/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "DAOGmailMessage.h"

#import "NetworkGmailMessage.h"

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
                                           
                                           completionBlock(data, error);
                                       }];
}

- (void)getMessageWithMessageId:(NSString *)messageId
                         userId:(NSString *)userID
                completionBlock:(CompletionBlock)completionBlock {
    
    [self.networkGmailMessage getMessageWithMessageId:messageId
                                               userId:userID
                                      completionBlock:^(id data, ErrorDataModel *error) {
                                          
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
