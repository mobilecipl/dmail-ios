//
//  RMModelMessage.
//  Dmail
//
//  Created by Armen Mkrtchian on 7/9/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "RMModelMessage.h"
#import "ModelMessage.h"

@implementation RMModelMessage

+ (NSString *)primaryKey {
    
    return @"serverId";
}

- (instancetype)initWithModel:(ModelMessage *)modelMessage {
    
    self = [super init];
    if (self) {
        self.serverId = modelMessage.serverId;
        self.messageId = modelMessage.messageId;
        self.messageIdentifier = modelMessage.messageIdentifier;
        self.gmailId = modelMessage.gmailId;
        self.type = modelMessage.type;
        self.access = modelMessage.access;
        self.position = modelMessage.position;
        
        self.body = modelMessage.body;
        self.internalDate = modelMessage.internalDate;
        self.to = modelMessage.to;
        self.cc = modelMessage.cc;
        self.bcc = modelMessage.bcc;
        self.snippet = modelMessage.snippet;
        self.publicKey = modelMessage.publicKey;
        self.subject = modelMessage.subject;
        self.fromName = modelMessage.fromName;
        self.fromEmail = modelMessage.fromEmail;
        
        self.status = modelMessage.status;
        self.read = NO;
    }
    
    return self;
}

@end
