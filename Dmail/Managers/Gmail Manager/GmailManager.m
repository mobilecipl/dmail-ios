//
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
                dmailEntityItem.status = MessageFetchedFull;
            }
        }
    }
    
    return dmailEntityItem;
}

- (void)writeMessageToGmailEntityWith:(DmailEntityItem *)item {
    
    [[CoreDataManager sharedCoreDataManager] writeMessageToGmailEntityWithparameters:item];
}

#pragma mark - Public Methods
- (void)getMessagesFromGmail {
    
    self.dmailmessage = [[CoreDataManager sharedCoreDataManager] getLastValidMessage];
    if (self.dmailmessage.identifier && !self.getInProcess) {
        self.getInProcess = YES;
        [[MessageService sharedInstance] getGmailMessageIdFromGmailWithIdentifier:self.dmailmessage.identifier withCompletionBlock:^(NSString *gmailMessageId, NSInteger statusCode) {
            if (gmailMessageId) {
                [[MessageService sharedInstance] getMessageFromGmailWithMessageId:gmailMessageId withCompletionBlock:^(NSDictionary *requestData, NSInteger statusCode) {
                    if (statusCode == 200) {
                        self.getInProcess = NO;
                        DmailEntityItem *item = [self parseGmailMessageContent:requestData];
                        item.dmailId = self.dmailmessage.dmailId;
                        item.status = MessageFetchedFull;
                        item.label = [self.dmailmessage.label integerValue];
                        item.type = Unread;
                        [self writeMessageToGmailEntityWith:item];
                        [[CoreDataManager sharedCoreDataManager] changeMessageStatusWithMessageId:self.dmailmessage.dmailId messageStatus:MessageFetchedFull];
                        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationNewMessageFetched object:nil];
                        [self performSelector:@selector(getMessagesFromGmail) withObject:nil afterDelay:1.0];
                    }
                    else {
                        self.getInProcess = NO;
                        DmailEntityItem *item = [[DmailEntityItem alloc] initWithClearObjects];
                        item.dmailId = self.dmailmessage.dmailId;
                        item.status = MessageRemovedFromGmail;
                        [self writeMessageToGmailEntityWith:item];
                        [self performSelector:@selector(getMessagesFromGmail) withObject:nil afterDelay:1.0];
                    }
                }];
            }
            else {
                self.getInProcess = NO;
                DmailEntityItem *item = [[DmailEntityItem alloc] initWithClearObjects];
                item.dmailId = self.dmailmessage.dmailId;
                item.status = MessageRemovedFromGmail;
                [self writeMessageToGmailEntityWith:item];
                [self performSelector:@selector(getMessagesFromGmail) withObject:nil afterDelay:1.0];
            }
        }];
    }
    else {
        [self performSelector:@selector(getMessagesFromGmail) withObject:nil afterDelay:1.0];
    }
}

@end
