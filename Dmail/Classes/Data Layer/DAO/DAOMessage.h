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

- (void)getMessageBodyWithMessageId:(NSString *)messageId;

- (void)getTemplateWithCompletionBlock:(CompletionBlock)completionBlock;

- (NSArray *)getInboxMessages;

- (NSArray *)getSentMessages;

- (NSString *)getClientKeyWithMessageId:(NSString *)messageId;

- (NSString *)getGmailIDWithMessageId:(NSString *)messageId;

- (NSString *)getLastGmailMessageId;

- (NSNumber *)getLastDmailPosition;

- (ModelMessage *)getMessageWithMessageId:(NSString *)messageId;

- (RMModelMessage *)getLastGmailUniqueId;

- (void)sendMessage:(NSString *)encryptedBopdy clientKey:(NSString *)clientKey messageSubject:(NSString *)messageSubject to:(NSArray *)to cc:(NSArray *)cc bcc:(NSArray *)bcc completionBlock:(CompletionBlock)completionBlock;

- (void)sendRecipientEmail:(NSString *)recipientEmail key:(NSString *)key recipientType:(NSString *)recipientType messageId:(NSString *)messageId completionBlock:(CompletionBlock)completionBlock;

- (void)deleteRecipientEmail:(NSString *)recipientEmail messageId:(NSString *)messageId completionBlock:(CompletionBlock)completionBlock;

- (void)deleteMessageWithMessageId:(NSString *)messageId;

- (void)unreadMessageWithMessageId:(NSString *)messageId;

- (void)destroyMessageWithMessageId:(NSString *)messageId participant:(NSString *)participant;

- (void)revokeMessageWithMessageId:(NSString *)messageId participant:(NSString *)participant;

- (void)changeMessageStatusToReadWithMessageId:(NSString *)messageId;

- (void)clearAllData;

- (NSString *)generatePublicKey;

- (void)writeDecryptedBodyWithMessageId:(NSString *)messageId body:(NSString *)body;

- (BOOL)hasInboxMessages;

@end
