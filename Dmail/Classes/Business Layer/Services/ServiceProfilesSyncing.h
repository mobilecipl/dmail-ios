//
//  ServiceProfilesSyncing.h
//  Dmail
//
//  Created by Karen Petrosyan on 9/3/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServiceProfilesSyncing : NSObject

- (void)addProfileWithEmail:(NSString *)email googleId:(NSString *)googleId;
- (BOOL)hasProfile;
- (void)sync;
- (void)logOutProfileWithEmail:(NSString *)email;

@end
