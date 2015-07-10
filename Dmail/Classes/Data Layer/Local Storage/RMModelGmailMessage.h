//
//  RMModelGmailMessage.h
//  Dmail
//
//  Created by Karen Petrosyan on 7/8/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "AutoDefaultsRMLObject.h"

@interface RMModelGmailMessage : AutoDefaultsRMLObject

//@property NSString *serverId;
//@property NSString *dmailId;
//@property NSString *identifier;
//@property NSString *gmailId;
//
//@property NSString *from;
//@property NSString *to;
//@property NSString *cc;
//@property NSString *bcc;
//@property NSString *label;
//@property NSString *subject;
//@property NSString *publicKey;
//@property long long internalDate;
//@property int type;

@property NSString *gmailId;
@property long long internalDate;
//@property NSArray *labelIds;
@property NSString *snippet;

@property NSString *fromName;
@property NSString *fromEmail;
@property NSString *to;
@property NSString *subject;
@property NSString *messageDate;
@property NSString *messageIdentifier;
@property BOOL read;

@end
