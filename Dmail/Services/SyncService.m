//
//  SyncService.m
//  Dmail
//
//  Created by Karen Petrosyan on 6/23/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "SyncService.h"
#import "Constants.h"
#import "UserService.h"
#import "MessageService.h"
#import "DmailEntityItem.h"
#import "CoreDataManager.h"

@implementation SyncService


#pragma mark - Private Methods
- (NSMutableArray *)parseDmailMessageToItems:(NSArray *)arrayRecipients {
    
    NSMutableArray *arrayParsedItems = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in arrayRecipients) {
        if ([[dict allKeys] containsObject:MessageIdentifier]) {
            DmailEntityItem *dmailEntityItem = [[DmailEntityItem alloc] initWithClearObjects];
            dmailEntityItem.access = dict[Access];
            dmailEntityItem.dmailId = dict[MessageId];
            dmailEntityItem.identifier = dict[MessageIdentifier];
            dmailEntityItem.position = [dict[Position] floatValue];
            if ([dict[Type] isEqualToString:@"SENDER"]) {
                dmailEntityItem.type = Sent;
            }
            else if([dict[Type] isEqualToString:@"TO"]) {
                dmailEntityItem.type = Inbox;
            }
            dmailEntityItem.status = MessageFetchedPartly;
            [arrayParsedItems addObject:dmailEntityItem];
        }
    }
    
    return arrayParsedItems;
}

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
                dmailEntityItem.status = MessageFetched;
            }
        }
    }
    
    return dmailEntityItem;
}


#pragma mark - Public Methods
- (void)getNewMessages {
    
    if ([[UserService sharedInstance] email]) {
        NSDate *date = [NSDate date];
        NSTimeInterval timeInterval = [date timeIntervalSince1970];
        NSDictionary *parameters = @{Position : [NSString stringWithFormat:@"%ld",(long)timeInterval*1000],
                                     Count : [NSString stringWithFormat:@"%ld",(long)100],
                                     RecipientEmail : [[UserService sharedInstance] email],
                                     Bottom : @YES};
        
        [[MessageService sharedInstance] getMessageListFromDmailWithPosition:parameters withCompletionBlock:^(NSDictionary *requestData, NSInteger statusCode) {
            if (statusCode == 200 || statusCode == 201) {
                NSArray *arrayRecipients = requestData[Recipients];
                if ([arrayRecipients count] > 0) {
                    NSMutableArray *arrayParsedItems = [self parseDmailMessageToItems:arrayRecipients];
                    for (DmailEntityItem *item in arrayParsedItems) {
                        [[MessageService sharedInstance] getGmailMessageIdFromGmailWithIdentifier:item.identifier withCompletionBlock:^(NSString *gmailMessageId, NSInteger statusCode) {
                            if (gmailMessageId) {
                                [[CoreDataManager sharedCoreDataManager] writeMessageWithparameters:item];
                                [[MessageService sharedInstance] getMessageFromGmailWithMessageId:gmailMessageId withCompletionBlock:^(DmailEntityItem *itemFromGmail, NSInteger statusCode) {
                                    if (statusCode == 200) {
                                        itemFromGmail.dmailId = item.dmailId;
                                        [[CoreDataManager sharedCoreDataManager] writeMessageWithparameters:itemFromGmail];
                                        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationNewMessageFetched object:nil];
                                    }
                                    else {
                                        
                                    }
                                }];
                            }
                            else {
                                
                            }
                        }];
                    }
                }
                else {
                    
                }
            }
        }];
    }
}

@end
