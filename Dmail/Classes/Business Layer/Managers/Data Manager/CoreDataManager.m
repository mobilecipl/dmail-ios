//
//  CoreDataManager.m
//  Dmail
//
//  Created by Karen Petrosyan on 6/19/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "CoreDataManager.h"
#import "ProfileService.h"
#import "Constants.h"
#import "DmailEntityItem.h"
#import "ProfileItem.h"

#import "User.h"
#import "DmailMessage.h"
#import "GmailMessage.h"
#import "Profile.h"

@implementation CoreDataManager

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

static NSString * const EntityMessage = @"Message";
static NSString * const EntityDmailMessage = @"DmailMessage";
static NSString * const EntityGmailMessage = @"GmailMessage";
static NSString * const EntityUser = @"User";
static NSString * const EntityProfile = @"Profile";

+ (instancetype)sharedCoreDataManager {
    
    static CoreDataManager *sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[CoreDataManager alloc] init];
    });
    
    return sharedInstance;
}

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.science.Dmail" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Dmail" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Dmail.sqlite"];
    NSError *error = nil;
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption : @YES, NSInferMappingModelAutomaticallyOption : @YES };
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        // Report any error we got.
        NSString *failureReason = @"There was an error creating or loading the application's saved data.";
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}


#pragma mark - Public Methods
#pragma mark - User
- (void)writeUserDataWith:(UserService *)userService {
    
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:EntityUser inManagedObjectContext:self.managedObjectContext];
//    [fetchRequest setEntity:entityDescription];
//    User *user = [NSEntityDescription insertNewObjectForEntityForName:EntityUser inManagedObjectContext:self.managedObjectContext];
//    user.fullName = userService.name;
//    user.email = userService.email;
//    user.gmailId = userService.gmailId;
    
    [self saveContext];
}

- (User *)getUserData {
    
    User *user;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:EntityUser inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entityDescription];
    
    NSError *error = nil;
    NSArray *fetchedUser = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    user = [fetchedUser firstObject];
    
    return user;
}

- (void)signOut {
    
    [self clearEntityWithName:EntityDmailMessage];
    [self clearEntityWithName:EntityGmailMessage];
    [self clearEntityWithName:EntityProfile];
    [self clearEntityWithName:EntityUser];
}

- (void)clearEntityWithName:(NSString *)entityName {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:[NSString stringWithFormat:@"%@", entityName] inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entityDescription];
    
    NSError *error = nil;
    NSArray *fetchedMessages = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    for (NSManagedObject *message in fetchedMessages) {
        [self.managedObjectContext deleteObject:message];
    }
    [self saveContext];
}


#pragma mark - Profile
- (Profile *)getProfileWithEmail:(NSString *)email {
    
    Profile *profile = nil;
    if (email) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:EntityProfile inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entityDescription];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"email like %@",email];
        [fetchRequest setPredicate:predicate];
        
        NSError *error = nil;
        NSArray *fetchedProfiles = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if ([fetchedProfiles count] > 0) {
            profile = [fetchedProfiles firstObject];
        }
    }
    
    return profile;
}

- (void)writeOrUpdateParticipantWith:(ProfileItem *)profileItem {
    
    Profile *profile = [self getProfileWithEmail:profileItem.email];
    if (!profile) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:EntityProfile inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entityDescription];
        profile = [NSEntityDescription insertNewObjectForEntityForName:EntityProfile inManagedObjectContext:self.managedObjectContext];
    }
    profile.email = profileItem.email;
    profile.name = profileItem.name;
    
    [self saveContext];
}



#pragma mark - Messages
- (NSArray *)getGmailMessagesWithType:(MessageLabel)messageType {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:EntityGmailMessage inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"label == %d",messageType];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *descendingSort = [[NSSortDescriptor alloc] initWithKey:InternalDate ascending:NO selector:nil];
    [fetchRequest setSortDescriptors:@[descendingSort]];
    
    NSError *error = nil;
    NSArray *fetchedMessages = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    return fetchedMessages;
}

- (DmailMessage *)getMessageWithMessageIdentifier:(NSString *)identifier {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:EntityDmailMessage inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier like %@",identifier];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedMessages = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    return [fetchedMessages lastObject];
}

- (DmailMessage *)getDmailMessageWithMessageId:(NSString *)dmailId {
    
    DmailMessage *dmailMessage = nil;
    if (dmailId) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:EntityDmailMessage inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entityDescription];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dmailId like %@",dmailId];
        [fetchRequest setPredicate:predicate];
        
        NSError *error = nil;
        NSArray *fetchedMessages = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if ([fetchedMessages count] > 0) {
            dmailMessage = [fetchedMessages firstObject];
        }
    }
    
    return dmailMessage;
}

- (GmailMessage *)getGmailMessageWithMessageId:(NSString *)dmailId {
    
    GmailMessage *gmailMessage = nil;
    if (dmailId) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:EntityGmailMessage inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entityDescription];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dmailId like %@",dmailId];
        [fetchRequest setPredicate:predicate];
        
        NSError *error = nil;
        NSArray *fetchedMessages = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if ([fetchedMessages count] > 0) {
            gmailMessage = [fetchedMessages firstObject];
        }
    }
    
    return gmailMessage;
}

- (DmailMessage *)getLastValidMessage {
    
    DmailMessage *dmailMessage = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:EntityDmailMessage inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"access like %@ AND status == %d",AccessTypeGaranted, MessageFetchedOnlyIds];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *descendingSort = [[NSSortDescriptor alloc] initWithKey:Position ascending:NO selector:nil];
    [fetchRequest setSortDescriptors:@[descendingSort]];
    
    NSError *error = nil;
    NSArray *fetchedMessages = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if ([fetchedMessages count] > 0) {
        dmailMessage = [fetchedMessages firstObject];
    }
    
    return dmailMessage;
}

- (DmailMessage *)getLastRevokedMessage {
    
    DmailMessage *dmailMessage = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:EntityDmailMessage inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"access like %@",AccessTypeRevoked];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *descendingSort = [[NSSortDescriptor alloc] initWithKey:Position ascending:NO selector:nil];
    [fetchRequest setSortDescriptors:@[descendingSort]];
    
    NSError *error = nil;
    NSArray *fetchedMessages = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if ([fetchedMessages count] > 0) {
        dmailMessage = [fetchedMessages firstObject];
    }
    
    return dmailMessage;
}

- (void)writeMessageToDmailEntityWithparameters:(DmailEntityItem *)item {
    
    DmailMessage *dmailMessage;
    if (item.dmailId) {
        dmailMessage = [self getDmailMessageWithMessageId:item.dmailId];
    }
    if (!dmailMessage) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:EntityDmailMessage inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entityDescription];
        dmailMessage = [NSEntityDescription insertNewObjectForEntityForName:EntityDmailMessage inManagedObjectContext:self.managedObjectContext];
    }
    if (item.dmailId) {
        dmailMessage.dmailId = item.dmailId;
    }
    if (item.identifier) {
        dmailMessage.identifier = item.identifier;
    }
    if (item.access) {
        dmailMessage.access = item.access;
    }
    if (item.body) {
        dmailMessage.body = item.body;
    }
    if (item.label && item.label!= 0) {
        dmailMessage.label = [NSNumber numberWithInteger:item.label];
    }
    if (item.position && item.position!= -1) {
        dmailMessage.position = [NSNumber numberWithDouble:item.position];
    }
    if (item.status && item.status!= 0) {
        dmailMessage.status = [NSNumber numberWithInteger:item.status];
    }
    
    [self saveContext];
}

- (void)writeMessageToGmailEntityWithparameters:(DmailEntityItem *)item {
    
    GmailMessage *gmailMessage;
    if (item.dmailId) {
        gmailMessage = [self getGmailMessageWithMessageId:item.dmailId];
    }
    if (!gmailMessage) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:EntityGmailMessage inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entityDescription];
        gmailMessage = [NSEntityDescription insertNewObjectForEntityForName:EntityGmailMessage inManagedObjectContext:self.managedObjectContext];
    }
    if (item.dmailId) {
        gmailMessage.dmailId = item.dmailId;
    }
    if (item.gmailId) {
        gmailMessage.gmailId = item.gmailId;
    }
    if (item.identifier) {
        gmailMessage.identifier = item.identifier;
    }
    if (item.subject) {
        gmailMessage.subject = item.subject;
    }
    if (item.fromEmail) {
        gmailMessage.from = item.fromEmail;
    }
    if (item.internalDate && item.internalDate!= -1) {
        gmailMessage.internalDate = [NSNumber numberWithDouble:item.internalDate];
    }
    if (item.label && item.label!= 0) {
        gmailMessage.label = [NSNumber numberWithInteger:item.label];
    }
    if (item.type && item.type!= 0) {
        gmailMessage.type = [NSNumber numberWithInteger:item.type];
    }
    if (item.publicKey) {
        gmailMessage.publicKey = item.publicKey;
    }
    if ([item.arrayTo count] > 0) {
        NSString *to = [item.arrayTo componentsJoinedByString:@","];
        gmailMessage.to = to;
    }
    if ([item.arrayCc count] > 0) {
        NSString *cc = [item.arrayCc componentsJoinedByString:@","];
        gmailMessage.cc = cc;
    }
    if ([item.arrayBcc count] > 0) {
        NSString *bcc = [item.arrayBcc componentsJoinedByString:@","];
        gmailMessage.bcc = bcc;
    }
    
    [self saveContext];
}

- (void)changeMessageStatusWithMessageId:(NSString *)messageId messageStatus:(MessageStatus)messageStatus {
    
    if (messageId) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:EntityDmailMessage inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entityDescription];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dmailId like %@",messageId];
        [fetchRequest setPredicate:predicate];
        
        NSError *error = nil;
        NSArray *fetchedMessages = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        DmailMessage *dmailMessage = nil;
        if ([fetchedMessages count] > 0) {
            dmailMessage = [fetchedMessages firstObject];
            dmailMessage.status = [NSNumber numberWithInteger:messageStatus];
        }
    }
    
    [self saveContext];
}

- (void)changeMessageTypeWithMessageId:(NSString *)messageId messageType:(MessageType)messageType {
    
    if (messageId) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:EntityGmailMessage inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entityDescription];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dmailId like %@",messageId];
        [fetchRequest setPredicate:predicate];
        
        NSError *error = nil;
        NSArray *fetchedMessages = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        GmailMessage *gmailMessage = nil;
        if ([fetchedMessages count] > 0) {
            gmailMessage = [fetchedMessages firstObject];
            gmailMessage.type = [NSNumber numberWithInteger:messageType];
        }
    }
    
    [self saveContext];
}

- (void)writeMessageBodyWithDmailId:(NSString *)dmailId messageBody:(NSString *)messageBody {
    
    DmailMessage *dmailMessage = [self getDmailMessageWithMessageId:dmailId];
    dmailMessage.body = messageBody;
    
    [self saveContext];
}

- (CGFloat)getLastPosition {
    
    CGFloat lastPosition = 0;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:EntityDmailMessage inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entityDescription];
    
    NSSortDescriptor *descendingSort = [[NSSortDescriptor alloc] initWithKey:Position ascending:NO selector:nil];
    [fetchRequest setSortDescriptors:@[descendingSort]];
    
    NSError *error = nil;
    NSArray *fetchedMessages = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if ([fetchedMessages count] > 0) {
        DmailMessage *message = [fetchedMessages firstObject];
        lastPosition = [message.position doubleValue];
    }
    
    return lastPosition;
}

- (NSString *)getPublicKeyWithDmailId:(NSString *)dmailId {
    
    NSString *publicKey = nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:EntityGmailMessage inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dmailId like %@",dmailId];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedMessages = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if ([fetchedMessages count] > 0) {
        GmailMessage *message = [fetchedMessages firstObject];
        publicKey = message.publicKey;
    }
    
    return publicKey;
}

- (void)removeDmailMessageWithDmailId:(NSString *)dmailId {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:EntityDmailMessage inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dmailId like %@",dmailId];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedContacts = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    for (DmailMessage *dmailMessage in fetchedContacts) {
        [self.managedObjectContext deleteObject:dmailMessage];
    }
    
    [self saveContext];
}

- (void)removeGmailMessageWithDmailId:(NSString *)dmailId {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:EntityGmailMessage inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dmailId like %@",dmailId];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedContacts = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    for (GmailMessage *gmailMessage in fetchedContacts) {
        [self.managedObjectContext deleteObject:gmailMessage];
    }
    
    [self saveContext];
}


#pragma mark - Core Data Saving support
- (void)saveContext {
    
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
