//
//  ComposeModel.m
//  Dmail
//
//  Created by Karen Petrosyan on 6/22/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "ComposeModel.h"
#import "ComposeModelItem.h"
#import "UserService.h"
#import "MessageService.h"
#import "CoreDataManager.h"
#import "DmailMessage.h"
#import "DmailEntityItem.h"
#import "UserService.h"
#import "ProfileItem.h"

@interface ComposeModel ()

@property (nonatomic, strong) NSString *dmailId;

@end

@implementation ComposeModel

#pragma mark - Private Methods
- (NSDictionary *)createRecipientsDictWithArrayTo:(NSArray *)arrayTO arrayCC:(NSArray *)arrayCC arrayBCC:(NSArray *)arrayBCC {
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    for (NSString *to in arrayTO) {
        [dict setObject:@"TO" forKey:@"recipient_type"];
        [dict setObject:to forKey:@"recipient_email"];
    }
//    for (NSString *cc in arrayCC) {
//        [dict setObject:@"CC" forKey:@"recipient_type"];
//        [dict setObject:cc forKey:@"recipient_email"];
//    }
//    for (NSString *bcc in arrayBCC) {
//        [dict setObject:@"BCC" forKey:@"recipient_type"];
//        [dict setObject:bcc forKey:@"recipient_email"];
//    }
    
    return [NSDictionary dictionaryWithDictionary:dict];
}

- (NSString *)createMessageBodyForGmailWithArrayTo:(NSArray *)arrayTO arrayCC:(NSArray *)arrayCC arrayBCC:(NSArray *)arrayBCC subject:(NSString *)subject body:(NSString *)body{
    
    NSString *from = [NSString stringWithFormat:@"From: %@ <%@>\n",[[UserService sharedInstance] name],[[UserService sharedInstance] email]];
    for (NSString *to in arrayTO) {
        NSString *stringTo = [NSString stringWithFormat:@"To: <%@>\n", to];
        from = [from stringByAppendingString:stringTo];
    }
//    for (NSString *cc in arrayCC) {
//        NSString *stringCC = [NSString stringWithFormat:@"Cc: <%@>\n", cc];
//        from = [from stringByAppendingString:stringCC];
//    }
//    for (NSString *bcc in arrayBCC) {
//        NSString *stringBCC = [NSString stringWithFormat:@"Bcc: <%@>\n", bcc];
//        from = [from stringByAppendingString:stringBCC];
//    }
    
    NSString *stringSubject = [NSString stringWithFormat:@"Subject: %@\n\n",subject];
    from = [from stringByAppendingString:stringSubject];
    
    from = [from stringByAppendingString:body];
    
    return from;
}

- (DmailEntityItem *)parseGmailMessageContent:(NSDictionary *)requestReply {
    
    NSLog(@"requestReply ==== %@", requestReply);
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


#pragma mark - Public Methods
- (void)sendMessageWithItem:(ComposeModelItem *)composeModelItem {
    
    //Send message body to Dmail ========== Success --> MessageSentOnlyBody
    [[MessageService sharedInstance] sendMessageToDmailWithMessageBody:composeModelItem.body senderEmail:[[UserService sharedInstance] email] completionBlock:^(NSString *dmailId, NSInteger statusCode) {
        if (dmailId) {
            DmailEntityItem *item = [[DmailEntityItem alloc] initWithClearObjects];
            item.dmailId = dmailId;            
            NSDictionary *recipients = [self createRecipientsDictWithArrayTo:composeModelItem.arrayTo arrayCC:composeModelItem.arrayCc arrayBCC:composeModelItem.arrayBcc];
            //Send Participants to Dmail ========== Success --> MessageSentParticipants
            [[MessageService sharedInstance] sendRecipientsWithParameters:recipients dmailId:dmailId completionBlock:^(BOOL success) {
                if (success) {
                    item.status = MessageSentParticipants;
                    [[CoreDataManager sharedCoreDataManager] writeMessageToDmailEntityWithparameters:item];
                    //Send Message to Gmail ========== Success --> MessageSentToGmail
                    [[MessageService sharedInstance] sendMessageToGmailWithArrayTo:composeModelItem.arrayTo
                                                                           arrayCc:composeModelItem.arrayCc
                                                                          arrayBcc:composeModelItem.arrayBcc
                                                                           subject:composeModelItem.subject
                                                                           dmailId:(NSString *)dmailId
                                                               withCompletionBlock:^(NSString *gmailMessageId, NSInteger statusCode) {
                        if (gmailMessageId) {
                            item.status = MessageSentToGmail;
                            [[CoreDataManager sharedCoreDataManager] writeMessageToDmailEntityWithparameters:item];
                            [[CoreDataManager sharedCoreDataManager] writeMessageToGmailEntityWithparameters:item];
                            //Get Message from Gmail for getting identifier
                            [[MessageService sharedInstance] getMessageFromGmailWithMessageId:gmailMessageId withCompletionBlock:^(NSDictionary *dict , NSInteger statusCode) {
                                DmailEntityItem *item = [self parseGmailMessageContent:dict];
                                if(item.identifier) {
                                    //Send identifier to Dmail ========== Success --> MessageSentFull
                                    [[MessageService sharedInstance] sendMessageUniqueIdToDmailWithMessageDmailId:dmailId gmailUniqueId:item.identifier senderEmail:[[UserService sharedInstance] email]  withCompletionBlock:^(BOOL success) {
                                        if (success) {
                                            item.subject = composeModelItem.subject;
                                            item.senderEmail = [[UserService sharedInstance] email];
                                            item.senderName = [[UserService sharedInstance] name];
                                            item.receiverEmail = [composeModelItem.arrayTo firstObject];
                                            item.type = Read;
                                            item.dmailId = dmailId;
                                            item.body = composeModelItem.body;
                                            item.label = Sent;
                                            item.status = MessageSentFull;
                                            item.arrayTo = composeModelItem.arrayTo;
                                            item.arrayCc = composeModelItem.arrayCc;
                                            item.arrayBcc = composeModelItem.arrayBcc;
                                            [[CoreDataManager sharedCoreDataManager] writeMessageToDmailEntityWithparameters:item];
                                            [[CoreDataManager sharedCoreDataManager] writeMessageToGmailEntityWithparameters:item];
                                            
                                            ProfileItem *profileItem = [[ProfileItem alloc] initWithEmail:item.receiverEmail name:item.receiverName];
                                            [[CoreDataManager sharedCoreDataManager] writeOrUpdateParticipantWith:profileItem];
                                            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationNewMessageSent object:nil];
                                        }
                                    }];
                                }
                                else {
                                    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationNewMessageSent object:@{@"Error with sending Email" : @"alert"}];
                                }
                            }];
                        }
                        else {
                            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationNewMessageSent object:@{@"Error with sending Email" : @"alert"}];
                        }
                    }];
                }
                else {
                    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationNewMessageSent object:@{@"Error with sending Email" : @"alert"}];
                }
            }];
        }
        else {
            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationNewMessageSent object:@{@"Error with sending Email" : @"alert"}];
        }
    }];
}

@end
