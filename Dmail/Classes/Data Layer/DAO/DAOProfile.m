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

- (void)removeProfileWithEmail:(NSString *)email completionBlock:(CompletionBlock)completionBlock {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    RLMResults *results = [RMModelProfile objectsInRealm:realm where:@"email = %@", email];
    if ([results count] > 0) {
        
    }
}

- (NSArray *)getAllProfiles {
    
    NSMutableArray *arrayAllProfiles = [[NSMutableArray alloc] init];
    RLMResults *results = [RMModelProfile allObjects];
    for (RMModelProfile *profile in results) {
        ProfileModel *profileModel = [[ProfileModel alloc] initWithRealProfile:profile];
        [arrayAllProfiles addObject:profileModel];
    }
    return [NSArray arrayWithArray:arrayAllProfiles];
}

- (ProfileModel *)getSelectedProfile {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    RLMResults *results = [RMModelProfile objectsInRealm:realm where:@"selected = YES"];
    RMModelProfile *profile = [results firstObject];
    if (profile) {
        ProfileModel *profileModel = [[ProfileModel alloc] initWithRealProfile:profile];
        return profileModel;
    }
    
    return nil;
}
    
- (NSString *)getSelectedProfileEmail {
    
    NSString *email;
    RLMRealm *realm = [RLMRealm defaultRealm];
    RLMResults *results = [RMModelProfile objectsInRealm:realm where:@"selected = YES"];
    RMModelProfile *profile = [results firstObject];
    email = profile.email;
    if(email.length == 0) {
        email = nil;
    }
    
    return email;
}

- (NSString *)getSelectedProfileUserId {
    
    NSString *userId;
    RLMRealm *realm = [RLMRealm defaultRealm];
    RLMResults *results = [RMModelProfile objectsInRealm:realm where:@"selected = YES"];
    RMModelProfile *profile = [results firstObject];
    userId = profile.googleId;
    
    return userId;
}


@end
