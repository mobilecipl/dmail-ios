//
//  CoreDataManager.m
//  Dmail
//
//  Created by Karen Petrosyan on 6/19/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "CoreDataManager.h"
#import "UserService.h"
#import "Message.h"
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
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"DMail" withExtension:@"momd"];
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
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"DMail.sqlite"];
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
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:EntityUser inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entityDescription];
    User *user = [NSEntityDescription insertNewObjectForEntityForName:EntityUser inManagedObjectContext:self.managedObjectContext];
    user.fullName = userService.name;
    user.email = userService.email;
    user.gmailId = userService.gmailId;
    
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
    
    [self clearEntityWithName:EntityUser];
    [self clearEntityWithName:EntityDmailMessage];
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


#pragma mark - Messages
- (NSArray *)getMessagesWithType:(MessageType)messageType {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:EntityDmailMessage inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type == %d",messageType];
    [fetchRequest setPredicate:predicate];
    
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

- (DmailMessage *)getDmailMessageWithMessageId:(NSString *)messageId {
    
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
    }
    
    return dmailMessage;
}

- (NSArray *)writeDmailMessageParametersWith:(NSArray *)arrayParameters {
    
    NSMutableArray *arrayMessagesIdentifiers = [[NSMutableArray alloc] init];
    for (DmailEntityItem *dmailEntityItem in arrayParameters) {
        NSString *identifier = dmailEntityItem.identifier;
        BOOL messageExist = YES;
        DmailMessage *dmailMessage;
        if (identifier) {
            dmailMessage = [self getMessageWithMessageIdentifier:identifier];
        }
        if (!dmailMessage && dmailEntityItem.dmailId) {
            dmailMessage = [self getDmailMessageWithMessageId:dmailEntityItem.dmailId];
        }
        if (!dmailMessage) {
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *entityDescription = [NSEntityDescription entityForName:EntityDmailMessage inManagedObjectContext:self.managedObjectContext];
            [fetchRequest setEntity:entityDescription];
            dmailMessage = [NSEntityDescription insertNewObjectForEntityForName:EntityDmailMessage inManagedObjectContext:self.managedObjectContext];
            messageExist = NO;
        }
        if (dmailEntityItem.dmailId) {
            dmailMessage.dmailId = dmailEntityItem.dmailId;
        }
        if (dmailEntityItem.identifier) {
            dmailMessage.identifier = dmailEntityItem.identifier;
        }
        if (dmailEntityItem.subject) {
            dmailMessage.subject = dmailEntityItem.subject;
        }
        if (dmailEntityItem.senderName) {
            dmailMessage.senderName = dmailEntityItem.senderName;
        }
        if (dmailEntityItem.access) {
            dmailMessage.access = dmailEntityItem.access;
        }
        if (dmailEntityItem.senderEmail) {
            dmailMessage.senderEmail = dmailEntityItem.senderEmail;
        }
        if (dmailEntityItem.body) {
            dmailMessage.body = dmailEntityItem.body;
        }
        if (dmailEntityItem.receiverEmail) {
            dmailMessage.receiverEmail = dmailEntityItem.receiverEmail;
        }
        if (dmailEntityItem.type != -1) {
            dmailMessage.type = dmailEntityItem.type;
        }
        if (dmailEntityItem.position != -1) {
            dmailMessage.position = dmailEntityItem.position;
        }
        if (dmailEntityItem.status != -1) {
            dmailMessage.status = dmailEntityItem.status;
        }
        if (!messageExist && dmailEntityItem.identifier) {
            [arrayMessagesIdentifiers addObject:dmailEntityItem.identifier];
        }
        
        if (dmailEntityItem.senderEmail) {
            ProfileItem *profileItem = [[ProfileItem alloc] initWithEmail:dmailEntityItem.senderEmail name:dmailEntityItem.senderName];
            [self writeOrUpdateParticipantWith:profileItem];
        }
    }
    
    [self saveContext];
    
    return [NSArray arrayWithArray:arrayMessagesIdentifiers];
}

- (void)writeSendMessageWithParameters:(NSDictionary *)parameters {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:EntityDmailMessage inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entityDescription];
    DmailMessage *dmailMessage = [NSEntityDescription insertNewObjectForEntityForName:EntityDmailMessage inManagedObjectContext:self.managedObjectContext];
    if ([[parameters allKeys] containsObject:Access]) {
        dmailMessage.access = parameters[Access];
    }
    if ([[parameters allKeys] containsObject:MessageId]) {
        dmailMessage.dmailId = parameters[MessageId];
    }
    if ([[parameters allKeys] containsObject:Access]) {
        dmailMessage.access = parameters[Access];
    }
    if ([[parameters allKeys] containsObject:Position]) {
        dmailMessage.position = [parameters[Position] floatValue];
    }
    if ([[parameters allKeys] containsObject:Type]) {
        dmailMessage.type = [parameters[Type] integerValue];
    }
    if ([[parameters allKeys] containsObject:Status]) {
        dmailMessage.status = [parameters[Status] integerValue];
    }
    if ([[parameters allKeys] containsObject:SenderName]) {
        dmailMessage.senderName = parameters[SenderName];
    }
    if ([[parameters allKeys] containsObject:Status]) {
        dmailMessage.senderEmail = parameters[SenderEmail];
    }
    if ([[parameters allKeys] containsObject:Subject]) {
        dmailMessage.subject = parameters[Subject];
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
            dmailMessage.status = messageStatus;
        }
    }
    
    [self saveContext];
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

- (void)writeMessageBodyWithDmailId:(NSString *)dmailId messageBody:(NSString *)messageBody {
    
    DmailMessage *dmailMessage = [self getDmailMessageWithMessageId:dmailId];
    dmailMessage.body = messageBody;
    
    [self saveContext];
}

- (Profile *)getProfileWithEmail:(NSString *)email {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:EntityProfile inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"email like %@",email];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedProfiles = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    Profile *profile = nil;
    if ([fetchedProfiles count] > 0) {
        profile = [fetchedProfiles firstObject];
    }
    
    return profile;
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
