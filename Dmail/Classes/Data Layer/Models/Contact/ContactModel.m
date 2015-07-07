//
//  ContactModel.m
//  Dmail
//
//  Created by Karen Petrosyan on 7/3/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "ContactModel.h"
#import "RealmContactModel.h"

@implementation ContactModel

- (instancetype)initWithEmail:(NSString *)email fullName:(NSString *)fullName contactId:(NSString *)contactId {
    
    self = [super init];
    if (self) {
        _email = email;
        _fullName = fullName;
        _contactId = contactId;
    }
    
    return self;
}

- (instancetype)initWithRMModel:(RealmContactModel *)rmModel {
    
    self = [super init];
    if (self) {
        _email = rmModel.email;
        _fullName = rmModel.fullName;
        _contactId = rmModel.contactId;
    }
    
    return self;
}

@end