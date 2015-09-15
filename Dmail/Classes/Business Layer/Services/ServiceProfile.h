//
//  UserService.h
//  Dmail
//
//  Created by Karen Petrosyan on 6/12/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleSignIn/GoogleSignIn.h>

@interface ServiceProfile : NSObject

@property (nonatomic, strong) NSString *googleId;
@property (nonatomic, strong) NSString *fullName;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, assign) BOOL signedIn;

- (void)updateUserDetails:(GIDGoogleUser *)user;
- (NSArray *)getAllProfiles;
- (NSString *)getSelectedProfileEmail;
- (NSString *)getSelectedProfileUserID;

@end
