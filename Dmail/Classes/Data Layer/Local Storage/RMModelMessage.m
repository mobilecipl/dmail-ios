//
//  RMModelMessage.m
//  Dmail
//
//  Created by Armen Mkrtchian on 7/9/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "RMModelMessage.h"
#import "ModelMessage.h"

@implementation RMModelMessage

+ (NSString *)primaryKey {
    
    return @"messageIdentifier";
}

- (instancetype)initWithModel:(ModelMessage *)modelMessage {
    
    self = [super init];
    if (self) {
        self.messageIdentifier = modelMessage.messageIdentifier;
        self.dmailId = modelMessage.dmailId;
        self.gmailId = modelMessage.gmailId;
        self.type = modelMessage.type;
        
        self.read = NO;
        self.internalDate = modelMessage.internalDate;
        self.to = modelMessage.to;
//        self.cc = gmailMessage.cc;
//        self.bcc = gmailMessage.bcc;
        
        self.subject = modelMessage.subject;
        self.from = modelMessage.from;
    }
    
    return self;
}

@end
