//
//  DAOProfile.h
//  Dmail
//
//  Created by Karen Petrosyan on 7/6/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "BaseDAO.h"

@class ProfileModel;

@interface DAOProfile : BaseDAO

- (ProfileModel *)getProfile;
- (void)addProfileWithProfileModel:(ProfileModel *)profileModel;
- (void)removeProfileWithEmail:(NSString *)email completionBlock:(CompletionBlock)completionBlock;
- (ProfileModel *)getSelectedProfile;
- (NSString *)getSelectedProfileEmail;
- (NSString *)getSelectedProfileUserId;

@end
