//
//  DAOAddressBook.m
//  Dmail
//
//  Created by Karen Petrosyan on 8/25/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "DAOAddressBook.h"

#import <AddressBook/ABAddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "ContactModel.h"

// realm
#import <Realm/Realm.h>
#import "RMModelContact.h"
#import "RMModelProfile.h"

static BOOL shouldSyncAddressBookChanges = YES;

@implementation DAOAddressBook

#pragma mark - Class Methods
- (instancetype)init {
    
    self = [super init];
    if (self) {
        [self registerForAddressBookChanges];
    }
    
    return self;
}

#pragma mark - Public Methods
- (void)syncAddressBook {
    
    if ([DAOAddressBook authorized]) {
        NSArray *phoneContacts = [DAOAddressBook fetchAllContacts];
        [DAOAddressBook saveContacts:phoneContacts];
    }
    else {
        [self requestAccessWithCompletion:^(BOOL granted, NSError *requestError) {
            if (granted) {
                [self syncAddressBook];
            }
        }];
    }
}

- (void)requestAccessWithCompletion:(void (^)(BOOL granted, NSError *requestError))completion {
    
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    if (status == kABAuthorizationStatusAuthorized) {
        completion(YES, nil);
    }
    else if (status == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            if (error) {
                NSError *err = (__bridge NSError *)error;
                NSLog(@"Error requesting Address Book access: %@", err.localizedFailureReason);
                completion(granted, nil);
            }
            else {
                completion(granted, nil);
            }
        });
    } else {
        completion(NO, [NSError errorWithDomain:@"" code:1 userInfo:nil]);
    }
}

+ (void)setShouldSyncAddressBookChanges:(BOOL)sync {
    
    shouldSyncAddressBookChanges = sync;
}


#pragma mark - Private Methods
+ (BOOL)authorized {
    
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    return (status == kABAuthorizationStatusAuthorized);
}

- (void)registerForAddressBookChanges {
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    ABAddressBookRegisterExternalChangeCallback(addressBook, addressBookChanged, NULL);
}

+ (NSArray *)fetchAllContacts {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    RLMResults *profiles = [RMModelProfile allObjectsInRealm:realm];
    RMModelProfile *profile = [profiles firstObject];
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    NSArray *thePeople = (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
    NSMutableSet *contacts = [NSMutableSet set];
    for (id person in thePeople) {
        // getting contact first & last names
        ABRecordRef personRef = (__bridge ABRecordRef)person;
        ABRecordID recordId = ABRecordGetRecordID(personRef);
        CFStringRef _firstName = ABRecordCopyValue(personRef, kABPersonFirstNameProperty);
        CFStringRef _lastName  = ABRecordCopyValue(personRef, kABPersonLastNameProperty);
        
        NSString *firstName = [NSString stringWithFormat:@"%@",_firstName];
        if (!firstName || [firstName isKindOfClass:[NSNull class]] || [firstName isEqualToString:@"(null)"]) {
            firstName = @"";
        }
        NSString *lastName = [NSString stringWithFormat:@"%@",_lastName];
        if (!lastName || [lastName isKindOfClass:[NSNull class]] || [lastName isEqualToString:@"(null)"]) {
            lastName = @"";
        }
        NSString *fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
        
        // getting contact's all emails
        CFTypeRef phones = ABRecordCopyValue((__bridge ABRecordRef)person, kABPersonEmailProperty);
        for (CFIndex i = 0; i < ABMultiValueGetCount(phones); i++) {
            NSString *email = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phones, i);
            if (email && ![email isEqualToString:profile.email]) {
                NSString *uniqueId = [NSString stringWithFormat:@"%d_%ld", recordId, i];
                ContactModel *contact = [[ContactModel alloc] initWithEmail:email fullName:fullName firstName:firstName lastName:lastName contactId:uniqueId  urlPhoto:nil profile:@"" addressBook:YES];
                if (contact) {
                    [contacts addObject:contact];
                }
            }
        }
        CFRelease(phones);
    }
    CFRelease(addressBook);
    
    return [contacts allObjects];
}

+ (void)saveContacts:(NSArray *)contacts {
    
    if ([contacts count] > 0) {
        RLMRealm *realm = [RLMRealm defaultRealm];
        NSPredicate *predicate =  [NSPredicate predicateWithFormat:@"addressBook == YES"];
        RLMResults *result = [RMModelContact objectsWithPredicate:predicate];
        [realm beginWriteTransaction];
        
        if ([result count] > 0) {
            [realm deleteObjects:result];
        }
        
        for (ContactModel *contactModel in contacts) {
            if (contactModel.email) {
                RMModelContact *realmModel = [[RMModelContact alloc] initWithContactModel:contactModel];
                [RMModelContact createOrUpdateInRealm:realm withValue:realmModel];
            }
        }
        [realm commitWriteTransaction];
    }
}

void addressBookChanged(ABAddressBookRef reference, CFDictionaryRef dictionary, void *context) {
    
    if (shouldSyncAddressBookChanges) {
        shouldSyncAddressBookChanges = NO;
        if ([DAOAddressBook authorized]) {
            NSArray *contacts = [DAOAddressBook fetchAllContacts];
            [DAOAddressBook saveContacts:contacts];
        }
    }
}

@end
