//
//  ProfileModel.h
//  Dmail
//
//  Created by Karen Petrosyan on 7/6/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RMModelProfile;

@interface ProfileModel : NSObject

@property NSDate *contactLastUpdateDate;
@property NSString *email;
@property NSString *fullName;
@property NSString *googleId;
@property NSString *token;
@property NSString *imageUrl;

@property NSString *lastContactsUpdate;

- (instancetype)initWithEmail:(NSString *)email fullName:(NSString *)fullName googleId:(NSString *)googleId imageUrl:(NSString *)imageUrl contactLastUpdateDate:(NSDate *)contactLastUpdateDate token:(NSString *)token;
- (instancetype)initWithRealProfile:(RMModelProfile *)RMModelProfile;

@end
