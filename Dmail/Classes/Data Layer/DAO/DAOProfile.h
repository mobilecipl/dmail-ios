//
//  DAOProfile.h
//  Dmail
//
//  Created by Karen Petrosyan on 7/6/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "BaseDAO.h"

@class ProfileModel;

@interface DAOProfile : BaseDAO

- (ProfileModel *)getProfile;
- (void)addProfileWithProfileModel:(ProfileModel *)profileModel;
- (void)removeProfileWithEmail:(NSString *)email;
- (NSArray *)getAllProfiles;
- (ProfileModel *)getSelectedProfile;
- (NSString *)getSelectedProfileEmail;
- (NSString *)getSelectedProfileUserId;
- (NSString *)getSelectedProfileToken;
- (void)selectProfileWithEmail:(NSString *)email;
- (NSString *)getKeychainWithEmail:(NSString *)email;
- (void)updateTokenWithEmail:(NSString *)email token:(NSString *)token;
- (NSString *)getTokenWithEmail:(NSString *)email;
- (BOOL)tokenExpireForEmail:(NSString *)email;
- (void)updateTokenExpireDateWithEmail:(NSString *)email expireDate:(long long)expireDate;
- (NSString *)getLastProfileKeychanName;

@end
