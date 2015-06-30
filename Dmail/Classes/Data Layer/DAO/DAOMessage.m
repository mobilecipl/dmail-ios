//
//  DAOMessage.m
//  Dmail
//
//  Created by Armen Mkrtchian on 6/30/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "DAOMessage.h"

// network
#import "NetworkMessage.h"

@interface DAOMessage ()
@property (nonatomic, strong) NetworkMessage *networkMessage;
@end

@implementation DAOMessage

- (instancetype)init {
    
    if (self) {
        _networkMessage = [[NetworkMessage alloc] init];
    }
    
    return self;
}

- (void)sendEncryptedMessage:(NSString *)encryptedMessage
                 senderEmail:(NSString *)senderEmail
             completionBlock:(CompletionBlock)completionBlock {
    
    [self.networkMessage sendEncryptedMessage:encryptedMessage
                                  senderEmail:senderEmail
                              completionBlock:^(id data, ErrorDataModel *error) {
                                  
                                  completionBlock(data, error);
                              }];
}

- (void)sendRecipientEmail:(NSString *)recipientEmail
                       key:(NSString *)key
             recipientType:(NSString *)recipientType
                 messageId:(NSString *)messageId
           completionBlock:(CompletionBlock)completionBlock {
    
    [self.networkMessage sendRecipientEmail:recipientEmail
                                        key:key
                              recipientType:recipientType
                                  messageId:messageId
                            completionBlock:^(id data, ErrorDataModel *error) {
                                
                                completionBlock(data, error);
                            }];
}

- (void)deleteRecipientEmail:(NSString *)recipientEmail
                   messageId:(NSString *)messageId
             completionBlock:(CompletionBlock)completionBlock {
    
    
    [self.networkMessage deleteRecipientEmail:recipientEmail
                                    messageId:messageId
                              completionBlock:^(id data, ErrorDataModel *error) {
                                  
                                  completionBlock(data, error);
                              }];
}

- (void)sentEmail:(NSString *)senderEmail
        messageId:(NSString *)messageId
messageIdentifier:(NSString *)messageIdentifier
  completionBlock:(CompletionBlock)completionBlock {
    
    [self.networkMessage sentEmail:senderEmail
                         messageId:messageId
                 messageIdentifier:messageIdentifier
                   completionBlock:^(id data, ErrorDataModel *error) {
                       
                       completionBlock(data, error);
                   }];
}

- (void)syncMessagesForEmail:(NSString *)recipientEmail
                    position:(NSString *)position
                       count:(NSString *)count
             completionBlock:(CompletionBlock)completionBlock {
    
    [self.networkMessage syncMessagesForEmail:recipientEmail
                                     position:position
                                        count:count
                              completionBlock:^(id data, ErrorDataModel *error) {
                                  
                                  completionBlock(data, error);
                              }];
}

@end
