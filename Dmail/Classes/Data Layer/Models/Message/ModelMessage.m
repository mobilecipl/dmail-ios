//
//  ModelMessage.m
//  Dmail
//
//  Created by Karen Petrosyan on 7/10/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "ModelMessage.h"
#import "RMModelMessage.h"


@implementation ModelMessage

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    
    self = [super initWithDictionary:dict];
    if (self) {
        _gmailId = dict[@"id"];
        _snippet = dict[@"snippet"];
        _publicKey = [self getPublicKeyFromSnippet:_snippet];
        _body = nil;
    }
    
    return self;
}

- (instancetype)initWithRealm:(RMModelMessage *)realm {
    
    self = [super init];
    if (self) {
        _serverId = realm.serverId;
        _messageId = realm.messageId;
        _messageIdentifier = realm.messageIdentifier;
        _access = realm.access;
        _position = realm.position;
        _type = realm.type;
        
        _gmailId = realm.gmailId;
        _fromName = realm.fromName;
        _fromEmail = realm.fromEmail;
        _subject = realm.subject;
        _internalDate = realm.internalDate;
        _publicKey = realm.publicKey;
        _read = realm.read;
        _profile = realm.profile;
    }
    return self;
}

- (NSString *)getPublicKeyFromSnippet:(NSString *)snippet {
    
    NSString *publicKey = @"";
    
    NSArray *array = [snippet componentsSeparatedByString:@"CLIENT="];
    if([array count] > 1) {
        publicKey = [array objectAtIndex:1];
    }
    
    return publicKey;
}

@end
