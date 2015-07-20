//
//  ModelGmailMessage.m
//  Dmail
//
//  Created by Karen Petrosyan on 7/8/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "ModelGmailMessage.h"

@implementation ModelGmailMessage

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    
    self = [super initWithDictionary:dict];
    if (self) {
        _gmailId = dict[@"id"];
        _snippet = dict[@"snippet"];
        _publicKey = [self getPublicKeyFromSnippet:_snippet];
    }
    
    return self;
}

- (NSString *)getPublicKeyFromSnippet:(NSString *)snippet {
    
    NSString *publicKey = @"";
    
    NSArray *array = [snippet componentsSeparatedByString:@"PublicKey "];
    if([array count] > 1) {
        publicKey = [array objectAtIndex:1];
        array = [publicKey componentsSeparatedByString:@" "];
        publicKey = [array firstObject];
    }
    
    return publicKey;
}

@end
