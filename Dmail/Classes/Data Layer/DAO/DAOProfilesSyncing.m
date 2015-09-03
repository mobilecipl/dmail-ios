//
//  DAOProfilesSyncing.m
//  Dmail
//
//  Created by Karen Petrosyan on 9/3/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "DAOProfilesSyncing.h"
#import "DAOProfile.h"
#import "ProfileModel.h"

@interface DAOProfilesSyncing ()

@property (nonatomic, strong) DAOProfile *daoProfile;
@property (nonatomic, strong) NSArray *arrayAllProfiles;

@end

@implementation DAOProfilesSyncing

- (instancetype)init {
    
    self = [super init];
    if (self) {
        _daoProfile = [[DAOProfile alloc] init];
    }
    
    return self;
}

- (NSString *)getSelectedProfileEmail {
    
    return [self.daoProfile getSelectedProfileEmail];
}

- (NSArray *)getAllProfiles {
    
    return [self.daoProfile getAllProfiles];
}

@end
