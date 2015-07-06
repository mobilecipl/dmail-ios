//
//  UserService.m
//  Dmail
//
//  Created by Karen Petrosyan on 6/12/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "ProfileService.h"
//#import "CoreDataManager.h"
//#import "User.h"
#import "ProfileModel.h"
#import "DAOProfile.h"

@interface ProfileService ()

@property (nonatomic, strong) ProfileModel *profileModel;
@property (nonatomic, strong) DAOProfile *daoProfile;

@end

@implementation ProfileService

+ (ProfileService *)sharedInstance {
    static ProfileService *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ProfileService alloc] init];
        
        DAOProfile *daoProfile = [[DAOProfile alloc] init];
        ProfileModel *model = [daoProfile getProfile];
        if (model) {
            sharedInstance.email = model.email;
            sharedInstance.fullName = model.fullName;
            sharedInstance.googleId = model.googleId;
        }
    });
    
    return sharedInstance;
}

- (void)updateUserDetails:(GIDGoogleUser *)user {
    
    self.profileModel = [[ProfileModel alloc] initWithEmail:user.profile.email fullName:user.profile.name googleId:user.userID contactLastUpdateDate:nil];
    self.daoProfile = [[DAOProfile alloc] init];
    [self.daoProfile addProfileWithProfileModel:self.profileModel];
}

@end
