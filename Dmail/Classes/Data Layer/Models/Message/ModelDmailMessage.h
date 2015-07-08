//
//  ModelDmailMessage.h
//  Dmail
//
//  Created by Armen Mkrtchian on 7/7/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "BaseDataModel.h"

@interface ModelDmailMessage : BaseDataModel

@property NSString *serverId;
@property NSString *access;
@property NSString *dmailId;
@property NSString *messageIdentifier;
@property NSNumber *position;
@property NSString *type;

@end
