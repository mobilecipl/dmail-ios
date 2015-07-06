//
//  DAOProfile.h
//  Dmail
//
//  Created by Karen Petrosyan on 7/6/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseDAO.h"

@class ProfileModel;

@interface DAOProfile : BaseDAO

- (ProfileModel *)getProfile;
- (void)addProfileWithProfileModel:(ProfileModel *)profileModel;

@end
