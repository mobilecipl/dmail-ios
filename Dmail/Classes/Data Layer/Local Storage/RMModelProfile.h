//
//  RealmUserData.h
//  Dmail
//
//  Created by Karen Petrosyan on 7/3/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AutoDefaultsRMLObject.h"

@class ProfileModel;

@interface RMModelProfile : AutoDefaultsRMLObject

@property NSString *contactLastUpdateDate;
@property NSString *email;
@property NSString *fullName;
@property NSString *googleId;
@property NSString *imageUrl;
@property NSString *token;
@property NSString *bodyTemplate;
@property long long templateLastUpdateDate;

- (instancetype)initWithProfileModel:(ProfileModel *)model;

@end
