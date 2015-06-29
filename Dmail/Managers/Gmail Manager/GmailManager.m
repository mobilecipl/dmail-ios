;//
//  GmailManager.m
//  Dmail
//
//  Created by Karen Petrosyan on 6/25/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "GmailManager.h"
#import "Constants.h"
#import "CoreDataManager.h"
#import "DmailMessage.h"
#import "MessageService.h"
#import "DmailEntityItem.h"
#import "ProfileItem.h"
#import "CommonMethods.h"

@interface GmailManager ()

@property (nonatomic, assign) BOOL getInProcess;
@property (nonatomic, strong) DmailMessage *dmailmessage;

@end

@implementation GmailManager

#pragma mark - Class Methods
+ (GmailManager *)sharedInstance {
    static GmailManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[GmailManager alloc] init];
        sharedInstance.getInProcess = NO;
    });
    
    return sharedInstance;
}

#pragma mark - Private Methods
- (DmailEntityItem *)parseGmailMessageContent:(NSDictionary *)requestReply {
    
    DmailEntityItem *dmailEntityItem = [[DmailEntityItem alloc] initWithClearObjects];
//    dmailEntityItem.gmailId = requestReply[@"id"];
    if ([[requestReply allKeys] containsObject:Payload]) {
        dmailEntityItem.internalDate = [requestReply[InternalDate] integerValue];
        NSDictionary *payload = requestReply[Payload];
        if ([[payload allKeys] containsObject:Headers]) {
            NSArray *headers = payload[Headers];
            for (NSDictionary *dict in headers) {
                if ([dict[Name] isEqualToString:From]) {
                    NSLog(@"From ==== %@",dict[Value]);
                    dmailEntityItem.fromEmail = [self getEmailFromValue:dict[Value]];
                    dmailEntityItem.fromName = [self getNameFromvalue:dict[Value]];
                    ProfileItem *profileItem = [[ProfileItem alloc] initWithEmail:dmailEntityItem.fromEmail name:dmailEntityItem.fromName];
                    [[CoreDataManager sharedCoreDataManager] writeOrUpdateParticipantWith:profileItem];
                }
                if ([dict[Name] isEqualToString:To]) {
                    NSLog(@"To ==== %@",dict[Value]);
                    NSArray *array = [dict[Value] componentsSeparatedByString:@","];
                    for (NSString *string in array) {
                        NSString *toEmail = [self getEmailFromValue:string];
                        if (toEmail) {
                            [dmailEntityItem.arrayTo addObject:toEmail];
                        }
                        NSString *toName = [self getNameFromvalue:string];
                        ProfileItem *profileItem = [[ProfileItem alloc] initWithEmail:toEmail name:toName];
                        [[CoreDataManager sharedCoreDataManager] writeOrUpdateParticipantWith:profileItem];
                    }
                }
//                if ([dict[Name] isEqualToString:Cc]) {
//                    NSArray *arrayCc = [dict[Value] componentsSeparatedByString:@","];
//                    dmailEntityItem.fromEmail = [self getEmailFromValue:dict[Value]];
//                    dmailEntityItem.fromName = [self getNameFromvalue:dict[Value]];
//                }
//                if ([dict[Name] isEqualToString:Bcc]) {
//                    NSArray *arrayCc = [dict[Value] componentsSeparatedByString:@","];
//                    dmailEntityItem.fromEmail = [self getEmailFromValue:dict[Value]];
//                    dmailEntityItem.fromName = [self getNameFromvalue:dict[Value]];
//                }
                if ([dict[Name] isEqualToString:Subject]) {
                    dmailEntityItem.subject = dict[Value];
                }
                if ([dict[Name] isEqualToString:Message_Id]) {
                    dmailEntityItem.identifier = dict[Value];
                }
                if ([dict[Name] isEqualToString:PublicKey]) {
                    dmailEntityItem.publicKey = dict[Value];
                }
                dmailEntityItem.status = MessageFetchedFull;
            }
        }
    }
    
    return dmailEntityItem;
}

- (NSString *)getEmailFromValue:(NSString *)value {
    
    NSString *email;
    NSArray *arraySubStrings = [value componentsSeparatedByString:@"<"];
    if ([arraySubStrings count] > 1) {
        NSLog(@"arraySubStrings ==== %@", arraySubStrings);
        email = [[arraySubStrings objectAtIndex:1] substringToIndex:[[arraySubStrings objectAtIndex:1] length]-1];
    }
    else {
        email = value;
    }
    
    return email;
}

- (NSString *)getNameFromvalue:(NSString *)value {
    
    NSString *name;
    
    NSArray *arraySubStrings = [value componentsSeparatedByString:@"<"];
    if ([arraySubStrings count] > 1) {
        NSLog(@"arraySubStrings ==== %@", arraySubStrings);
        name = [arraySubStrings firstObject];
        name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    
    return name;
}

#pragma mark - Public Methods
- (void)getMessages {
    
    [self getGrantedMessagesFromGmail];
    [self getRevokedMessages];
}

- (void)getGrantedMessagesFromGmail {
    
    self.dmailmessage = [[CoreDataManager sharedCoreDataManager] getLastValidMessage];
    if (self.dmailmessage.identifier && !self.getInProcess) {
        if ([self.dmailmessage.access isEqualToString:AccessTypeGaranted]) {
            self.getInProcess = YES;
            [[MessageService sharedInstance] getGmailMessageIdFromGmailWithIdentifier:self.dmailmessage.identifier withCompletionBlock:^(NSString *gmailMessageId, NSInteger statusCode) {
                if (gmailMessageId) {
                    [[MessageService sharedInstance] getMessageFromGmailWithMessageId:gmailMessageId withCompletionBlock:^(NSDictionary *requestData, NSInteger statusCode) {
                        if (statusCode == 200) {
                            self.getInProcess = NO;
                            DmailEntityItem *item = [[CommonMethods sharedInstance] parseGmailMessageContent:requestData];
                            item.dmailId = self.dmailmessage.dmailId;
                            item.label = [self.dmailmessage.label integerValue];
                            item.type = Unread;
                            item.gmailId = gmailMessageId;
                            [[CoreDataManager sharedCoreDataManager] writeMessageToGmailEntityWithparameters:item];
                            [[CoreDataManager sharedCoreDataManager] changeMessageStatusWithMessageId:self.dmailmessage.dmailId messageStatus:MessageFetchedFull];
                            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationNewMessageFetched object:nil];
                            [self performSelector:@selector(getGrantedMessagesFromGmail) withObject:nil afterDelay:1.0];
                        }
                        else {
                            self.getInProcess = NO;
                            DmailEntityItem *item = [[DmailEntityItem alloc] initWithClearObjects];
                            item.dmailId = self.dmailmessage.dmailId;
                            [[CoreDataManager sharedCoreDataManager] writeMessageToGmailEntityWithparameters:item];
                            [self performSelector:@selector(getGrantedMessagesFromGmail) withObject:nil afterDelay:1.0];
                        }
                    }];
                }
                else {
                    self.getInProcess = NO;
                    DmailEntityItem *item = [[DmailEntityItem alloc] initWithClearObjects];
                    item.status = MessageRemovedFromGmail;
                    item.dmailId = self.dmailmessage.dmailId;
                    [[CoreDataManager sharedCoreDataManager] writeMessageToGmailEntityWithparameters:item];
                    [self performSelector:@selector(getGrantedMessagesFromGmail) withObject:nil afterDelay:1.0];
                }
            }];
        }
        else {
            [[CoreDataManager sharedCoreDataManager] removeGmailMessageWithDmailId:self.dmailmessage.dmailId];
            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationNewMessageFetched object:nil];
        }
    }
    else {
        [self performSelector:@selector(getGrantedMessagesFromGmail) withObject:nil afterDelay:1.0];
    }
}

- (void)getRevokedMessages {
    
    DmailMessage *revokedMessage = [[CoreDataManager sharedCoreDataManager] getLastRevokedMessage];
    if (revokedMessage.identifier && !self.getInProcess) {
        if ([revokedMessage.access isEqualToString:AccessTypeRevoked]) {
            [[CoreDataManager sharedCoreDataManager] removeGmailMessageWithDmailId:revokedMessage.dmailId];
            [[CoreDataManager sharedCoreDataManager] removeDmailMessageWithDmailId:revokedMessage.dmailId];
            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationNewMessageFetched object:nil];
            [self performSelector:@selector(getRevokedMessages) withObject:nil afterDelay:1.0];
        }
        else {
            [self performSelector:@selector(getRevokedMessages) withObject:nil afterDelay:1.0];
        }
    }
    else {
        [self performSelector:@selector(getRevokedMessages) withObject:nil afterDelay:1.0];
    }
}

@end
