//
//  DAOContact.m
//  Dmail
//
//  Created by Karen Petrosyan on 7/3/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "DAOContact.h"
#import "NetworkContacts.h"
#import "ContactModel.h"
#import "RealmContactModel.h"
#import "RealmProfile.h"
#import <GoogleSignIn/GoogleSignIn.h>
#import <Realm/Realm.h>
#import <NSDate+DateTools.h>
#import "ProfileService.h"

const NSInteger contactsUpdateTime = 12;

@interface DAOContact ()

@property (nonatomic, strong) NetworkContacts *networkContacts;

@end

@implementation DAOContact

#pragma mark - Intsance Methods
- (instancetype)init {
    
    if (self) {
        _networkContacts = [[NetworkContacts alloc] init];
    }
    
    return self;
}


#pragma mark - Public Methods
- (void)syncGoogleContacts {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    RLMResults *profiles = [RealmProfile allObjectsInRealm:realm];
    RealmProfile *profile = [profiles firstObject];
    if (profile) {
        NSDate *contactLastUpdateTime = profile.contactLastUpdateDate;
        NSDate *date = [[NSDate alloc] init];
        NSInteger time = [date hoursLaterThan:contactLastUpdateTime];
        if (time > contactsUpdateTime || !contactLastUpdateTime) {
            [self getContactsFromGoogleWithEmail:profile.email];
        }
    }
}

- (NSMutableArray *)getContactsFromLocalDBWithName:(NSString *)name {
    
    NSMutableArray *arrayContacts = [[NSMutableArray alloc] init];
    if(name.length > 0) {
        NSPredicate *predicate =  [NSPredicate predicateWithFormat:@"fullName CONTAINS [c] %@ OR email CONTAINS [c] %@", name, name];
        RLMResults *result = [RealmContactModel objectsWithPredicate:predicate];
        for (RealmContactModel *rmModel in result) {
            ContactModel *model = [[ContactModel alloc] initWithRMModel:rmModel];
            [arrayContacts addObject:model];
        }
    }
    
    return arrayContacts;
}


#pragma mark - Private Methods
- (void)getContactsFromGoogleWithEmail:(NSString *)email {
    
    [self.networkContacts getGoogleContactsForEmail:email completionBlock:^(id data, ErrorDataModel *error) {
        NSDictionary *contactsDict = (NSDictionary *)data;
        NSArray *arrayModels = [self parseContactsWithDictionary:contactsDict];
        [self saveContacts:arrayModels];
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationUpdateContacts object:nil];
    }];
}

- (NSArray *)parseContactsWithDictionary:(NSDictionary *)dict {
    
    NSMutableArray *arrayModels = [[NSMutableArray alloc] init];
    NSDictionary *dictFeed = dict[@"feed"];
    NSArray *entryFeed = dictFeed[@"entry"];
    for (NSDictionary *dict in entryFeed) {
        NSString *email;
        NSString *fullName;
        NSString *contactId;
        if ([[dict allKeys] containsObject:@"gd:email"]) {
            NSDictionary *emailDict = dict[@"gd:email"];
            email = emailDict[@"address"];
            NSLog(@"email === %@", email);
        }
        if ([[dict allKeys] containsObject:@"gd:name"]) {
            NSDictionary *emailDict = dict[@"gd:name"];
            NSDictionary *fullNameDict = emailDict[@"gd:fullName"];
            fullName = fullNameDict[@"text"];
            NSLog(@"fullName === %@", fullName);
        }
        if ([[dict allKeys] containsObject:@"id"]) {
            NSDictionary *idDict = dict[@"id"];
            contactId = idDict[@"text"];
            NSArray *array = [contactId componentsSeparatedByString:@"/"];
            contactId = [array lastObject];
            NSLog(@"contactId === %@", contactId);
        }
        ContactModel *model = [[ContactModel alloc] initWithEmail:email fullName:fullName contactId:contactId];
        [arrayModels addObject:model];
        NSLog(@"============================================\n");
    }
    
    return [NSArray arrayWithArray:arrayModels];
}

- (void)saveContacts:(NSArray *)contacts {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    for (ContactModel *model in contacts) {
        RealmContactModel *realmModel = [[RealmContactModel alloc] initWithContactModel:model];
        [realm beginWriteTransaction];
        [RealmContactModel createOrUpdateInRealm:realm withValue:realmModel];
        [realm commitWriteTransaction];
    }
}


@end
