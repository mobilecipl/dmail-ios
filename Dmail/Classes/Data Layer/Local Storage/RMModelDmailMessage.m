//
//  RMModelDmailMessage.m
//  Dmail
//
//  Created by Armen Mkrtchian on 7/7/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "RMModelDmailMessage.h"

#import "ModelDmailMessage.h"

@implementation RMModelDmailMessage

+ (NSString *)primaryKey {
    
    return @"messageId";
}

- (instancetype)initWithModel:(ModelDmailMessage *)model {
    
    self = [super init];
    if (self) {
        
        _access = model.access;
        _messageId = model.messageId;
        _messageIdentifier = model.messageIdentifier;
        _position = [model.position longLongValue];
        _type = model.type;
    }
    
    return self;
}
@end
