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

- (NSArray *)getInboxMessages;

- (NSArray *)getSentMessages;

- (VMInboxMessageItem *)getInboxMessageWithMessageId:(NSString *)messageId;

- (VMSentMessage *)getSentMessageWithMessageId:(NSString *)messageId;

- (void)getMessageBodyWithIdentifier:(NSString *)messageIdentifier completionBlock:(CompletionBlock)completionBlock;

- (void)sendMessage:(NSString *)messageBody messageSubject:(NSString *)messageSubject to:(NSArray *)to cc:(NSArray *)cc bcc:(NSArray *)bcc completionBlock:(CompletionBlock)completionBlock;

- (void)sendRecipientEmail:(NSString *)recipientEmail key:(NSString *)key recipientType:(NSString *)recipientType messageId:(NSString *)messageId completionBlock:(CompletionBlock)completionBlock;

- (void)deleteRecipientEmail:(NSString *)recipientEmail messageId:(NSString *)messageId completionBlock:(CompletionBlock)completionBlock;

- (void)sentEmail:(NSString *)senderEmail messageId:(NSString *)messageId messageIdentifier:(NSString *)messageIdentifier completionBlock:(CompletionBlock)completionBlock;

- (void)deleteMessageWithMessageItem:(NSString *)messageId;

- (void)destroyMessageWithMessageItem:(NSArray *)arrayParticipants messageId:(NSString *)messageId;

@end
