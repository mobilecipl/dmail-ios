//
//  RMModelMessage.h
//  Dmail
//
//  Created by Armen Mkrtchian on 7/9/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "AutoDefaultsRMLObject.h"

@class ModelMessage;

@interface RMModelMessage : AutoDefaultsRMLObject

@property NSString *serverId;
@property NSString *access;
@property NSString *dmailId;
@property NSString *messageIdentifier;
@property NSString *gmailId;

@property NSString *subject;
@property NSString *body;

@property BOOL read;
@property long long position;
@property long long internalDate;
@property NSString *type;
@property NSString *fromName;
@property NSString *fromEmail;
@property NSString *to;
@property NSString *cc;
@property NSString *bcc;

- (instancetype)initWithModel:(ModelMessage *)modelMessage;

@end
