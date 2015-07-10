//
//  ModelMessage.h
//  Dmail
//
//  Created by Karen Petrosyan on 7/10/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "BaseDataModel.h"

@interface ModelMessage : BaseDataModel

@property NSString *serverId;
@property NSString *access;
@property NSString *dmailId;
@property NSString *messageIdentifier;
@property NSString *gmailId;
@property long long internalDate;
@property NSString *subject;
@property NSString *body;
@property BOOL read;
@property long long position;
@property NSString *type;
@property NSString *from;
@property NSString *to;
@property NSString *cc;
@property NSString *bcc;

- (instancetype)initWithIdentifier:(NSString *)identifier;

@end
