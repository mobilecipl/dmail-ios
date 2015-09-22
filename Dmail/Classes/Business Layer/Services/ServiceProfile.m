//
//  UserService.m
//  Dmail
//
//  Created by Karen Petrosyan on 6/12/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "ServiceProfile.h"
#import "ProfileModel.h"
#import "DAOProfile.h"

@interface ServiceProfile ()

@property (nonatomic, strong) ProfileModel *profileModel;
@property (nonatomic, strong) DAOProfile *daoProfile;

@end

@implementation ServiceProfile

- (instancetype)init {
    
    self = [super init];
    if (self) {
        _daoProfile = [[DAOProfile alloc] init];
        ProfileModel *model = [_daoProfile getSelectedProfile];
        if (model) {
            _email = model.email;
            _fullName = model.fullName;
            _googleId = model.googleId;
            _imageUrl = model.imageUrl;
            _token = model.token;
        }
    }
    
    return self;
}

- (void)updateUserDetails:(NSDictionary *)userParameters {
    
    NSLog(@"userParameters ===== %@",userParameters);
    self.profileModel = [[ProfileModel alloc] initWithEmail:userParameters[@"email"]
                                                   fullName:userParameters[@"fullName"]
                                                   googleId:userParameters[@"userID"]
                                                   imageUrl:userParameters[@"imageUrl"]
                                      contactLastUpdateDate:nil
                                                      token:userParameters[@"access_token"]
                                               refreshToken:userParameters[@"refresh_token"]
                                               keychainName:userParameters[@"keychainName"]
                                            tokenExpireTime:[userParameters[@"expires_in"] integerValue]
                                                   selected:YES];
    if (self.profileModel) {
        self.daoProfile = [[DAOProfile alloc] init];
        [self.daoProfile addProfileWithProfileModel:self.profileModel];
    }
}

- (NSArray *)getAllProfiles {
    
    return [self.daoProfile getAllProfiles];
}

- (NSString *)getSelectedProfileEmail {
    
    return [self.daoProfile getSelectedProfileEmail];
}

- (NSString *)getSelectedProfileUserID {
    
    return [self.daoProfile getSelectedProfileUserId];
}

- (void)selectProfileWithEmail:(NSString *)email {
    
    [self.daoProfile selectProfileWithEmail:email];
}

- (NSString *)getKeychainWithEmail:(NSString *)email {
    
    return [self.daoProfile getKeychainWithEmail:email];
}

- (NSString *)getTokenWithEmail:(NSString *)email {
    
    return [self.daoProfile getTokenWithEmail:email];
}

- (void)updateTokenWithEmail:(NSString *)email token:(NSString *)token {
    
    [self.daoProfile updateTokenWithEmail:email token:token];
}

- (void)updateTokenExpireDateWithEmail:(NSString *)email expireDate:(long long)expireDate {
    
    [self.daoProfile updateTokenExpireDateWithEmail:email expireDate:expireDate];
}

- (BOOL)tokenExpireForEmail:(NSString *)email {
    
    return [self.daoProfile tokenExpireForEmail:email];
}

- (NSString *)getLastProfileKeychanName {
    
    return [self.daoProfile getLastProfileKeychanName];
}

- (void)removeProfileWithEmail:(NSString *)email {
    
    [self.daoProfile removeProfileWithEmail:email];
}

@end
