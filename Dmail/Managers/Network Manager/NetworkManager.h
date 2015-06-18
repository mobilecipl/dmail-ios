//
//  NetworkManager.h
//  Dmail
//
//  Created by Karen Petrosyan on 6/17/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseNetwork.h"

@interface NetworkManager : BaseNetwork

+ (instancetype)sharedManager;

#pragma mark - Get Methods
- (void)getMessageListFromDmailWithPosition:(NSInteger)position count:(NSInteger)count senderEmail:(NSString *)senderEmail withCompletionBlock:(mainCompletionBlock)completion;
- (void)getMessageUniqueIDsFromDmailWithUserId:(NSString *)userID withCompletionBlock:(void (^)(NSArray *arrayIDs, NSInteger statusCode))completion;
- (void)getMessageFromGmailWithMessageUniqueId:(NSString *)gmailUniqueId withCompletionBlock:(mainCompletionBlock)completion;
- (void)getMessageFromGmailWithMessageId:(NSString *)messageId withCompletionBlock:(mainCompletionBlock)completion;
- (void)getMessageFromDmailWithGmailUniqueId:(NSString *)gmailUniqueId withCompletionBlock:(mainCompletionBlock)completion;


#pragma mark - Send Methods
- (void)sendMessageToDmailWithEncriptedMessage:(NSString *)encriptedMessage senderEmail:(NSString *)senderEmail completionBlock:(mainCompletionBlock)completionBlock;
- (void)sendMessageToGmailWithEncodedBody:(NSString *)encodedBody withCompletionBlock:(mainCompletionBlock)completion;
- (void)sendMessageUniqueIdToDmailWithMessageDmailId:(NSString*)dmailId gmailUniqueId:(NSString *)gmailUniqueId senderEmail:(NSString *)senderEmail withCompletionBlock:(mainCompletionBlock)completion;

@end
