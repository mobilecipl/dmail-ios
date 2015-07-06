//
//  SyncService.m
//  Dmail
//
//  Created by Karen Petrosyan on 6/23/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "SyncService.h"
#import "Constants.h"
#import "DmailManager.h"
#import "ServiceContact.h"

@implementation SyncService


#pragma mark - Class Methods
+ (SyncService *)sharedInstance {
    static SyncService *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SyncService alloc] init];
        [NSTimer scheduledTimerWithTimeInterval:kMessageUpdateTime target:sharedInstance selector:@selector(getMessageIds) userInfo:nil repeats:YES];
    });
    
    return sharedInstance;
}


#pragma mark - Private Methods
- (void)getMessageIds {
    
    [[DmailManager sharedInstance] getDmailIds];
}

- (void)syncGoogleContacts {
    
    ServiceContact *serviceContact = [[ServiceContact alloc] init];
    [serviceContact getContactsFromGoogle];
}

@end
