//
//  DAOMessage.h
//  Dmail
//
//  Created by Armen Mkrtchian on 6/30/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "BaseDAO.h"

@class ModelMessage;
@class RMModelMessage;

@interface DAOMessage : BaseDAO

- (NSArray *)getInboxMessages;

- (NSArray *)getSentMessages;

- (ModelMessage *)getMessageWithIdentifier:(NSString *)identifier;

- (void)getMessageBodyWithIdentifier:(NSString *)messageIdentifier completionBlock:(CompletionBlock)completionBlock;

- (RMModelMessage *)getLastGmailUniqueId;

- (NSString *)getLastGmailMessageId;

- (NSNumber *)getLastDmailPosition;

- (void)sendMessage:(NSString *)messageBody completionBlock:(CompletionBlock)completionBlock;

- (void)sendRecipientEmail:(NSString *)recipientEmail key:(NSString *)key recipientType:(NSString *)recipientType messageId:(NSString *)messageId completionBlock:(CompletionBlock)completionBlock;

- (void)deleteRecipientEmail:(NSString *)recipientEmail messageId:(NSString *)messageId completionBlock:(CompletionBlock)completionBlock;

- (void)sentEmail:(NSString *)senderEmail messageId:(NSString *)messageId messageIdentifier:(NSString *)messageIdentifier completionBlock:(CompletionBlock)completionBlock;

@end
