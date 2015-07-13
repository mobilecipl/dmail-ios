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

- (instancetype)initWithModel:(ModelRecipient *)modelRecipient {
    
    self = [super init];
    if (self) {
        self.messageId = modelRecipient.messageId;
        self.serverId = modelRecipient.serverId;
        self.access = modelRecipient.access;
        self.name = modelRecipient.name;
        self.email = modelRecipient.email;
        self.type = modelRecipient.type;
    }
    
    return self;
}

@end
