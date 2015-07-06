//
//  UserService.h
//  Dmail
//
//  Created by Karen Petrosyan on 6/12/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleSignIn/GoogleSignIn.h>

@interface ProfileService : NSObject

@property (nonatomic, strong) NSString *googleId;
@property (nonatomic, strong) NSString *fullName;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, assign) BOOL signedIn;

+ (ProfileService *)sharedInstance;

- (void)updateUserDetails:(GIDGoogleUser *)user;

@end
