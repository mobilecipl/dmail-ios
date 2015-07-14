//
//  RMModelRecipient.m
//  Dmail
//
//  Created by Karen Petrosyan on 7/13/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "RMModelRecipient.h"
#import "ModelRecipient.h"

@implementation RMModelRecipient

+ (NSString *)primaryKey {
    
    return @"serverId";
}

- (instancetype)initWithModel:(ModelRecipient *)modelRecipient {
    
    self = [super init];
    if (self) {
        self.access = modelRecipient.access;
        self.messageId = modelRecipient.messageId;
        self.messageIdentifier = modelRecipient.messageIdentifier;
        self.serverId = modelRecipient.serverId;
        self.recipient = modelRecipient.recipient;
        self.position = modelRecipient.position;
        self.name = modelRecipient.name;
        self.email = modelRecipient.email;
        self.type = modelRecipient.type;
    }
    
    return self;
}

@end
