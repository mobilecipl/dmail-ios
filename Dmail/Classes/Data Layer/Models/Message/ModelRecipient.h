//
//  ModelRecipient.h
//  Dmail
//
//  Created by Karen Petrosyan on 7/13/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "BaseDataModel.h"

@class RMModelRecipient;

@interface ModelRecipient : BaseDataModel

@property (nonatomic) NSString *messageId;
@property (nonatomic) NSString *messageIdentifier;
@property (nonatomic) NSString *recipient;
@property (nonatomic) NSString *serverId;
@property (nonatomic) NSString *access;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *email;
@property (nonatomic) NSString *type;
@property long long position;

- (instancetype)initWithRealm:(RMModelRecipient *)realm;

@end
