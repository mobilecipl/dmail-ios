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

@protocol InboxModelDelegate <NSObject>

- (void)updateInboxScreen:(MessageItem *)messageItem;

@end

@interface InboxModel : NSObject

@property (nonatomic, assign) id<InboxModelDelegate> delegate;

- (id)initWithMessageType:(MessageType)messageType;
- (NSMutableArray *)getArrayMessageItems;
- (void)getNewMessages;

@end
