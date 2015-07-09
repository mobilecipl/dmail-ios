//
//  RealmContactModel.m
//  Dmail
//
//  Created by Karen Petrosyan on 7/3/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "RealmContactModel.h"
#import "ContactModel.h"

@implementation RealmContactModel

+ (NSString *)primaryKey {
    
    return @"email";
}

- (instancetype)initWithContactModel:(ContactModel *)model {
    
    self = [super init];
    if (self) {
        _email = model.email;
        _fullName = model.fullName;
        _contactId = model.contactId;
        _urlPhoto = model.urlPhoto;
    }
    
    return self;
}

@end
