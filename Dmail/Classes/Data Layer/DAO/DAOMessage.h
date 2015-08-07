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

- (BOOL)hasInboxMessages;

- (NSArray *)getInboxMessages;

- (NSArray *)getSentMessages;

- (ModelMessage *)getMessageWithMessageId:(NSString *)messageId;

- (void)getMessageBodyWithMessageId:(NSString *)messageId;

- (RMModelMessage *)getLastGmailUniqueId;

- (NSString *)getLastGmailMessageId;

- (NSNumber *)getLastDmailPosition;

- (void)sendMessage:(NSString *)encryptedBopdy clientKey:(NSString *)clientKey messageSubject:(NSString *)messageSubject to:(NSArray *)to cc:(NSArray *)cc bcc:(NSArray *)bcc completionBlock:(CompletionBlock)completionBlock;

- (void)sendRecipientEmail:(NSString *)recipientEmail key:(NSString *)key recipientType:(NSString *)recipientType messageId:(NSString *)messageId completionBlock:(CompletionBlock)completionBlock;

- (void)deleteRecipientEmail:(NSString *)recipientEmail messageId:(NSString *)messageId completionBlock:(CompletionBlock)completionBlock;

- (void)deleteMessageWithMessageId:(NSString *)messageId;

- (void)unreadMessageWithMessageId:(NSString *)messageId;

- (void)archiveMessageWithFrom:(NSString *)from subject:(NSString *)subject CompletionBlock:(CompletionBlock)completionBlock;

- (void)destroyMessageWithMessageId:(NSString *)messageId participant:(NSString *)participant;

- (void)revokeMessageWithMessageId:(NSString *)messageId participant:(NSString *)participant;

- (void)getTemplateWithCompletionBlock:(CompletionBlock)completionBlock;

- (void)changeMessageStatusToReadWithMessageId:(NSString *)messageId;

- (void)clearAllData;

- (NSString *)generatePublicKey;

- (NSString *)getClientKeyWithMessageId:(NSString *)messageId;

- (void)writeDecryptedBodyWithMessageId:(NSString *)messageId body:(NSString *)body;

@end
