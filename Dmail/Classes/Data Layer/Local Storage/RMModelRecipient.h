//
//  RMModelRecipient.h
//  Dmail
//
//  Created by Karen Petrosyan on 7/13/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "AutoDefaultsRMLObject.h"

@interface RMModelRecipient : AutoDefaultsRMLObject

@property NSString *access;
@property NSString *messageId;
@property NSString *messageIdentifier;
@property NSString *recipient;
@property NSString *serverId;
@property NSString *type;
@property NSString *profile;
@property long long position;

@property NSString *name;
@property NSString *email;

@end
