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
- (void)getMessageUniqueIDsFromDmailWithUserId:(NSString *)userID WithCompletionBlock:(void (^)(BOOL success, NSError *error))completion;

@end
