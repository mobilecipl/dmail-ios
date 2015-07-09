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
#import "ServiceProfile.h"

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
        NSTimeInterval lastTimeUpdate = [contactLastUpdateTime timeIntervalSince1970];
        [self getContactsFromGoogleWithEmail:profile.email lastUpdateDate:lastTimeUpdate];
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

- (NSString *)contactNameWithEmail:(NSString *)email {
    
    NSString *name;
    NSPredicate *predicate =  [NSPredicate predicateWithFormat:@"email == %@", email];
    RLMResults *result = [RealmContactModel objectsWithPredicate:predicate];
    if ([result count] > 0) {
        RealmContactModel *rmModel = [result firstObject];
        name = rmModel.fullName;
    }
    
    return name;
}


#pragma mark - Private Methods
- (void)getContactsFromGoogleWithEmail:(NSString *)email lastUpdateDate:(long long)lastUpdateDate{
    
    [self.networkContacts getGoogleContactsForEmail:email lastUpdateDate:lastUpdateDate completionBlock:^(id data, ErrorDataModel *error) {
        NSDictionary *contactsDict = (NSDictionary *)data;
        NSArray *contacts = [self parseContactsWithDictionary:contactsDict];
        [self saveContacts:contacts];
        
        [self getGoogleContactsPhotos:contacts];
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationUpdateContacts object:nil];
    }];
}

- (void)getGoogleContactsPhotos:(NSArray *)contacts {
    
    for (ContactModel *contactModel in contacts) {
        
    }
}

- (NSArray *)parseContactsWithDictionary:(NSDictionary *)dict {
    
    NSMutableArray *arrayModels = [[NSMutableArray alloc] init];
    NSDictionary *dictFeed = dict[@"feed"];
    NSArray *entryFeed = dictFeed[@"entry"];
    for (NSDictionary *dict in entryFeed) {
        NSString *email;
        NSString *fullName;
        NSString *contactId;
        NSString *urlPhoto;
        if ([[dict allKeys] containsObject:@"gd$email"]) {
            NSArray *emailArray = dict[@"gd$email"];
            for (NSDictionary *emailDict in emailArray) {
                if ([[emailDict allKeys] containsObject:@"address"]) {
                    email = emailDict[@"address"];
                    break;
                }
            }
        }
        if ([[dict allKeys] containsObject:@"gd$name"]) {
            NSDictionary *nameDict = dict[@"gd$name"];
            NSDictionary *fullNameDict = nameDict[@"gd$fullName"];
            fullName = fullNameDict[@"$t"];
        }
        if ([[dict allKeys] containsObject:@"id"]) {
            NSDictionary *idDict = dict[@"id"];
            contactId = idDict[@"$t"];
            NSArray *array = [contactId componentsSeparatedByString:@"/"];
            contactId = [array lastObject];
            NSLog(@"contactId === %@", contactId);
        }
        if ([[dict allKeys] containsObject:@"link"]) {
            NSArray *hrefArray = dict[@"link"];
            for (NSDictionary *hrefDict in hrefArray) {
                if ([[hrefDict allKeys] containsObject:@"href"]) {
                    urlPhoto = hrefDict[@"href"];
                    NSLog(@"urlPhoto === %@", urlPhoto);
                    break;
                }
            }
        }
        ContactModel *model = [[ContactModel alloc] initWithEmail:email fullName:fullName contactId:contactId urlPhoto:urlPhoto];
        [arrayModels addObject:model];
        NSLog(@"============================================\n");
    }
    
    return [NSArray arrayWithArray:arrayModels];
}

- (void)saveContacts:(NSArray *)contacts {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    for (ContactModel *contactModel in contacts) {
        RealmContactModel *realmModel = [[RealmContactModel alloc] initWithContactModel:contactModel];
        [realm beginWriteTransaction];
        [RealmContactModel createOrUpdateInRealm:realm withValue:realmModel];
        [realm commitWriteTransaction];
    }
}


@end
