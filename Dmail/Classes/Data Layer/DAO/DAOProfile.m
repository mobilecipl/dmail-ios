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

#import <NSDate+DateTools.h>

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

- (void)removeProfileWithEmail:(NSString *)email {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    RLMResults *results = [RMModelProfile objectsInRealm:realm where:@"email = %@", email];
    [realm beginWriteTransaction];
    [realm deleteObjects:results];
    [realm commitWriteTransaction];
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

- (NSString *)getSelectedProfileToken {
    
    NSString *userId;
    RLMRealm *realm = [RLMRealm defaultRealm];
    RLMResults *results = [RMModelProfile objectsInRealm:realm where:@"selected = YES"];
    RMModelProfile *profile = [results firstObject];
    userId = profile.token;
    
    return userId;
}

- (void)selectProfileWithEmail:(NSString *)email {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    RLMResults *results = [RMModelProfile objectsInRealm:realm where:@"selected = YES"];
    RMModelProfile *selectedProfile = [results firstObject];
    RMModelProfile *profile = [RMModelProfile objectForPrimaryKey:email];
    [realm beginWriteTransaction];
    if (selectedProfile) {
        selectedProfile.selected = NO;
    }
    if (profile) {
        profile.selected = YES;
    }
    [realm commitWriteTransaction];
}

- (NSString *)getKeychainWithEmail:(NSString *)email {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    RLMResults *results = [RMModelProfile objectsInRealm:realm where:@"email = %@", email];
    if ([results count] > 0) {
        RMModelProfile *profile = [results firstObject];
        return profile.keychainName;
    }
    
    return nil;
}

- (NSString *)getTokenWithEmail:(NSString *)email {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    RLMResults *results = [RMModelProfile objectsInRealm:realm where:@"email = %@", email];
    if ([results count] > 0) {
        RMModelProfile *profile = [results firstObject];
        return profile.token;
    }
    
    return nil;
}

- (void)updateTokenWithEmail:(NSString *)email token:(NSString *)token {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    RLMResults *results = [RMModelProfile objectsInRealm:realm where:@"email = %@", email];
    if ([results count] > 0) {
        RMModelProfile *profile = [results firstObject];
        [realm beginWriteTransaction];
        profile.token = token;
        [realm commitWriteTransaction];
    }
}

- (void)updateTokenExpireDateWithEmail:(NSString *)email expireDate:(long long)expireDate {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    RLMResults *results = [RMModelProfile objectsInRealm:realm where:@"email = %@", email];
    if ([results count] > 0) {
        RMModelProfile *profile = [results firstObject];
        [realm beginWriteTransaction];
        profile.tokenLastUpdatedate = expireDate;
        [realm commitWriteTransaction];
    }
}

- (BOOL)tokenExpireForEmail:(NSString *)email {
    
    BOOL success = NO;
    RLMRealm *realm = [RLMRealm defaultRealm];
    RLMResults *results = [RMModelProfile objectsInRealm:realm where:@"email = %@", email];
    if ([results count] > 0) {
        RMModelProfile *profile = [results firstObject];
        NSDate *expireDate = [NSDate dateWithTimeIntervalSince1970:profile.tokenLastUpdatedate];
        NSDate *nowDate = [NSDate date];
        success = [nowDate isLaterThan:expireDate];
    }
    
    return success;
}

- (NSString *)getLastProfileKeychanName {
    
    NSString *keychanName;
    NSInteger keychanNumber = 0;
    RLMResults *results = [RMModelProfile allObjects];
    if ([results count] > 0) {
        for (RMModelProfile *profileModel in results) {
            if ([profileModel.keychainName integerValue] > keychanNumber) {
                keychanNumber = [profileModel.keychainName integerValue];
            }
        }
        keychanNumber++;
        keychanName = [NSString stringWithFormat:@"%ld", (long)keychanNumber];
    }
    else {
        keychanName = @"1";
    }
    
    return keychanName;
}

@end
