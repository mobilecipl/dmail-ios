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

- (NSNumber *)getLastDmailPositionWithEmail:(NSString *)email forProfile:(NSString *)profile;

- (ModelMessage *)getMessageWithMessageId:(NSString *)messageId;

- (RMModelMessage *)getLastGmailUniqueIdForProfile:(NSString *)profile;

- (void)sendMessage:(NSString *)encryptedBopdy clientKey:(NSString *)clientKey messageSubject:(NSString *)messageSubject to:(NSArray *)to cc:(NSArray *)cc bcc:(NSArray *)bcc timer:(long long)timer completionBlock:(CompletionBlock)completionBlock;

- (void)sendRecipientEmail:(NSString *)recipientEmail key:(NSString *)key recipientType:(NSString *)recipientType messageId:(NSString *)messageId completionBlock:(CompletionBlock)completionBlock;

- (void)deleteRecipientEmail:(NSString *)recipientEmail messageId:(NSString *)messageId completionBlock:(CompletionBlock)completionBlock;

- (void)deleteMessageWithMessageId:(NSString *)messageId completionBlock:(CompletionBlock)completionBlock;

- (void)unreadMessageWithMessageId:(NSString *)messageId;

- (void)destroyMessageWithMessageId:(NSString *)messageId fromSentList:(BOOL)fromSentList;

- (void)changeMessageStatusToReadWithMessageId:(NSString *)messageId;

- (void)removeMessagesForProfile:(NSString *)profileEmail;

- (void)removeResipientsForProfile:(NSString *)profileEmail;

- (NSString *)generatePublicKey;

- (void)writeDecryptedBodyWithMessageId:(NSString *)messageId body:(NSString *)body;

- (BOOL)hasInboxMessages;

- (void)cancelAllRequests;

@end
