//
//  ServiceSync.m
//  Dmail
//
//  Created by Armen Mkrtchian on 7/7/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "ServiceSync.h"
#import "DmailManager.h"

// service
#import "ServiceContact.h"
#import "ServiceGmailMessage.h"

// dao
#import "DAOSync.h"
#import "DAOMessage.h"

#import "ServiceProfile.h"
#import "NetworkManager.h"

// dao
//#import "DAOSync.h"

@interface ServiceSync ()
@property (nonatomic, strong) ServiceGmailMessage *serviceGmailMessage;

@property (nonatomic, strong) DAOSync *daoSync;
@property (nonatomic, strong) DAOMessage *daoMessage;
@property __block BOOL syncInProgressDmail;
@property __block BOOL syncInProgressGmail;
@property __block BOOL syncInProgressGmailMessages;
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
        
        _syncInProgressDmail = NO;
        _syncInProgressGmail = NO;
        _syncInProgressGmailMessages = NO;
        
        _daoSync = [[DAOSync alloc] init];
        _daoMessage= [[DAOMessage alloc] init];
        _serviceGmailMessage = [[ServiceGmailMessage alloc] init];
    }
    
    return self;
}

- (void)sync {
    
    [self syncDmailMessages];
    [self syncGmailUniqueMessages];
    [self syncGmailMessages];
    
//    [NSTimer scheduledTimerWithTimeInterval:kMessageUpdateTime target:self selector:@selector(syncDmailMessages) userInfo:nil repeats:YES];
    [NSTimer scheduledTimerWithTimeInterval:kMessageUpdateTime target:self selector:@selector(syncGmailUniqueMessages) userInfo:nil repeats:YES];
    [NSTimer scheduledTimerWithTimeInterval:kMessageUpdateTime target:self selector:@selector(syncGmailMessages) userInfo:nil repeats:YES];
    
    [self syncGoogleContacts];
}

- (void)syncDmailMessages {
    
    if (!self.syncInProgressDmail) {
        self.syncInProgressDmail = YES;
        NSString *email = [[ServiceProfile sharedInstance] email];
        NSNumber *position = @100; //[[CoreDataManager sharedCoreDataManager] getLastPosition];
        NSNumber *count = @100;
        if (email) {
            @weakify(self);
            [self.daoSync syncMessagesForEmail:email position:position count:count completionBlock:^(id data, ErrorDataModel *error) {
                @strongify(self);
                self.syncInProgressDmail = NO;
            }];
        } else {
            self.syncInProgressDmail = NO;
        }
    }
}

- (void)syncGmailUniqueMessages {
    
    if (!self.syncInProgressGmail) {
        self.syncInProgressGmail = YES;
        NSString *gmailUniqueId = [self.daoMessage getLastGmailUniqueId];
        NSString *userId = [[[GIDSignIn sharedInstance].currentUser valueForKeyPath:@"userID"] description];
        if (gmailUniqueId) {
            @weakify(self);
            [self.serviceGmailMessage getMessageIdWithUniqueId:gmailUniqueId userId:userId completionBlock:^(id data, ErrorDataModel *error) {
                @strongify(self);
                self.syncInProgressGmail = NO;
            }];
        }
        else {
            self.syncInProgressGmail = NO;
        }
    }
}

- (void)syncGmailMessages {
    
    if (!self.syncInProgressGmailMessages) {
        
        self.syncInProgressGmailMessages = YES;
        NSString *gmailMessageId = [self.daoMessage getLastGmailMessageId];
        NSString *userId = [[[GIDSignIn sharedInstance].currentUser valueForKeyPath:@"userID"] description];
        if (gmailMessageId) {
            @weakify(self);
            [self.serviceGmailMessage getMessageWithMessageId:gmailMessageId userId:userId completionBlock:^(id data, ErrorDataModel *error) {
                @strongify(self);
                self.syncInProgressGmailMessages = NO;
            }];
        }
        else {
            self.syncInProgressGmailMessages = NO;
        }
    }

//    [[DmailManager sharedInstance] getDmailIds];
//    NSString *email = [[ServiceProfile sharedInstance] email];
//    NSNumber *position = @100; //[[CoreDataManager sharedCoreDataManager] getLastPosition];
//    NSNumber *count = @100;
//    
//    if (email) {
//        [self.daoSync syncMessagesForEmail:email position:position count:count completionBlock:^(id data, ErrorDataModel *error) {}];
//    }
}

- (void)syncGoogleContacts {
    
    ServiceContact *serviceContact = [[ServiceContact alloc] init];
    [serviceContact getContactsFromGoogle];
}

@end
