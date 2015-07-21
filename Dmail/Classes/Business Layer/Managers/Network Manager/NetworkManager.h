//
//  NetworkManager.h
//  Dmail
//
//  Created by Karen Petrosyan on 6/17/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseNetwork.h"
#import <AFOAuth2Manager.h>
#import <GoogleSignIn/GoogleSignIn.h>
#import "Constants.h"
#import "Configurations.h"

static NSString * const baseURL = @"http://192.168.0.100:8080/dmail/";
//static NSString * const baseURL = @"http://dmail-dev.elasticbeanstalk.com/";
@interface NetworkManager : BaseNetwork

+ (instancetype)sharedManager;

#pragma mark - Get Methods
- (void)getMessageListFromDmailWithPosition:(NSDictionary *)parameters withCompletionBlock:(mainCompletionBlock)completion;
- (void)getGmailMessageIdFromGmailWithMessageUniqueId:(NSString *)gmailUniqueId withCompletionBlock:(mainCompletionBlock)completion;    //GMAIL
- (void)getMessageFromGmailWithMessageId:(NSString *)messageId withCompletionBlock:(mainCompletionBlock)completion;                     //GMAIL
- (void)getMessageFromDmailWithGmailUniqueId:(NSString *)gmailUniqueId withCompletionBlock:(mainCompletionBlock)completion;


#pragma mark - Send Methods
- (void)sendRecipientsWithParameters:(NSDictionary *)parameters dmailId:(NSString *)dmailId completionBlock:(mainCompletionBlock)completion;
- (void)sendMessageToDmailWithEncriptedMessage:(NSString *)encriptedMessage senderEmail:(NSString *)senderEmail completionBlock:(mainCompletionBlock)completionBlock;
- (void)sendMessageToGmailWithEncodedBody:(NSString *)encodedBody withCompletionBlock:(mainCompletionBlock)completion;                  //GMAIL
- (void)sendMessageUniqueIdToDmailWithMessageDmailId:(NSString*)dmailId gmailUniqueId:(NSString *)gmailUniqueId senderEmail:(NSString *)senderEmail withCompletionBlock:(mainCompletionBlock)completion;
- (void)revokeUserWithEmail:(NSString *)email dmailId:(NSString *)dmailId completionBlock:(mainCompletionBlock)completion;
- (void)deleteMessageWithGmailId:(NSString *)gmailId withCompletionBlock:(mainCompletionBlock)completion;

- (void)getContactsWithCompletionBlock:(mainCompletionBlock)completion;
- (void)getContactPhoto;

@end
