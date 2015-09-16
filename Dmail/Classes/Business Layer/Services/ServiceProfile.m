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
    
    self.profileModel = [[ProfileModel alloc] initWithEmail:userParameters[@"email"]
                                                   fullName:userParameters[@"fullName"]
                                                   googleId:userParameters[@"userID"]
                                                   imageUrl:userParameters[@"imageUrl"]
                                      contactLastUpdateDate:nil
                                                      token:userParameters[@"access_token"]
                                               refreshToken:userParameters[@"refresh_token"]
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

@end
