//
//  RMModelMessage.h
//  Dmail
//
//  Created by Armen Mkrtchian on 7/9/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "AutoDefaultsRMLObject.h"

@interface RMModelMessage : AutoDefaultsRMLObject

@property NSString *serverId;
@property NSString *access;
@property NSString *dmailId;

@property NSString *messageIdentifier;

@property NSString *gmailId;

@property long long position;
@property NSString *type;


@end
