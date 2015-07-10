//
//  ModelGmailPayload.m
//  Dmail
//
//  Created by Armen Mkrtchian on 7/8/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "ModelGmailPayload.h"

@implementation ModelGmailPayload

- (instancetype)initWithDictionary:(NSDictionary *)dict error:(NSError *__autoreleasing *)err {
    
    self = [super initWithDictionary:dict error:err];
    if (self) {
        
        for (ModelGmailHeader *header in self.headers) {
            if ([header.name isEqualToString:@"From"]) {
                
                self.from = header.value;
                
                _fromEmail = [self getEmailFromFullName:self.from];
                _fromName = [self getNameFromFullName:self.from];
                if (!_fromName) {
                    _fromName = _fromEmail;
                }

                continue;
            }
            
            if ([header.name isEqualToString:@"To"]) {
                
                self.to = [self cleanEmail:header.value];
                continue;
            }
            
            if ([header.name isEqualToString:@"Subject"]) {
               
                self.subject = header.value;
                continue;
            }
            
            if ([header.name isEqualToString:@"Date"]) {
                
                self.messageDate = header.value;
                continue;
            }
            
            if ([header.name isEqualToString:@"Message-Id"]) {
                
                self.messageIdentifier = header.value;
                continue;
            }
        }
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
        cleanedEmail = [[arraySubStrings objectAtIndex:1] substringToIndex:[[arraySubStrings objectAtIndex:1] length]-1];
    }
    else {
        cleanedEmail = email;
    }
    
    return cleanedEmail;
}

@end
