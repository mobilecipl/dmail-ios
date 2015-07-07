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
@property NSString *gmailId;
@property NSString *identifier;
@property NSString *subject;
@property NSString *senderName;
@property NSString *fromEmail;
@property NSArray *arrayTo;
@property NSArray *arrayCc;
@property NSArray *arrayBcc;
@property NSNumber *internalDate;
@property MessageType type;
@property MessageLabel label;
@property (nonatomic) CGFloat postDate;

@end
