//
//  DAOMessage.h
//  Dmail
//
//  Created by Armen Mkrtchian on 6/30/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "BaseDAO.h"

@class RLMResults;

@interface DAOMessage : BaseDAO

- (void)sendEncryptedMessage:(NSString *)encryptedMessage
                 senderEmail:(NSString *)senderEmail
             completionBlock:(CompletionBlock)completionBlock;

- (void)sendRecipientEmail:(NSString *)recipientEmail
                       key:(NSString *)key
            recipientType:(NSString *)recipientType
                 messageId:(NSString *)messageId
           completionBlock:(CompletionBlock)completionBlock;

- (void)deleteRecipientEmail:(NSString *)recipientEmail
                   messageId:(NSString *)messageId
             completionBlock:(CompletionBlock)completionBlock;

- (void)sentEmail:(NSString *)senderEmail
        messageId:(NSString *)messageId
messageIdentifier:(NSString *)messageIdentifier
  completionBlock:(CompletionBlock)completionBlock;

- (NSArray *)getInboxMessages;

- (NSArray *)getSentMessages;

- (NSString *)getLastGmailUniqueId;

- (NSString *)getLastGmailMessageId;
@end
