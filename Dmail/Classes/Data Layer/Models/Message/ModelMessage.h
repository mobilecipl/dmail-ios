//
//  ModelMessage.h
//  Dmail
//
//  Created by Karen Petrosyan on 7/10/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "BaseDataModel.h"

@interface ModelMessage : BaseDataModel

@property (nonatomic) NSString *serverId;
@property (nonatomic) NSString *access;
@property (nonatomic) NSString *dmailId;
@property (nonatomic) NSString *messageIdentifier;
@property (nonatomic) NSString *gmailId;
@property (nonatomic) long long internalDate;
@property (nonatomic) NSString *subject;
@property (nonatomic) NSString *body;
@property BOOL read;
@property long long position;
@property NSString *type;
@property NSString *from;
@property NSString *to;
@property NSString *cc;
@property NSString *bcc;

@property NSString *imageUrl;

@end
