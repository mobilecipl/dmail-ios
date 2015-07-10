//
//  ModelDmailMessage.m
//  Dmail
//
//  Created by Armen Mkrtchian on 7/7/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "ModelDmailMessage.h"

#import "RMModelDmailMessage.h"

@implementation ModelDmailMessage

- (instancetype)initWithRealm:(RMModelDmailMessage *)realm {
    
    self = [super init];
    if (self) {
        
        _serverId = realm.serverId;
        _access = realm.access;
        _messageId = realm.dmailId;
        _messageIdentifier = realm.messageIdentifier;
        _position = @(realm.position);
        _type = realm.type;
        _gmailId = realm.gmailId;
    }
    
    return self;
}

@end
