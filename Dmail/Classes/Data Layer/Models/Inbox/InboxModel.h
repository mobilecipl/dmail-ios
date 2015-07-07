//
//  InboxModel.h
//  Dmail
//
//  Created by Karen Petrosyan on 6/18/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@class MessageItem;

@interface InboxModel : NSObject

@property (nonatomic, assign) MessageLabel messageLabel;

- (id)initWithMessageLabel:(MessageLabel)messageLabel;
- (NSMutableArray *)getArrayMessageItems;
- (void)deleteMessageWithMessageItem:(MessageItem *)item;

@end
