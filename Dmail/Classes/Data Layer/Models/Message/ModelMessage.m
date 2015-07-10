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

- (instancetype)initWithRealm:(RMModelMessage *)realm {
    
    self = [super init];
    if (self) {
        
        _fromName = realm.fromName;
        _fromEmail = realm.fromEmail;
        _subject = realm.subject;
        _internalDate = realm.internalDate;
        _publicKey = realm.publicKey;
        _messageIdentifier = realm.messageIdentifier;
        _read = realm.read;
    }
    return self;
}
@end
