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

// GoogleOauth2
#import "GTMOAuth2ViewControllerTouch.h"
#import "GTMOAuth2SignIn.h"


@interface ServiceSync ()

@property (nonatomic, strong) GTMOAuth2Authentication *auth;
@property (nonatomic, strong) ServiceGmailMessage *serviceGmailMessage;
@property (nonatomic, strong) ServiceProfile *serviceProfile;

@property (nonatomic, strong) DAOSync *daoSync;
@property (nonatomic, strong) DAOMessage *daoMessage;
@property (nonatomic, strong) DAOContact *daoContact;
@property (nonatomic, strong) DAOAddressBook *daoAddressBook;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *keychainName;

@property (nonatomic, strong) NSTimer *timerSyncDmailMessages;
@property (nonatomic, strong) NSTimer *timerSyncGoogleContacts;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, assign) BOOL syncStoped;

@property __block BOOL syncInProgressDmail;
@property __block BOOL syncInProgressGmail;
@property __block BOOL syncInProgressGmailMessages;

@property __block BOOL syncInProgressContact;
@end

@implementation ServiceSync

- (instancetype)initWithEmail:(NSString *)email userId:(NSString *)userId {
    
    self = [super init];
    if (self) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.signedIn = YES;
        
        _syncInProgressDmail = NO;
        _syncInProgressGmail = NO;
        _syncInProgressGmailMessages = NO;
        _syncInProgressContact = NO;
        
        _daoSync = [[DAOSync alloc] init];
        _daoMessage = [[DAOMessage alloc] init];
        _daoContact = [[DAOContact alloc] init];
        
        _serviceGmailMessage = [[ServiceGmailMessage alloc] init];
        _serviceProfile = [[ServiceProfile alloc] init];
        
        [self setupNotifications];
        
        self.email = email;
        self.userId = userId;
        self.keychainName = [self.serviceProfile getKeychainWithEmail:email];
        self.token = [self.serviceProfile getTokenWithEmail:email];
    }
    
    return self;
}

- (void)setupNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncGmailUniqueMessages) name:NotificationGmailUniqueFetched object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncGmailMessages:) name:NotificationGmailIdFetched object:nil];
}

- (void)sync {
    
//    [self syncTemplate];
    if ([self.serviceProfile tokenExpireForEmail:self.email]) {
        [self refreshAccessToken];
    }
    [self syncGoogleContacts];
    [self syncDmailMessages];
    
    self.timerSyncDmailMessages = [NSTimer scheduledTimerWithTimeInterval:kMessageUpdateTime target:self selector:@selector(syncDmailMessages) userInfo:nil repeats:YES];
    self.timerSyncGoogleContacts = [NSTimer scheduledTimerWithTimeInterval:600 target:self selector:@selector(syncGoogleContacts) userInfo:nil repeats:YES];
}

- (void)syncDmailMessages {
    
    if (!self.syncInProgressDmail) {
        self.syncInProgressDmail = YES;
        if(self.email) {
            NSNumber *position = [self.daoMessage getLastDmailPositionWithEmail:self.email forProfile:self.email];
            NSNumber *count = @2000; //TODO: add paging
            if (self.email) {
                @weakify(self);
                if (!self.syncStoped) {
                    NSLog(@"++++++++ syncDmailMessages ==== %@", self.email);
                    [self.daoSync syncMessagesForEmail:self.email position:position count:count completionBlock:^(id hasNewData, ErrorDataModel *error) {
                        @strongify(self);
                        //                    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                        //                    if (appDelegate.signedIn) {
                        self.syncInProgressDmail = NO;
                        if ([hasNewData isEqual:@(YES)]) {
                            if (!self.syncStoped) {
                                [[NSNotificationCenter defaultCenter] postNotificationName:NotificationGmailUniqueFetched object:nil];
                            }
                        }
                        //                    }
                    }];
                }
            } else {
                self.syncInProgressDmail = NO;
            }
        }
    }
}

- (void)syncGmailUniqueMessages {
    
    if (!self.syncInProgressGmail) {
        self.syncInProgressGmail = YES;
        if (!self.syncStoped) {
            RMModelMessage *message = [self.daoMessage getLastGmailUniqueIdForProfile:self.email];
            if (message.messageIdentifier) {
                @weakify(self);
                if (!self.syncStoped) {
                    NSLog(@"++++++++ syncGmailUniqueMessages ==== %@", self.email);
                    [self.serviceGmailMessage getMessageIdWithUniqueId:message.messageIdentifier profileEmail:self.email userId:self.userId serverId:message.serverId token:self.token completionBlock:^(id data, ErrorDataModel *error) {
                        @strongify(self);
                        self.syncInProgressGmail = NO;
                        if (!self.syncStoped) {
                            if ([data isEqual:@(YES)]) {
                                if (!self.syncStoped && message) {
                                    if (self.userId) {
                                        NSLog(@"message.gmailId ==== %@", message.gmailId);
                                        if (message.gmailId) {
                                            NSDictionary *dict = @{@"gmailId" : message.gmailId};
                                            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationGmailIdFetched object:nil userInfo:dict];
                                        }
                                    }
                                }
                            }
                            else {
                                [[NSNotificationCenter defaultCenter] postNotificationName:NotificationGmailUniqueFetched object:nil userInfo:nil];
                            }
                        }
                    }];
                }
            }
            else {
                self.syncInProgressGmail = NO;
            }
        }
    }
}

- (void)syncGmailMessages:(NSNotification *)notification {
    
    if (!self.syncInProgressGmailMessages && [notification userInfo]) {
        self.syncInProgressGmailMessages = YES;
        NSString *gmailMessageId = [[notification userInfo] valueForKey:@"gmailId"];//[self.daoMessage getLastGmailMessageId];
        if (gmailMessageId) {
            @weakify(self);
            NSLog(@"++++++++ syncGmailMessages ==== %@", self.email);
            [self.serviceGmailMessage getMessageWithMessageId:gmailMessageId profileEmail:self.email userId:self.userId completionBlock:^(id data, ErrorDataModel *error) {
                @strongify(self);
                if (!self.syncStoped) {
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
        NSString *startIndex = @"1";
        NSString *maxResult = @"200";
        if (self.email && self.token) {
            @weakify(self);
            [self.daoContact getContactsForEmail:self.email startIndex:startIndex maxResult:maxResult token:self.token completionBlock:^(id data, ErrorDataModel *error) {
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

- (void)refreshAccessToken {
    
    self.auth = nil;
    self.auth = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:self.keychainName clientID:kGoogleClientID clientSecret:kGoogleClientSecret];
    if(self.auth.canAuthorize) {
        NSLog(@"canAuthorize");
    }
    
//    [self.daoSync refreshTokenWith:self.auth.refreshToken completion:^(id data, ErrorDataModel *error) {
//        
//    }];
    
    NSString *requestString = [NSString stringWithFormat:@"https://accounts.google.com/o/oauth2/token"];
    NSString *string = [NSString stringWithFormat:@"client_id=%@&client_secret=%@&refresh_token=%@&grant_type=refresh_token",kGoogleClientID,kGoogleClientSecret,self.auth.refreshToken];
    NSData *postData = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestString]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];//connectionWithRequest:request delegate:self];
    if(connection)
    {
        NSLog(@"Connection Successful");
    }
    else
    {
        NSLog(@"Connection could not be made");
    }
    
    [connection start];
}

- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse *)response {
    
    NSLog(@"Did Receive Response %@", response);
    //NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    self.data = [NSMutableData data];
}

- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data {
    
    NSLog(@"Did Receive Data %@", data);
    [self.data appendData:data];
}

- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error {
    
    NSLog(@"Did Fail %@",error);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSLog(@"Did Finish");
    // Do something with responseData
    NSError *err;
    id JSon = [NSJSONSerialization JSONObjectWithData:self.data options:kNilOptions error:&err];
    if (err) {
        NSLog(@"%@",err);
    }
    else {
        NSLog(@"Json %@",JSon);
        if ([JSon valueForKey:@"access_token"]) {
            [self.serviceProfile updateTokenWithEmail:self.email token:[JSon valueForKey:@"access_token"]];
            NSDate *now = [NSDate date];
            NSDate *dateToFire = [now dateByAddingTimeInterval:[[JSon valueForKey:@"expires_in"] integerValue]];
            NSTimeInterval timeInterval = [dateToFire timeIntervalSince1970];
            [self.serviceProfile updateTokenExpireDateWithEmail:self.email expireDate:timeInterval];
        }
    }
}

- (void)logOut {
    
    if ([self.auth.serviceProvider isEqual:kGTMOAuth2ServiceProviderGoogle]) {
        // remove the token from Google's servers
        [GTMOAuth2ViewControllerTouch revokeTokenForGoogleAuthentication:self.auth];
    }
    
    // remove the stored Google authentication from the keychain, if any
    [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:self.keychainName];
    
    // Discard our retained authentication object.
    self.auth = nil;
}

- (void)stopSync {
    
    self.syncStoped = YES;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    //    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    [[NSUserDefaults standardUserDefaults] synchronize];
    //    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"syncStarted"];
    [self.timerSyncDmailMessages invalidate];
    self.timerSyncDmailMessages = nil;
    [self.timerSyncGoogleContacts invalidate];
    self.timerSyncGoogleContacts = nil;
    [self.daoMessage cancelAllRequests];
    [self.serviceProfile removeProfileWithEmail:self.email];
    [self.daoMessage removeMessagesForProfile:self.email];
    [self.daoMessage removeResipientsForProfile:self.email];
    [self.daoContact removeContactsForProfile:self.email];
}

@end
