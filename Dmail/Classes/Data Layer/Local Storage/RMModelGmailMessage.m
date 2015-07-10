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
        _fromEmail = [self getEmailFromFullName:model.payload.from];
        _fromName = [self getNameFromFullName:model.payload.from];
        if (!_fromName) {
            _fromName = _fromEmail;
        }
        _to = model.payload.to;
        _subject = model.payload.subject;
        _messageDate = model.payload.messageDate;
        _messageIdentifier = model.payload.messageIdentifier;
    }
    
    return self;
}

- (NSString *)getEmailFromFullName:(NSString *)fullName {
    
    NSString *email;
    NSArray *arraySubStrings = [fullName componentsSeparatedByString:@"<"];
    if ([arraySubStrings count] > 1) {
        email = [[arraySubStrings objectAtIndex:1] substringToIndex:[[arraySubStrings objectAtIndex:1] length]-1];
    }
    else {
        email = fullName;
    }
    
    return email;
}

- (NSString *)getNameFromFullName:(NSString *)fullName {
    
    NSString *name;
    
    NSArray *arraySubStrings = [fullName componentsSeparatedByString:@"<"];
    if ([arraySubStrings count] > 1) {
        name = [arraySubStrings firstObject];
        name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    
    return name;
}

@end
