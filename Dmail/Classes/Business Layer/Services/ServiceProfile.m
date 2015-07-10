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

+ (ServiceProfile *)sharedInstance {
    static ServiceProfile *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ServiceProfile alloc] init];
        
        DAOProfile *daoProfile = [[DAOProfile alloc] init];
        ProfileModel *model = [daoProfile getProfile];
        if (model) {
            sharedInstance.email = model.email;
            sharedInstance.fullName = model.fullName;
            sharedInstance.googleId = model.googleId;
            sharedInstance.imageUrl = model.imageUrl;
        }
    });
    
    return sharedInstance;
}

- (void)updateUserDetails:(GIDGoogleUser *)user {
    
    NSString *imageUrl = [[user.profile imageURLWithDimension:kProfileImageSize] absoluteString];
    self.profileModel = [[ProfileModel alloc] initWithEmail:user.profile.email fullName:user.profile.name googleId:user.userID imageUrl:imageUrl contactLastUpdateDate:nil];
    if (self.profileModel) {
        self.email = self.profileModel.email;
        self.fullName = self.profileModel.fullName;
        self.googleId = self.profileModel.googleId;
        self.daoProfile = [[DAOProfile alloc] init];
        self.imageUrl = self.profileModel.imageUrl;
        [self.daoProfile addProfileWithProfileModel:self.profileModel];
    }
}

@end
