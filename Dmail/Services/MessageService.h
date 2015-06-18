//
//  MessageService.h
//  Dmail
//
//  Created by Karen Petrosyan on 6/12/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@interface MessageService : NSObject


+ (MessageService *)sharedInstance;

#pragma mark - Get Methods
- (void)getMessageListFromDmailWithPosition:(NSInteger)position count:(NSInteger)count senderEmail:(NSString *)senderEmail withCompletionBlock:(void (^)(NSArray *arrayInboxItems, NSInteger statusCode))completion;
- (void)getMessageUniqueIDsFromDmailWithUserId:(NSString *)userID withCompletionBlock:(void (^)(NSArray *arrayIDs, NSInteger statusCode))completion;
- (void)getDecodedMessageWithGmailUniqueId:(NSString *)gmailUniqueId withCompletionBlock:(void (^)(NSString *message, NSInteger statusCode))completion;
- (void)getMessageFromGmailWithMessageUniqueId:(NSString *)gmailUniqueId withCompletionBlock:(void (^)(NSDictionary *message, NSInteger statusCode))completion;
- (void)getMessageFromGmailWithMessageId:(NSString *)messageId withCompletionBlock:(void (^)(NSString *messageUniqueId, NSInteger statusCode))completion;
- (void)getMessageFromDmailWithGmailUniqueId:(NSString *)gmailUniqueId withCompletionBlock:(void (^)(NSString *encodedMessage, NSInteger statusCode))completion;


#pragma mark - Send Methods
- (void)sendMessageToDmailWithEncriptedMessage:(NSString *)encriptedMessage senderEmail:(NSString *)senderEmail completionBlock:(void (^)(NSString *messageId, NSInteger statusCode))completion;
- (void)sendMessageToGmailWithTo:(NSString *)to messageSubject:(NSString *)messageSubject messageBody:(NSString *)messageBody withCompletionBlock:(void (^)(NSString *gmailMessageId, NSInteger statusCode))completion;
- (void)sendMessageUniqueIdToDmailWithMessageDmailId:(NSString*)dmailId gmailUniqueId:(NSString *)gmailUniqueId senderEmail:(NSString *)senderEmail withCompletionBlock:(void (^)(NSString *gmailMessageId, NSInteger statusCode))completion;

@end
