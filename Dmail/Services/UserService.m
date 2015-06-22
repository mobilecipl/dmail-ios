//
//  UserService.m
//  Dmail
//
//  Created by Karen Petrosyan on 6/12/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "UserService.h"
#import "CoreDataManager.h"
#import "User.h"

@implementation UserService

+ (UserService *)sharedInstance {
    static UserService *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[UserService alloc] init];
        
        User *user = [[CoreDataManager sharedCoreDataManager] getUserData];
        sharedInstance.gmailId = user.gmailId;
        sharedInstance.email = user.email;
        sharedInstance.name = user.fullName;
    });
    
    return sharedInstance;
}

- (void)updateUserDetails:(GIDGoogleUser *)user {
    
    self.gmailId = user.userID;
    self.name = user.profile.name;
    self.email = user.profile.email;
    
    [[CoreDataManager sharedCoreDataManager] writeUserDataWith:self];
}

@end
