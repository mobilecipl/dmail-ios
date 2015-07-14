//
//  ModelInboxMessage.h
//  Dmail
//
//  Created by Karen Petrosyan on 7/14/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ModelInboxMessage : NSObject

@property (nonatomic) NSString *messageId;
@property (nonatomic) NSString *fromName;
@property (nonatomic) NSString *fromEmail;
@property (nonatomic) NSString *subject;
@property (nonatomic) NSString *imageUrl;
@property (nonatomic) NSString *body;
@property long long internalDate;
@property BOOL read;

@end
