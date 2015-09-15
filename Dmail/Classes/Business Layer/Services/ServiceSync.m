//
//  ServiceSync.m
//  Dmail
//
//  Created by Armen Mkrtchian on 7/7/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "ServiceSync.h"
#import "AppDelegate.h"

// service
#import "ServiceContact.h"
#import "ServiceGmailMessage.h"
#import "ServiceProfile.h"

// dao
#import "DAOSync.h"
#import "DAOMessage.h"
#import "DAOContact.h"
#import "DAOAddressBook.h"


// realm
#import "RMModelMessage.h"
#import "RMModelRecipient.h"


@interface ServiceSync ()
@property (nonatomic, strong) ServiceGmailMessage *serviceGmailMessage;
@property (nonatomic, strong) ServiceProfile *serviceProfile;

@property (nonatomic, strong) DAOSync *daoSync;
@property (nonatomic, strong) DAOMessage *daoMessage;
@property (nonatomic, strong) DAOContact *daoContact;
@property (nonatomic, strong) DAOAddressBook *daoAddressBook;
@property (nonatomic, strong) NSString *userId;

@property (nonatomic, strong) NSTimer *timerSyncDmailMessages;
@property (nonatomic, strong) NSTimer *timerSyncGoogleContacts;

@property __block BOOL syncInProgressDmail;
@property __block BOOL syncInProgressGmail;
@property __block BOOL syncInProgressGmailMessages;

@property __block BOOL syncInProgressContact;
@end

@implementation ServiceSync

- (instancetype)initWithEmail:(NSString *)email userId:(NSString *)userId {
    
    self = [super init];
    if (self) {
        self.email = email;
        self.userId = userId;
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if(!appDelegate.signedIn) {
            appDelegate.signedIn = YES;
            
            _syncInProgressDmail = NO;
            _syncInProgressGmail = NO;
            _syncInProgressGmailMessages = NO;
            _syncInProgressContact = NO;
            
            _daoSync = [[DAOSync alloc] init];
            _daoMessage = [[DAOMessage alloc] init];
            _daoContact = [[DAOContact alloc] init];
//            _daoAddressBook = [[DAOAddressBook alloc] init];
            
            _serviceGmailMessage = [[ServiceGmailMessage alloc] init];
            _serviceProfile = [[ServiceProfile alloc] init];
            
            [self setupNotifications];
//            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"syncStarted"];
//            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    
    return self;
}

//- (instancetype)init {
//    
//    self = [super init];
//    if (self) {
//        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//        if(!appDelegate.signedIn) {
//            appDelegate.signedIn = YES;
//            
//            _syncInProgressDmail = NO;
//            _syncInProgressGmail = NO;
//            _syncInProgressGmailMessages = NO;
//            _syncInProgressContact = NO;
//            
//            _daoSync = [[DAOSync alloc] init];
//            _daoMessage = [[DAOMessage alloc] init];
//            _daoContact = [[DAOContact alloc] init];
//            _daoAddressBook = [[DAOAddressBook alloc] init];
//            
//            _serviceGmailMessage = [[ServiceGmailMessage alloc] init];
//            _serviceProfile = [[ServiceProfile alloc] init];
//            
//            [self setupNotifications];
//            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"syncStarted"];
//            [[NSUserDefaults standardUserDefaults] synchronize];
//        }
//    }
//    
//    return self;
//}

- (void)setupNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncGmailUniqueMessages) name:NotificationGmailUniqueFetched object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncGmailMessages:) name:NotificationGmailIdFetched object:nil];
}

- (void)sync {
    
//    [self syncTemplate];
//    [self syncAddressBookContacts];
    [self syncGoogleContacts];
    [self syncDmailMessages];
    
    self.timerSyncDmailMessages = [NSTimer scheduledTimerWithTimeInterval:kMessageUpdateTime target:self selector:@selector(syncDmailMessages) userInfo:nil repeats:YES];
    self.timerSyncGoogleContacts = [NSTimer scheduledTimerWithTimeInterval:600 target:self selector:@selector(syncGoogleContacts) userInfo:nil repeats:YES];
}

- (void)syncDmailMessages {
    
    if (!self.syncInProgressDmail) {
        self.syncInProgressDmail = YES;
//        NSString *email = [self.serviceProfile getSelectedProfileEmail];
        if(self.email) {
            NSNumber *position = [self.daoMessage getLastDmailPositionWithEmail:self.email];
            NSNumber *count = @2000; //TODO: add paging
            if (self.email) {
                @weakify(self);
                [self.daoSync syncMessagesForEmail:self.email position:position count:count completionBlock:^(id hasNewData, ErrorDataModel *error) {
                    @strongify(self);
//                    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//                    if (appDelegate.signedIn) {
                        self.syncInProgressDmail = NO;
                        if ([hasNewData isEqual:@(YES)]) {
                            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationGmailUniqueFetched object:nil];
                        }
//                    }
                }];
            } else {
                self.syncInProgressDmail = NO;
            }
        }
    }
}

- (void)syncGmailUniqueMessages {
    
    if (!self.syncInProgressGmail) {
        self.syncInProgressGmail = YES;
        RMModelMessage *message = [self.daoMessage getLastGmailUniqueId];
        if (message.messageIdentifier) {
            @weakify(self);
            [self.serviceGmailMessage getMessageIdWithUniqueId:message.messageIdentifier userId:self.userId serverId:message.serverId completionBlock:^(id data, ErrorDataModel *error) {
                @strongify(self);
                self.syncInProgressGmail = NO;
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                if (appDelegate.signedIn) {
                    if ([data isEqual:@(YES)]) {
                        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                        if (appDelegate.signedIn || message.gmailId ) {
                            if (self.userId) {
                                NSDictionary *dict = @{@"gmailId" : message.gmailId};
                                [[NSNotificationCenter defaultCenter] postNotificationName:NotificationGmailIdFetched object:nil userInfo:dict];
                            }
                        }
                    }
                    else {
                        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationGmailUniqueFetched object:nil userInfo:nil];
                    }
                }
            }];
        }
        else {
            self.syncInProgressGmail = NO;
        }
    }
}

- (void)syncGmailMessages:(NSNotification *)notification {
    
    if (!self.syncInProgressGmailMessages && [notification userInfo]) {
        self.syncInProgressGmailMessages = YES;
        NSString *gmailMessageId = [[notification userInfo] valueForKey:@"gmailId"];//[self.daoMessage getLastGmailMessageId];
        if (gmailMessageId) {
            @weakify(self);
            [self.serviceGmailMessage getMessageWithMessageId:gmailMessageId userId:self.userId completionBlock:^(id data, ErrorDataModel *error) {
                @strongify(self);
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                if (appDelegate.signedIn) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationGmailUniqueFetched object:nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationGmailMessageFetched object:nil];
                    self.syncInProgressGmailMessages = NO;
                }
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
        NSString *email = [self.serviceProfile email];
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

- (void)syncAddressBookContacts {
    
    [self.daoAddressBook syncAddressBook];
}

- (void)syncTemplate {
    
    [self.daoMessage getTemplateWithCompletionBlock:^(NSString *template, ErrorDataModel *error) {

    }];
}

- (void)stopSync {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    [[NSUserDefaults standardUserDefaults] synchronize];
//    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"syncStarted"];
    [self.timerSyncDmailMessages invalidate];
    self.timerSyncDmailMessages = nil;
    [self.timerSyncGoogleContacts invalidate];
    self.timerSyncGoogleContacts = nil;
    [self.daoMessage cancelAllRequests];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.signedIn = NO;
}

@end
