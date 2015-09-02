//
//  RealmUserData.m
//  Dmail
//
//  Created by Karen Petrosyan on 7/3/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "RMModelProfile.h"
#import <Realm/Realm.h>
#import "ProfileModel.h"


@implementation RMModelProfile

+ (NSString *)primaryKey {
    
    return @"email";
}

- (instancetype)initWithProfileModel:(ProfileModel *)model {
    
    self = [super init];
    if (self) {
        _email = model.email;
        _fullName = model.fullName;
        _googleId = model.googleId;
        _imageUrl = model.imageUrl;
        _token = model.token;
        _contactLastUpdateDate = model.contactLastUpdateDate;
        _bodyTemplate = model.bodyTemplate;
        _templateLastUpdateDate = model.templateLastUpdateDate;
        _selected = model.selected;
    }
    
    return self;
}

@end
