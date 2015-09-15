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


- (void)updateUserDetails:(GIDGoogleUser *)user {
    
    NSString *imageUrl = [[user.profile imageURLWithDimension:kProfileImageSize] absoluteString];
    NSString *token = [[user valueForKeyPath:@"authentication.accessToken"] description];
    self.profileModel = [[ProfileModel alloc] initWithEmail:user.profile.email fullName:user.profile.name googleId:user.userID imageUrl:imageUrl contactLastUpdateDate:nil token:token selected:YES];
    if (self.profileModel) {
        self.email = self.profileModel.email;
        self.fullName = self.profileModel.fullName;
        self.googleId = self.profileModel.googleId;
        self.token = self.profileModel.token;
        self.imageUrl = self.profileModel.imageUrl;
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

@end
