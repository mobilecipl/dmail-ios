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
- (void)getMessageFromGmailWithMessageId:(NSString *)messageId withCompletionBlock:(void (^)(DmailEntityItem *itemFromGmail, NSInteger statusCode))completion;
- (void)getMessageFromDmailWithGmailUniqueId:(NSString *)gmailUniqueId withCompletionBlock:(void (^)(NSString *encodedMessage, NSInteger statusCode))completion;


#pragma mark - Send Methods
- (void)sendRecipientsWithParameters:(NSDictionary *)parameters dmailId:(NSString *)dmailId completionBlock:(void (^)(BOOL success))completion;
- (void)sendMessageToDmailWithEncriptedMessage:(NSString *)encriptedMessage senderEmail:(NSString *)senderEmail completionBlock:(void (^)(NSString *messageId, NSInteger statusCode))completion;
- (void)sendMessageToGmailWithMessageGmailBody:(NSString *)gmailBody withCompletionBlock:(void (^)(NSString *gmailMessageId, NSInteger statusCode))completion;
- (void)sendMessageUniqueIdToDmailWithMessageDmailId:(NSString*)dmailId gmailUniqueId:(NSString *)gmailUniqueId senderEmail:(NSString *)senderEmail withCompletionBlock:(void (^)(BOOL sucess))completion;

@end
