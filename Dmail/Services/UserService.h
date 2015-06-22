//
//  UserService.h
//  Dmail
//
//  Created by Karen Petrosyan on 6/12/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleSignIn/GoogleSignIn.h>

@interface UserService : NSObject

@property (nonatomic, strong) NSString *gmailId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *email;

+ (UserService *)sharedInstance;

- (void)updateUserDetails:(GIDGoogleUser *)user;

@end
