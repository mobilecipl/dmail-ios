//
//  ServiceMessage.h
//  Dmail
//
//  Created by Armen Mkrtchian on 6/30/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "BaseService.h"

@class VMInboxMessageItem;
@class VMSentMessageItem;
@class VMSentMessage;

@interface ServiceMessage : BaseService

- (BOOL)hasInboxMessages;

- (NSArray *)getInboxMessages;

- (NSArray *)getSentMessages;

- (VMInboxMessageItem *)getInboxMessageWithMessageId:(NSString *)messageId;

- (VMSentMessage *)getSentMessageWithMessageId:(NSString *)messageId;

- (NSString *)getGmailIDWithMessageId:(NSString *)messageId;

- (NSString *)getClientKey;

- (NSString *)getClientKeyWithMessageId:(NSString *)messageId;

- (void)getMessageBodyWithIdentifier:(NSString *)messageIdentifier;

- (void)sendMessage:(NSString *)encryptedBody clientKey:(NSString *)clientKey messageSubject:(NSString *)messageSubject to:(NSArray *)to cc:(NSArray *)cc bcc:(NSArray *)bcc timer:(long long)timer completionBlock:(CompletionBlock)completionBlock;

- (void)sendRecipientEmail:(NSString *)recipientEmail key:(NSString *)key recipientType:(NSString *)recipientType messageId:(NSString *)messageId completionBlock:(CompletionBlock)completionBlock;

- (void)deleteRecipientEmail:(NSString *)recipientEmail messageId:(NSString *)messageId completionBlock:(CompletionBlock)completionBlock;

- (void)deleteMessageWithMessageId:(NSString *)messageId completionBlock:(CompletionBlock)completionBlock;

- (void)unreadMessageWithMessageId:(NSString *)messageId;

- (void)destroyMessageWithMessageId:(NSString *)messageId fromSentList:(BOOL)fromSentList;

- (void)changeMessageStatusToReadWithMessageId:(NSString *)messageId;

- (void)clearAllData;

- (void)writeDecryptedBodyWithMessageId:(NSString *)messageId body:(NSString *)body;

@end
