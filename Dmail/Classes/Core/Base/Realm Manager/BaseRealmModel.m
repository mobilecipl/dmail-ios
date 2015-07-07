//
//  BaseRealmModel.m
//  pium
//
//  Created by Armen Mkrtchian on 17/11/14.
//  Copyright (c) 2014 Armen Mkrtchian. All rights reserved.
//

#import "BaseRealmModel.h"
#import <Realm/Realm.h>

@implementation BaseRealmModel

- (instancetype)initWithModel:(id)model {
    
    self = [super init];
    if (self) {
        
    }
    
    return self;
}

- (void)saveInDefaultRealm {
    RLMRealm *realm = [RLMRealm defaultRealm];
    [self saveInRealm:realm];
}

- (void)saveInRealm:(RLMRealm *)realm {
    // Save your object
    @weakify(realm);
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        //Background Thread
        @strongify(realm);
        [realm beginWriteTransaction];
        [realm addObject:self];
        [realm commitWriteTransaction];
        dispatch_async(dispatch_get_main_queue(), ^(void){
            //Run UI Updates
        });
    });
}

- (void)createOrUpdateInDefaultRealm {
    RLMRealm *realm = [RLMRealm defaultRealm];
    [self createOrUpdateInRealm:realm];
}

- (void)createOrUpdateInRealm:(RLMRealm *)realm {
    // Save your object
    @weakify(realm);
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        //Background Thread
        @strongify(realm);
        [realm beginWriteTransaction];
        [[self class] createOrUpdateInDefaultRealmWithValue:self];
        [realm commitWriteTransaction];
        dispatch_async(dispatch_get_main_queue(), ^(void){
            //Run UI Updates
        });
    });
}



+ (void)removeAllObjects {
//    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        //Background Thread
        RLMRealm *realm = [RLMRealm defaultRealm];
        RLMResults *arrayOfObjects = [[self class] allObjects];
        [realm beginWriteTransaction];
        [realm deleteObjects:arrayOfObjects];
        [realm commitWriteTransaction];
        dispatch_async(dispatch_get_main_queue(), ^(void){
            //Run UI Updates
        });
//    });
}

@end
