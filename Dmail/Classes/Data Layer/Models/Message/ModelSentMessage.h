//
//  ModelSentMessage.h
//  Dmail
//
//  Created by Karen Petrosyan on 7/13/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ModelSentMessage : NSObject

@property (nonatomic) NSString *messageId;
@property (nonatomic) NSString *recipientName;
@property (nonatomic) NSString *subject;
@property long long internalDate;

@end
