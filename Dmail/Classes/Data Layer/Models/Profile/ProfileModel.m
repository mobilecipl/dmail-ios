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

- (instancetype)initWithEmail:(NSString *)email
                     fullName:(NSString *)fullName
                     googleId:(NSString *)googleId
                     imageUrl:(NSString *)imageUrl
        contactLastUpdateDate:(NSString *)contactLastUpdateDate
                        token:(NSString *)token
                 refreshToken:(NSString *)refreshToken
                     selected:(BOOL)selected {
    
    self = [super init];
    if (self) {
        _email = email;
        _fullName = fullName;
        _googleId = googleId;
        _imageUrl = imageUrl;
        _contactLastUpdateDate = contactLastUpdateDate;
        _token = token;
        _refreshToken = refreshToken;
        _selected = selected;
    }
    
    return self;
}

- (instancetype)initWithRealProfile:(RMModelProfile *)rmModelProfile {
    
    self = [super init];
    if (self) {
        _email = rmModelProfile.email;
        _fullName = rmModelProfile.fullName;
        _googleId = rmModelProfile.googleId;
        _imageUrl = rmModelProfile.imageUrl;
        _token = rmModelProfile.token;
        _refreshToken = rmModelProfile.refreshToken;
        _contactLastUpdateDate = rmModelProfile.contactLastUpdateDate;
        _bodyTemplate = rmModelProfile.bodyTemplate;
        _templateLastUpdateDate = rmModelProfile.templateLastUpdateDate;
        _selected = rmModelProfile.selected;
    }
    
    return self;
}

@end
