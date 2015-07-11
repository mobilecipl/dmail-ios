//
//  ServiceSync.m
//  Dmail
//
//  Created by Armen Mkrtchian on 7/7/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "ServiceSync.h"

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
@property (nonatomic, strong) ServiceContact *serviceContact;

@property (nonatomic, strong) DAOSync *daoSync;
@property (nonatomic, strong) DAOMessage *daoMessage;

@property __block BOOL syncInProgressDmail;
@property __block BOOL syncInProgressGmail;
@property __block BOOL syncInProgressGmailMessages;

@property __block BOOL syncInProgressContact;
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
        
        _syncInProgressContact = NO;
        
        _daoSync = [[DAOSync alloc] init];
        _daoMessage = [[DAOMessage alloc] init];
        
        _serviceGmailMessage = [[ServiceGmailMessage alloc] init];
        _serviceContact = [[ServiceContact alloc] init];
    }
    
    [self setupNotifications];
    
    return self;
}

- (void)setupNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncGmailUniqueMessages) name:NotificationNewMessageFetched object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncGmailUniqueMessages) name:NotificationGMailUniqueFetched object:nil];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncGmailMessages) name:NotificationNewMessageFetched object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncGmailMessages) name:NotificationGMailUniqueFetched object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncGmailMessages) name:NotificationGMailMessageFetched object:nil];
}

- (void)sync {
    
    [self syncDmailMessages];
    [self syncGoogleContacts];
    
    [NSTimer scheduledTimerWithTimeInterval:kMessageUpdateTime target:self selector:@selector(syncDmailMessages) userInfo:nil repeats:YES];
    [NSTimer scheduledTimerWithTimeInterval:600 target:self selector:@selector(syncGoogleContacts) userInfo:nil repeats:YES];
}

- (void)syncDmailMessages {
    
    if (!self.syncInProgressDmail) {
        
        self.syncInProgressDmail = YES;
        
        NSString *email = [[ServiceProfile sharedInstance] email];
        NSNumber *position = [self.daoMessage getLastDmailPosition];
        NSNumber *count = @1000; //TODO: add paging
        
        if (email) {
            
            @weakify(self);
            [self.daoSync syncMessagesForEmail:email
                                      position:position
                                         count:count
                               completionBlock:^(id data, ErrorDataModel *error) {
                                   
                                   @strongify(self);
                                   self.syncInProgressDmail = NO;
                                   if ([data isEqual:@(YES)]) {
                                       
                                       [[NSNotificationCenter defaultCenter] postNotificationName:NotificationNewMessageFetched object:nil];
                                   }
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
                [[NSNotificationCenter defaultCenter] postNotificationName:NotificationGMailUniqueFetched object:nil];
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
                
                [[NSNotificationCenter defaultCenter] postNotificationName:NotificationGMailMessageFetched object:nil];
                @strongify(self);
                self.syncInProgressGmailMessages = NO;
            }];
        }
        else {
            
            self.syncInProgressGmailMessages = NO;
        }
    }
}


- (void)syncGoogleContacts {
    
    if (!self.syncInProgressContact) {
        
        self.syncInProgressContact = YES;

        NSString *email = [[ServiceProfile sharedInstance] email];
        
        NSString *maxResult = @"200";
        
        if (email) {
            
            @weakify(self);
            [self.serviceContact getContactsWithPagingForEmail:email
                                                     maxResult:maxResult
                                               completionBlock:^(NSArray *data, ErrorDataModel *error) {
                                                   @strongify(self);
                                                   if (error) {
                                                       //fail
                                                   } else {
                                                       //finishLoading
                                                       NSLog(@"syncGoogleContacts");
                                                   }
                                                   
                                                   self.syncInProgressContact = NO;
                                                   
                                               }];
        } else {
            
            self.syncInProgressContact = NO;
        }
    }
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
