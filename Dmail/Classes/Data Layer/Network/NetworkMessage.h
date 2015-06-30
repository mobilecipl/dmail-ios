//
//  NetworkMessage.h
//  Dmail
//
//  Created by Gevorg Ghukasyan on 6/30/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "BaseNetwork.h"

@interface NetworkMessage : BaseNetwork

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

- (void)syncMessagesForEmail:(NSString *)recipientEmail
                    position:(NSString *)position
                       count:(NSString *)count
             completionBlock:(CompletionBlock)completionBlock;

@end
