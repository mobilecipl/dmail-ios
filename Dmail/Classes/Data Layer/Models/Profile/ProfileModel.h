//
//  ProfileModel.h
//  Dmail
//
//  Created by Karen Petrosyan on 7/6/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RealmProfile;

@interface ProfileModel : NSObject

@property NSDate *contactLastUpdateDate;
@property NSString *email;
@property NSString *fullName;
@property NSString *googleId;

- (instancetype)initWithEmail:(NSString *)email fullName:(NSString *)fullName googleId:(NSString *)googleId contactLastUpdateDate:(NSDate *)contactLastUpdateDate;
- (instancetype)initWithRealProfile:(RealmProfile *)realmProfile;

@end
