//
//  DAOGmailMessage.h
//  Dmail
//
//  Created by Gevorg Ghukasyan on 7/7/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "BaseDAO.h"

@interface DAOGmailMessage : BaseDAO

- (void)getMessageIdWithUniqueId:(NSString *)uniqueId userId:(NSString *)userID serverId:(NSString *)serverId completionBlock:(CompletionBlock)completionBlock;

- (void)getMessageWithMessageId:(NSString *)messageId
                         userId:(NSString *)userID
                completionBlock:(CompletionBlock)completionBlock;

- (void)sendWithEncodedBody:(NSString *)encodedBody
                     userId:(NSString *)userID
            completionBlock:(CompletionBlock)completionBlock;

- (void)deleteWithGmailId:(NSString *)gmailId
                   userId:(NSString *)userID
          completionBlock:(CompletionBlock)completionBlock;

@end
