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
#import "ServiceProfile.h"

// dao
#import "DAOSync.h"
#import "DAOMessage.h"
#import "DAOContact.h"


// realm
#import "RMModelMessage.h"
#import "RMModelRecipient.h"


@interface ServiceSync ()
@property (nonatomic, strong) ServiceGmailMessage *serviceGmailMessage;

@property (nonatomic, strong) DAOSync *daoSync;
@property (nonatomic, strong) DAOMessage *daoMessage;
@property (nonatomic, strong) DAOContact *daoContact;

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
        _daoContact = [[DAOContact alloc] init];
        
        _serviceGmailMessage = [[ServiceGmailMessage alloc] init];
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
    
    [self syncTemplate];
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
            [self.daoSync syncMessagesForEmail:email position:position count:count completionBlock:^(id hasNewData, ErrorDataModel *error) {
                @strongify(self);
                self.syncInProgressDmail = NO;
                if ([hasNewData isEqual:@(YES)]) {
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationGMailUniqueFetched object:nil];
                } else {
                    
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
        RMModelMessage *message = [self.daoMessage getLastGmailUniqueId];
        NSString *userId = [[[GIDSignIn sharedInstance].currentUser valueForKeyPath:@"userID"] description];
        if (message.messageIdentifier) {
            @weakify(self);
            [self.serviceGmailMessage getMessageIdWithUniqueId:message.messageIdentifier userId:userId serverId:message.serverId completionBlock:^(id data, ErrorDataModel *error) {
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
        NSString *startIndex = @"1";
        NSString *maxResult = @"200";
        if (email) {
            @weakify(self);
            [self.daoContact getContactsForEmail:email startIndex:startIndex maxResult:maxResult completionBlock:^(id data, ErrorDataModel *error) {
                @strongify(self);
                self.syncInProgressContact = NO;
            }];
        } else {
            self.syncInProgressContact = NO;
        }
    }
}

- (void)syncTemplate {
    
    [self.daoMessage getTemplateWithCompletionBlock:^(NSString *template, ErrorDataModel *error) {

    }];
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
