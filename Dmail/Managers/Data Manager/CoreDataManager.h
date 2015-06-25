//
//  CoreDataManager.h
//  Dmail
//
//  Created by Karen Petrosyan on 6/19/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Constants.h"
#import <UIKit/UIKit.h>

@class ProfileItem;
@class DmailMessage;
@class GmailMessage;
@class UserService;
@class User;
@class Profile;
@class DmailEntityItem;

@interface CoreDataManager : NSObject

@property (readonly, strong, nonatomic)  NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (instancetype)sharedCoreDataManager;

#pragma mark - User
- (void)writeUserDataWith:(UserService *)userService;
- (User *)getUserData;
- (void)signOut;


#pragma mark - Message
- (NSArray *)getGmailMessagesWithType:(MessageLabel)messageType;
- (DmailMessage *)getMessageWithMessageIdentifier:(NSString *)identifier;
- (DmailMessage *)getDmailMessageWithMessageId:(NSString *)dmailId;
- (GmailMessage *)getGmailMessageWithMessageId:(NSString *)dmailId;
- (DmailMessage *)getLastValidMessage;

- (void)writeMessageToDmailEntityWithparameters:(DmailEntityItem *)item;
- (void)writeMessageToGmailEntityWithparameters:(DmailEntityItem *)item;
- (void)changeMessageStatusWithMessageId:(NSString *)messageId messageStatus:(MessageStatus)messageStatus;
- (void)changeMessageTypeWithMessageId:(NSString *)messageId messageType:(MessageType)messageType;
- (void)writeOrUpdateParticipantWith:(ProfileItem *)profileItem;
- (void)writeMessageBodyWithDmailId:(NSString *)dmailId messageBody:(NSString *)messageBody;
- (Profile *)getProfileWithEmail:(NSString *)email;
- (CGFloat)getLastPosition;
- (void)removeDmailMessageWithDmailId:(NSString *)dmailId;
- (void)removeGmailMessageWithDmailId:(NSString *)dmailId;

@end
