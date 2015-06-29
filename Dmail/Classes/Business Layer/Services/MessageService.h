//
//  MessageService.h
//  Dmail
//
//  Created by Karen Petrosyan on 6/12/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@class ComposeModelItem;
@class DmailEntityItem;

@interface MessageService : NSObject


+ (MessageService *)sharedInstance;

#pragma mark - Get Methods
- (void)getMessageListFromDmailWithPosition:(NSDictionary *)parameters withCompletionBlock:(void (^)(NSDictionary *requestData, NSInteger statusCode))completion;
- (void)getDecodedMessageWithGmailUniqueId:(NSString *)gmailUniqueId withCompletionBlock:(void (^)(NSString *message, NSInteger statusCode))completion;
- (void)getGmailMessageIdFromGmailWithIdentifier:(NSString *)gmailUniqueId withCompletionBlock:(void (^)(NSString *gmailMessageId, NSInteger statusCode))completion;
- (void)getMessageFromGmailWithMessageId:(NSString *)messageId withCompletionBlock:(void (^)(NSDictionary *requestData, NSInteger statusCode))completion;
- (void)getMessageFromDmailWithGmailUniqueId:(NSString *)gmailUniqueId withCompletionBlock:(void (^)(NSString *encodedMessage, NSInteger statusCode))completion;


#pragma mark - Send Methods
- (void)sendRecipientsWithParameters:(NSDictionary *)parameters dmailId:(NSString *)dmailId completionBlock:(void (^)(BOOL success))completion;
- (void)sendMessageToDmailWithMessageBody:(NSString *)messageBody senderEmail:(NSString *)senderEmail completionBlock:(void (^)(NSString *dmailId, NSInteger statusCode))completion;
- (void)sendMessageToGmailWithArrayTo:(NSArray *)arrayTo
                              arrayCc:(NSArray *)arrayCc
                             arrayBcc:(NSArray *)arrayBcc
                              subject:(NSString *)subject
                              dmailId:(NSString *)dmailId
                  withCompletionBlock:(void (^)(NSString *gmailMessageId, NSInteger statusCode))completion;
- (void)sendMessageUniqueIdToDmailWithMessageDmailId:(NSString*)dmailId gmailUniqueId:(NSString *)gmailUniqueId senderEmail:(NSString *)senderEmail withCompletionBlock:(void (^)(BOOL sucess))completion;

- (void)revokeUserWithEmail:(NSString *)email dmailId:(NSString *)dmailId completionBlock:(void (^)(BOOL success))completion;
- (void)deleteMessageWithGmailId:(NSString *)gmailId completionBlock:(void (^)(BOOL success))completion;

@end
