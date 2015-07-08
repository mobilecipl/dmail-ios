//
//  ModelGmailMessage.h
//  Dmail
//
//  Created by Karen Petrosyan on 7/8/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "BaseDataModel.h"

@interface ModelGmailMessage : BaseDataModel

@property NSString *dmailId;
@property NSString *identifier;
@property NSString *gmailId;

@property NSString *from;
@property NSString *to;
@property NSString *cc;
@property NSString *bcc;
@property NSString *label;
@property NSString *subject;
@property NSString *publicKey;
@property long long internalDate;
@property int type;

@end
