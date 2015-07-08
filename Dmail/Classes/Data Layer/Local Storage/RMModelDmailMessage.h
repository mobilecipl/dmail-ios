//
//  RMModelDmailMessage.h
//  Dmail
//
//  Created by Armen Mkrtchian on 7/7/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "AutoDefaultsRMLObject.h"

@interface RMModelDmailMessage : AutoDefaultsRMLObject

@property NSString *serverId;
@property NSString *access;
@property NSString *dmailId;
@property NSString *messageIdentifier;
@property long long position;
@property NSString *type;

@end
