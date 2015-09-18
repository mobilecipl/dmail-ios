//
//  NetworkGmailMessage.h
//  Dmail
//
//  Created by Gevorg Ghukasyan on 7/7/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "BaseNetwork.h"
#import "GTMOAuth2Authentication.h"

@interface NetworkGmailMessage : BaseNetwork

- (void)getMessageIdWithUniqueId:(NSString *)uniqueId userId:(NSString *)userID token:(NSString *)token completionBlock:(CompletionBlock)completionBlock;

- (void)getMessageWithMessageId:(NSString *)messageId userId:(NSString *)userID token:(NSString *)token completionBlock:(CompletionBlock)completionBlock;

- (void)sendWithEncodedBody:(NSString *)encodedBody userId:(NSString *)userID token:(NSString *)token completionBlock:(CompletionBlock)completionBlock;

- (void)deleteWithGmailId:(NSString *)gmailId userId:(NSString *)userID token:(NSString *)token completionBlock:(CompletionBlock)completionBlock;

- (void)getMessageLabelsWithMessageId:(NSString *)messageID userId:(NSString *)userID token:(NSString *)token completionBlock:(CompletionBlock)completionBlock;

- (void)deleteMessageLabels:(NSArray *)labels messageId:(NSString *)messageID userId:(NSString *)userID token:(NSString *)token completionBlock:(CompletionBlock)completionBlock;

@end
