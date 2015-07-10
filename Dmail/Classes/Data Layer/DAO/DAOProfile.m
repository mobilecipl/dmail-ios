//
//  DAOProfile.m
//  Dmail
//
//  Created by Karen Petrosyan on 7/6/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "DAOProfile.h"
#import "ProfileModel.h"

#import <Realm/Realm.h>
#import "RMModelProfile.h"

@interface DAOProfile ()

@end


@implementation DAOProfile

#pragma mark - Intsance Methods
- (instancetype)init {
    
    if (self) {
        
    }
    
    return self;
}

- (ProfileModel *)getProfile {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    RLMResults *profiles = [RMModelProfile allObjectsInRealm:realm];
    RMModelProfile *RMModelProfile = [profiles firstObject];
    ProfileModel *model = [[ProfileModel alloc] initWithRealProfile:RMModelProfile];
    
    return model;
}

- (void)addProfileWithProfileModel:(ProfileModel *)profileModel {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    RMModelProfile *rmModelProfile = [[RMModelProfile alloc] initWithProfileModel:profileModel];
    [realm beginWriteTransaction];
    [RMModelProfile createOrUpdateInRealm:realm withValue:rmModelProfile];
    [realm commitWriteTransaction];
}

@end
