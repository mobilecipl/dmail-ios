//
//  CredentialStore.h
//  Core
//
//  Created by Armen on 22/09/13.
//  Copyright (c) 2013 Armen Mkrtchian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CredentialStore : NSObject
+ (CredentialStore *)sharedInstance;
- (BOOL)isLoggedIn;
- (void)clearSavedCredentials;
- (NSString *)authToken;
- (void)setAuthToken:(NSString *)authToken;
@end
