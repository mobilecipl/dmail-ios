//
//  ServiceProfilesSyncing.h
//  Dmail
//
//  Created by Karen Petrosyan on 9/3/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "BaseService.h"

@interface ServiceProfilesSyncing : BaseService

- (void)addProfileWithEmail:(NSString *)email googleId:(NSString *)googleId;
- (BOOL)hasProfile;
- (void)sync;
- (void)logOutProfileWithEmail:(NSString *)email completion:(CompletionBlock)completionBlock;

@end
