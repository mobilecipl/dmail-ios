//
//  DAOGmailMessage.h
//  Dmail
//
//  Created by Gevorg Ghukasyan on 7/7/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "BaseDAO.h"
#import "GTMOAuth2Authentication.h"

@interface DAOGmailMessage : BaseDAO

- (void)getMessageIdWithUniqueId:(NSString *)uniqueId profileEmail:(NSString *)profileEmail userId:(NSString *)userID serverId:(NSString *)serverId token:(NSString *)token completionBlock:(CompletionBlock)completionBlock;

- (void)getMessageWithMessageId:(NSString *)messageId profileEmail:(NSString *)profileEmail userId:(NSString *)userID completionBlock:(CompletionBlock)completionBlock;

- (void)sendWithEncodedBody:(NSString *)encodedBody userId:(NSString *)userID token:(NSString *)token completionBlock:(CompletionBlock)completionBlock;

- (void)deleteWithGmailId:(NSString *)gmailId userId:(NSString *)userID token:(NSString *)token completionBlock:(CompletionBlock)completionBlock;

- (void)getMessageLabelsWithMessageId:(NSString *)messageID completionBlock:(CompletionBlock)completionBlock;

- (void)deleteMessageLabels:(NSArray *)labels messageId:(NSString *)messageID completionBlock:(CompletionBlock)completionBlock;

@end
