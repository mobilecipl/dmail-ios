//
//  UserService.m
//  Dmail
//
//  Created by Karen Petrosyan on 6/12/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "UserService.h"

@implementation UserService

+ (UserService *)sharedInstance {
    static UserService *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[UserService alloc] init];
        sharedInstance.userID = [[NSUserDefaults standardUserDefaults] objectForKey:@"userID"];
        sharedInstance.name = [[NSUserDefaults standardUserDefaults] objectForKey:@"name"];
        sharedInstance.email = [[NSUserDefaults standardUserDefaults] objectForKey:@"email"];
    });
    
    return sharedInstance;
}

- (void)updateUserDetails:(GIDGoogleUser *)user {
    
    self.userID = user.userID;
    self.name = user.profile.name;
    self.email = user.profile.email;
    
    [[NSUserDefaults standardUserDefaults] setObject:user.userID forKey:@"userID"];
    [[NSUserDefaults standardUserDefaults] setObject:user.profile.name forKey:@"name"];
    [[NSUserDefaults standardUserDefaults] setObject:user.profile.email forKey:@"email"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
