//
//  DAOProfile.m
//  Dmail
//
//  Created by Karen Petrosyan on 7/6/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "DAOProfile.h"
#import "ProfileModel.h"
#import "RealmProfile.h"
#import <Realm/Realm.h>

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
    RLMResults *profiles = [RealmProfile allObjectsInRealm:realm];
    RealmProfile *realmProfile = [profiles firstObject];
    ProfileModel *model = [[ProfileModel alloc] initWithRealProfile:realmProfile];
    
    return model;
}

- (void)addProfileWithProfileModel:(ProfileModel *)profileModel {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    RealmProfile *realmProfile = [[RealmProfile alloc] initWithProfileModel:profileModel];
    [realm beginWriteTransaction];
    [RealmProfile createOrUpdateInRealm:realm withValue:realmProfile];
    [realm commitWriteTransaction];
}

@end
