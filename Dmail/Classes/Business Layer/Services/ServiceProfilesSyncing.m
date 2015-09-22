//
//  ServiceProfilesSyncing.m
//  Dmail
//
//  Created by Karen Petrosyan on 9/3/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "ServiceProfilesSyncing.h"
#import "ServiceSync.h"

//DAO
#import "DAOProfilesSyncing.h"
#import "DAOAddressBook.h"
#import "DAOMessage.h"

//Models
#import "ProfileModel.h"

@interface ServiceProfilesSyncing ()

@property (nonatomic, strong) ServiceSync *serviceSync;
@property (nonatomic, strong) DAOProfilesSyncing *daoProfilesSyncing;
@property (nonatomic, strong) DAOAddressBook *daoAddressBook;
@property (nonatomic, strong) DAOMessage *daoMessage;
@property (nonatomic, strong) NSArray *arrayAllProfiles;
@property (nonatomic, strong) NSMutableArray *arraySyncsProfiles;

@end

@implementation ServiceProfilesSyncing

- (instancetype)init {
    
    self = [super init];
    if (self) {
        _daoProfilesSyncing = [[DAOProfilesSyncing alloc] init];
        _daoAddressBook = [[DAOAddressBook alloc] init];
        _daoMessage = [[DAOMessage alloc] init];
        [self syncAddressBookContacts];
    }
    
    return self;
}

- (BOOL)hasProfile {
    
    NSString *email = [self.daoProfilesSyncing getSelectedProfileEmail];
    if (email) {
        return YES;
    }
    
    return NO;
}

- (void)sync {
    
    self.arrayAllProfiles = [self.daoProfilesSyncing getAllProfiles];
    self.arraySyncsProfiles = [[NSMutableArray alloc] init];
    for (ProfileModel *model in self.arrayAllProfiles) {
        ServiceSync *serviceSync = [[ServiceSync alloc] initWithEmail:model.email userId:model.googleId];
        serviceSync.email = model.email;
        serviceSync.token = model.token;
        [self.arraySyncsProfiles addObject:serviceSync];
        [serviceSync sync];
    }
    
    [self syncTemplate];
}

- (void)syncTemplate {
    
    [self.daoMessage getTemplateWithCompletionBlock:^(NSString *template, ErrorDataModel *error) {
        
    }];
}

- (void)syncAddressBookContacts {
    
    [self.daoAddressBook syncAddressBook];
}

- (void)addProfileWithEmail:(NSString *)email googleId:(NSString *)googleId {
    
    ServiceSync *serviceSync = [[ServiceSync alloc] initWithEmail:email userId:googleId];
    [self.arraySyncsProfiles addObject:serviceSync];
    [serviceSync sync];
}

- (void)logOutProfileWithEmail:(NSString *)email completion:(CompletionBlock)completionBlock {
    
    for (ServiceSync *serviceSync in self.arraySyncsProfiles) {
        if ([serviceSync.email isEqualToString:email]) {
            [serviceSync stopSync];
            [serviceSync logOut];
            [self.arraySyncsProfiles removeObject:serviceSync];
            break;
        }
    }
    completionBlock (nil,nil);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ProfileRemoved" object:nil];
}


@end
