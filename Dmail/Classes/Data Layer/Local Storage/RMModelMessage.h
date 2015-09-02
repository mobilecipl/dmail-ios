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

@property NSInteger status;

//Dmail
@property NSString *messageId;
@property NSString *serverId;
@property NSString *messageIdentifier;
@property NSString *gmailId;
@property NSString *access;


// Gmail
@property long long internalDate;
@property NSString *snippet;
@property NSString *fromName;
@property NSString *fromEmail;
@property NSString *subject;
@property NSString *publicKey;
@property NSString *profile;


@property (nonatomic) NSString *body;
@property BOOL read;
@property long long position;
@property NSString *type;

- (instancetype)initWithModel:(ModelMessage *)modelMessage;

@end
