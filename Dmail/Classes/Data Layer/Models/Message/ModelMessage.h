//
//  ModelMessage.h
//  Dmail
//
//  Created by Karen Petrosyan on 7/10/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "BaseDataModel.h"
#import "ModelGmailPayload.h"

@interface ModelMessage : BaseDataModel

@property NSInteger status;

//Dmail
@property (nonatomic) NSString *serverId;
@property (nonatomic) NSString *messageId;
@property (nonatomic) NSString *messageIdentifier;
@property (nonatomic) NSString *gmailId;
@property (nonatomic) NSString *access;
@property long long position;
@property NSString *type;


//Gmail
@property NSArray *labelIds;
@property ModelGmailPayload *payload;
@property NSString *snippet;
@property (nonatomic) long long internalDate;
@property (nonatomic) NSString *subject;
@property (nonatomic) NSString *body;


@property NSString *fromName;
@property NSString *fromEmail;
@property NSString *to;
@property NSString *cc;
@property NSString *bcc;
@property NSString *publicKey;

@property NSString *imageUrl;
@property BOOL read;



@end
