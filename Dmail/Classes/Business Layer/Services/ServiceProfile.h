//
//  UserService.h
//  Dmail
//
//  Created by Karen Petrosyan on 6/12/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <GoogleSignIn/GoogleSignIn.h>

@interface ServiceProfile : NSObject

@property (nonatomic, strong) NSString *googleId;
@property (nonatomic, strong) NSString *fullName;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, assign) BOOL signedIn;

- (void)updateUserDetails:(NSDictionary *)userParameters;
- (void)selectProfileWithEmail:(NSString *)email;
- (NSArray *)getAllProfiles;
- (NSString *)getSelectedProfileEmail;
- (NSString *)getSelectedProfileUserID;
- (NSString *)getKeychainWithEmail:(NSString *)email;
- (NSString *)getTokenWithEmail:(NSString *)email;
- (void)updateTokenWithEmail:(NSString *)email token:(NSString *)token;
- (BOOL)tokenExpireForEmail:(NSString *)email;
- (void)updateTokenExpireDateWithEmail:(NSString *)email expireDate:(long long)expireDate;
- (NSString *)getLastProfileKeychanName;
- (void)removeProfileWithEmail:(NSString *)email;

@end
