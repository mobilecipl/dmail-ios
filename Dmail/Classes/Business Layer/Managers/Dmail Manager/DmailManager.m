//
//  DmailManager.m
//  Dmail
//
//  Created by Karen Petrosyan on 6/25/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "DmailManager.h"
#import "ServiceProfile.h"
#import "Constants.h"
#import "CoreDataManager.h"
#import "MessageService.h"
#import "DmailEntityItem.h"

@implementation DmailManager

#pragma mark - Class Methods
+ (DmailManager *)sharedInstance {
    static DmailManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DmailManager alloc] init];
    });
    
    return sharedInstance;
}


#pragma mark - Private Methods
- (NSMutableArray *)parseDmailMessageToItems:(NSArray *)arrayRecipients {
    
    NSMutableArray *arrayParsedItems = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in arrayRecipients) {
        if ([[dict allKeys] containsObject:MessageIdentifier]) {
            DmailEntityItem *dmailEntityItem = [[DmailEntityItem alloc] initWithClearObjects];
            dmailEntityItem.access = dict[Access];
            dmailEntityItem.dmailId = dict[MessageId];
            dmailEntityItem.identifier = dict[MessageIdentifier];
            dmailEntityItem.position = [dict[Position] longValue];
            if ([dict[Type] isEqualToString:@"SENDER"]) {
                dmailEntityItem.label = Sent;
            }
            else if([dict[Type] isEqualToString:@"TO"]) {
                dmailEntityItem.label = Inbox;
            }
            dmailEntityItem.status = MessageFetchedOnlyIds;
            [arrayParsedItems addObject:dmailEntityItem];
        }
    }
    
    return arrayParsedItems;
}


#pragma mark - Public Methods
- (void)getDmailIds {
    
    if ([[ServiceProfile sharedInstance] email]) {
        NSInteger position = [[CoreDataManager sharedCoreDataManager] getLastPosition];
        NSDictionary *parameters;
        
        if (position == 0) {
            NSDate *date = [NSDate date];
            NSTimeInterval timeInterval = [date timeIntervalSince1970];
            parameters = @{Position : [NSString stringWithFormat:@"%ld",(long)timeInterval*1000],
                           Count : [NSString stringWithFormat:@"%ld",(long)kMessageGetCount],
                           RecipientEmail : [[ServiceProfile sharedInstance] email],
                           Bottom : @YES};
        }
        else {
            parameters = @{Position : [NSString stringWithFormat:@"%ld",(long)position],
                           Count : [NSString stringWithFormat:@"%ld",(long)kMessageGetCount],
                           RecipientEmail : [[ServiceProfile sharedInstance] email]};
        }
        
        [[MessageService sharedInstance] getMessageListFromDmailWithPosition:parameters withCompletionBlock:^(NSDictionary *requestData, NSInteger statusCode) {
            if (statusCode == 200 || statusCode == 201) {
                NSMutableArray *arrayParsedItems = [self parseDmailMessageToItems:requestData[Recipients]];
                if ([arrayParsedItems count] > 0) {
                    for (DmailEntityItem *item in arrayParsedItems) {
                        if ([item.access isEqualToString:AccessTypeGaranted]) {
                            [[CoreDataManager sharedCoreDataManager] writeMessageToDmailEntityWithparameters:item];
                        }
                        else {
                            item.access = AccessTypeRevoked;
                            [[CoreDataManager sharedCoreDataManager] writeMessageToDmailEntityWithparameters:item];
                        }
                    }
                }
            }
        }];
    }
}

@end
