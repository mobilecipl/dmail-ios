//
//  ProfileModel.m
//  Dmail
//
//  Created by Karen Petrosyan on 7/6/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "ProfileModel.h"
#import "RealmProfile.h"

@implementation ProfileModel

- (instancetype)initWithEmail:(NSString *)email fullName:(NSString *)fullName googleId:(NSString *)googleId contactLastUpdateDate:(NSDate *)contactLastUpdateDate {
    
    self = [super init];
    if (self) {
        _email = email;
        _fullName = fullName;
        _googleId = googleId;
        _contactLastUpdateDate = contactLastUpdateDate;
    }
    
    return self;
}

- (instancetype)initWithRealProfile:(RealmProfile *)realmProfile {
    
    self = [super init];
    if (self) {
        _email = realmProfile.email;
        _fullName = realmProfile.fullName;
        _googleId = realmProfile.googleId;
        _contactLastUpdateDate = realmProfile.contactLastUpdateDate;
    }
    
    return self;
}

@end
