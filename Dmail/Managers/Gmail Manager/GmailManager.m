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
                    NSArray *arraySubStrings = [dict[Value] componentsSeparatedByString:@"<"];
                    NSString *name = [arraySubStrings firstObject];
                    dmailEntityItem.senderName = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    NSString *email = [[arraySubStrings objectAtIndex:1] substringToIndex:[[arraySubStrings objectAtIndex:1] length]-1];
                    dmailEntityItem.senderEmail = email;
                }
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
                            DmailEntityItem *item = [self parseGmailMessageContent:requestData];
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
