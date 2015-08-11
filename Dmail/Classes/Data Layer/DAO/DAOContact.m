//
//  DAOContact.m
//  Dmail
//
//  Created by Karen Petrosyan on 7/3/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "DAOContact.h"

// network
#import "NetworkContacts.h"

// model
#import "ContactModel.h"

// realm
#import <Realm/Realm.h>
#import "RMModelContact.h"
#import "RMModelProfile.h"

// google
#import <GoogleSignIn/GoogleSignIn.h>

// util
#import <NSDate+DateTools.h>

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
- (NSMutableArray *)getContactsWithName:(NSString *)name {
    
    NSMutableArray *arrayContacts = [[NSMutableArray alloc] init];
    if(name.length > 0) {
        NSPredicate *predicate =  [NSPredicate predicateWithFormat:@"firstName BEGINSWITH[c] %@ OR lastName BEGINSWITH[c] %@ OR email BEGINSWITH[c] %@", name, name, name];
        RLMResults *result = [RMModelContact objectsWithPredicate:predicate];
        for (RMModelContact *rmModel in result) {
            ContactModel *model = [[ContactModel alloc] initWithRMModel:rmModel];
            [arrayContacts addObject:model];
        }
    }
    
    return arrayContacts;
}

- (NSString *)contactNameWithEmail:(NSString *)email {
    
    NSString *name;
    NSPredicate *predicate =  [NSPredicate predicateWithFormat:@"email == %@", email];
    RLMResults *result = [RMModelContact objectsWithPredicate:predicate];
    if ([result count] > 0) {
        RMModelContact *rmModel = [result firstObject];
        name = rmModel.fullName;
    }
    
    return name;
}


#pragma mark - Private Methods
- (void)getContactsForEmail:(NSString *)email
                 startIndex:(NSString *)startIndex
                  maxResult:(NSString *)maxResult
            completionBlock:(CompletionBlock)completionBlock {
    
    NSString *updatedMinTime = [self getLastUpdateTime];
    
    [self.networkContacts getContactsForEmail:email
                                   startIndex:startIndex
                                    maxResult:maxResult
                                   updatedMin:updatedMinTime
                              completionBlock:^(NSDictionary *data, ErrorDataModel *error) {
                                  
                                  if (!error) {
                                      NSArray *contacts = [self parseContactsWithDictionary:data];
                                      [self saveContacts:contacts];
                                      
                                      
                                      if (contacts == nil || contacts.count < maxResult.intValue) {
                                          //finishLoading
                                          [self saveLastUpdateTimeWithDictionaryIfNeeded:data];
                                          
                                      }
                                      completionBlock(contacts, nil);
                                  } else {
                                      completionBlock(nil, error);
                                  }
                              }];
    
}

- (NSArray *)parseContactsWithDictionary:(NSDictionary *)data {
    
    //TODO: parse as JSONMODEL
    NSMutableArray *arrayModels = [[NSMutableArray alloc] init];
    NSDictionary *dictFeed = data[@"feed"];
    NSArray *entryFeed = dictFeed[@"entry"];
    for (NSDictionary *dict in entryFeed) {
        
        NSString *email;
        NSString *firstName;
        NSString *lastName;
        NSString *fullName;
        NSString *contactId;
        NSString *urlPhoto;
//        NSDate *updated;
        
        if ([[dict allKeys] containsObject:@"gd$email"]) {
            NSArray *emailArray = dict[@"gd$email"];
            for (NSDictionary *emailDict in emailArray) {
                if ([[emailDict allKeys] containsObject:@"address"]) {
                    email = emailDict[@"address"];
                }
            }
        }
        if ([[dict allKeys] containsObject:@"gd$name"]) {
            NSDictionary *nameDict = dict[@"gd$name"];
            NSDictionary *fullNameDict = nameDict[@"gd$fullName"];
            fullName = fullNameDict[@"$t"];
            
            NSDictionary *lastNameDict = nameDict[@"gd$familyName"];
            lastName = lastNameDict[@"$t"];
            
            NSDictionary *firstNameDict = nameDict[@"gd$givenName"];
            firstName = firstNameDict[@"$t"];
        }
        if ([[dict allKeys] containsObject:@"id"]) {
            NSDictionary *idDict = dict[@"id"];
            contactId = idDict[@"$t"];
            NSArray *array = [contactId componentsSeparatedByString:@"/"];
            contactId = [array lastObject];
        }
        
        if ([[dict allKeys] containsObject:@"link"]) {
            NSArray *hrefArray = dict[@"link"];
            for (NSDictionary *hrefDict in hrefArray) {
                if ([[hrefDict allKeys] containsObject:@"href"]) {
                    urlPhoto = hrefDict[@"href"];
                    break;
                }
            }
        }
        
//        if ([[dict allKeys] containsObject:@"updated"]) {
//            NSDictionary *updatedDict = dict[@"updated"];
//            
//            updated = [NSDate dateWithString:updatedDict[@"$t"] formatString:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"];
//        }
        
        ContactModel *model = [[ContactModel alloc] initWithEmail:email
                                                         fullName:fullName
                                                        firstName:firstName
                                                         lastName:lastName
                                                        contactId:contactId
                                                         urlPhoto:urlPhoto];
        if (model) {
            [arrayModels addObject:model];
        }
    }
    
    return [NSArray arrayWithArray:arrayModels];
}

- (void)saveContacts:(NSArray *)contacts {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    for (ContactModel *contactModel in contacts) {
        RMModelContact *realmModel = [[RMModelContact alloc] initWithContactModel:contactModel];
        [realm beginWriteTransaction];
        [RMModelContact createOrUpdateInRealm:realm withValue:realmModel];
        [realm commitWriteTransaction];
    }
}

- (NSString *)getLastUpdateTime {

    RLMRealm *realm = [RLMRealm defaultRealm];
    RLMResults *profiles = [RMModelProfile allObjectsInRealm:realm];
    RMModelProfile *profile = [profiles firstObject];

    if ( !([profile.contactLastUpdateDate isEqualToString:@""] || profile.contactLastUpdateDate == nil) ) {
        
        return profile.contactLastUpdateDate;
    }

    return @"2007-03-16T00:00:00";
}

- (void)saveLastUpdateTimeWithDictionaryIfNeeded:(NSDictionary *)data {
    
    NSDictionary *dictFeed = data[@"feed"];
    NSDictionary *updatedDict = dictFeed[@"updated"];
    NSString *updatedTime = updatedDict[@"$t"];
    
    NSString *updatedTimeRM = [self getLastUpdateTime];
    
    NSComparisonResult result = [updatedTime compare:updatedTimeRM];
    
    if (result == NSOrderedDescending) { // stringOne > stringTwo
        
        [self updateProfileWithLastUpdateTime:updatedTime];
    }
}

- (void)updateProfileWithLastUpdateTime:(NSString *)time {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    RLMResults *profiles = [RMModelProfile allObjectsInRealm:realm];
    RMModelProfile *profile = [profiles firstObject];
    
    [realm beginWriteTransaction];
    
    profile.contactLastUpdateDate = time;
//    [RMModelProfile createOrUpdateInRealm:realm withValue:profile];
    
    [realm commitWriteTransaction];
}

- (void)cancelAllRequests {
    
    [self.networkContacts cancellAllRequests];
}

@end
