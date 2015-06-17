//
//  MessageService.h
//  Dmail
//
//  Created by Karen Petrosyan on 6/12/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageService : NSObject


+ (MessageService *)sharedInstance;

#pragma mark - Public Methods
- (void)getMessageUniqueIDsFromDmailWithUserId:(NSString *)userID withCompletionBlock:(void (^)(NSArray *arrayIDs, NSError *error))completion;
- (void)getMessageFromGmailWithGmailUniqueId:(NSString *)gmailUniqueId withCompletionBlock:(void (^)(NSString *messageId, NSError *error))completion;
- (void)getMessageFromDmailWithGmailUniqueId:(NSString *)gmailUniqueId withCompletionBlock:(void (^)(BOOL success, NSError *error))completion;

- (void)sendMessageToGmailWithTo:(NSString *)to messageSubject:(NSString *)messageSubject messageBody:(NSString *)messageBody withCompletionBlock:(void (^)(BOOL success, NSError *error))completion;

@end
