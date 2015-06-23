//
//  DmailEntityItem.h
//  Dmail
//
//  Created by Karen Petrosyan on 6/22/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DmailEntityItem : NSObject

@property (nonatomic, retain) NSString * dmailId;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * subject;
@property (nonatomic, retain) NSString * senderName;
@property (nonatomic, retain) NSString * access;
@property (nonatomic, retain) NSString * senderEmail;
@property (nonatomic, retain) NSString * body;
@property (nonatomic, retain) NSString * receiverEmail;

@property (nonatomic) NSInteger internalDate;
@property (nonatomic) NSInteger position;
@property (nonatomic) NSInteger status;
@property (nonatomic) NSInteger type;

- (instancetype)initWithClearObjects;

@end
