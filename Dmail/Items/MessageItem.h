//
//  MessageItem.h
//  Dmail
//
//  Created by Karen Petrosyan on 6/21/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Constants.h"

@interface MessageItem : NSObject

@property NSString *dmailId;
@property NSString *identifier;
@property NSString *subject;
@property NSString *senderName;
@property MessageType type;
@property MessageStatus status;
@property (nonatomic) CGFloat postDate;

@end
