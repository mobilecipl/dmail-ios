//
//  ProfileModel.m
//  Dmail
//
//  Created by Karen Petrosyan on 7/6/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "ProfileModel.h"
#import "RMModelProfile.h"

@implementation ProfileModel

- (instancetype)initWithEmail:(NSString *)email fullName:(NSString *)fullName googleId:(NSString *)googleId imageUrl:(NSString *)imageUrl contactLastUpdateDate:(NSDate *)contactLastUpdateDate {
    
    self = [super init];
    if (self) {
        _email = email;
        _fullName = fullName;
        _googleId = googleId;
        _imageUrl = imageUrl;
        _contactLastUpdateDate = contactLastUpdateDate;
    }
    
    return self;
}

- (instancetype)initWithRealProfile:(RMModelProfile *)RMModelProfile {
    
    self = [super init];
    if (self) {
        _email = RMModelProfile.email;
        _fullName = RMModelProfile.fullName;
        _googleId = RMModelProfile.googleId;
        _imageUrl = RMModelProfile.imageUrl;
        _contactLastUpdateDate = RMModelProfile.contactLastUpdateDate;
    }
    
    return self;
}

@end
