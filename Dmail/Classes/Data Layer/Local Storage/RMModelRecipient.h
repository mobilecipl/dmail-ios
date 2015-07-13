//
//  RMModelRecipient.h
//  Dmail
//
//  Created by Karen Petrosyan on 7/13/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "AutoDefaultsRMLObject.h"

@interface RMModelRecipient : AutoDefaultsRMLObject

@property NSString *messageId;
@property NSString *serverId;
@property NSString *access;
@property NSString *name;
@property NSString *email;
@property NSString *type;

@end
