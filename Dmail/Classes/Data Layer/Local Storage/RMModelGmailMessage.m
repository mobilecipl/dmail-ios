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
        
        _fromEmail = [self getEmailFromFullName:model.payload.from];
        _fromName = [self getNameFromFullName:model.payload.from];
        if (!_fromName) {
            _fromName = _fromEmail;
        }
        _to = [self cleanEmail:model.payload.to];
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

- (NSString *)cleanEmail:(NSString *)email {
    
    NSString *cleanedEmail;
    NSArray *arraySubStrings = [email componentsSeparatedByString:@"<"];
    if ([arraySubStrings count] > 1) {
        NSLog(@"arraySubStrings ==== %@", arraySubStrings);
        email = [[arraySubStrings objectAtIndex:1] substringToIndex:[[arraySubStrings objectAtIndex:1] length]-1];
    }
    else {
        email = email;
    }
    
    return email;
    
    return cleanedEmail;
}

@end
