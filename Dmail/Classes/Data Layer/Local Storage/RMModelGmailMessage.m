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
    
    return @"gmailId";
}

- (instancetype)initWithModel:(ModelGmailMessage *)model {
    
    self = [super init];
    if (self) {
        
        _gmailId = model.gmailId;
        _internalDate = [model.internalDate longLongValue];
        _snippet = model.snippet;
        
        //TODO: parse from to name and email
        _fromName = model.payload.from;
        _fromEmail = model.payload.from;
        _to = model.payload.to;
        _subject = model.payload.subject;
        _messageDate = model.payload.messageDate;
        _messageIdentifier = model.payload.messageIdentifier;
    }
    
    return self;
}

@end
