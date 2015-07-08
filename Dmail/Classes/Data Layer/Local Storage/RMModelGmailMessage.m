//
//  RMModelGmailMessage.m
//  Dmail
//
//  Created by Karen Petrosyan on 7/8/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "RMModelGmailMessage.h"
#import "ModelGmailMessage.h"

@implementation RMModelGmailMessage

+ (NSString *)primaryKey {
    
    return @"serverId";
}

- (instancetype)initWithModel:(ModelGmailMessage *)model {
    
    self = [super init];
    if (self) {
        self.dmailId = model.dmailId;
        self.identifier = model.identifier;
        self.gmailId = model.gmailId;
        self.from = model.from;
        self.to = model.to;
        self.cc = model.cc;
        self.bcc = model.bcc;
        self.label = model.label;
        self.subject = model.subject;
        self.publicKey = model.publicKey;
        self.internalDate = model.internalDate;
    }
    
    return self;
}

@end
