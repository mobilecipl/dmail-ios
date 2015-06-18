//
//  InboxModel.h
//  Dmail
//
//  Created by Karen Petrosyan on 6/18/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@interface InboxModel : NSObject

- (id)initWithMessageType:(MessageType)messageType;

- (void)getMessageListWithPosition:(NSInteger)position count:(NSInteger)count senderEmail:(NSString *)senderEmail withCompletionBlock:(void (^)(NSArray *arrayMessages, NSInteger statusCode))completion;

@end
