//
//  ModelRecipient.m
//  Dmail
//
//  Created by Karen Petrosyan on 7/13/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "ModelRecipient.h"
#import "RMModelRecipient.h"

@implementation ModelRecipient

- (instancetype)initWithRealm:(RMModelRecipient *)realm {
    
    self = [super init];
    if (self) {
        _messageId = realm.messageId;
        _messageIdentifier = realm.messageIdentifier;
        _serverId = realm.serverId;
        _access = realm.access;
        _name = realm.name;
        _email = realm.email;
        _type = realm.type;
        _position = realm.position;
        _recipient = realm.recipient;
    }
    return self;
}


@end
