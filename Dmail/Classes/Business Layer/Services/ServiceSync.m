//
//  ServiceSync.m
//  Dmail
//
//  Created by Armen Mkrtchian on 7/7/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "ServiceSync.h"

#import "DAOSync.h"

#import "ServiceContact.h"

#import "ServiceProfile.h"

// dao
//#import "DAOSync.h"

@interface ServiceSync ()
@property (nonatomic, strong) DAOSync *daoSync;
@end

@implementation ServiceSync

+ (ServiceSync *)sharedInstance {
    static ServiceSync *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ServiceSync alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init {
    
    if (self) {
        [NSTimer scheduledTimerWithTimeInterval:kMessageUpdateTime target:self selector:@selector(syncMessages) userInfo:nil repeats:YES];
        _daoSync = [[DAOSync alloc] init];
    }
    
    return self;
}

- (void)sync {
    
    [self syncMessages];
    [self syncGoogleContacts];
}

- (void)syncMessages {
    
    NSString *email = [[ServiceProfile sharedInstance] email];
    NSNumber *position = @100; //[[CoreDataManager sharedCoreDataManager] getLastPosition];
    NSNumber *count = @100;
    
    if (email) {
        [self.daoSync syncMessagesForEmail:email position:position count:count completionBlock:^(id data, ErrorDataModel *error) {}];
    }
}

- (void)syncGoogleContacts {
    
    ServiceContact *serviceContact = [[ServiceContact alloc] init];
    [serviceContact getContactsFromGoogle];
}
@end
