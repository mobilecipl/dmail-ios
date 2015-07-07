//
//  ComposeModel.m
//  Dmail
//
//  Created by Karen Petrosyan on 6/22/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "ComposeModel.h"
#import "ComposeModelItem.h"
#import "ServiceProfile.h"
#import "MessageService.h"
#import "CoreDataManager.h"
#import "DmailMessage.h"
#import "DmailEntityItem.h"
#import "ServiceProfile.h"
#import "ProfileItem.h"
#import "CommonMethods.h"

@interface ComposeModel ()

@property (nonatomic, strong) NSString *dmailId;
@property (nonatomic, strong) NSArray *arrayAllParticipants;
@property (nonatomic, assign) NSInteger index;

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
    
    NSString *from = [NSString stringWithFormat:@"From: %@ <%@>\n",[[ServiceProfile sharedInstance] fullName],[[ServiceProfile sharedInstance] email]];
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


#pragma mark - Public Methods
- (void)sendMessageWithItem:(ComposeModelItem *)composeModelItem {
    
    //Send message body to Dmail ========== Success --> MessageSentOnlyBody
    [[MessageService sharedInstance] sendMessageToDmailWithMessageBody:composeModelItem.body senderEmail:[[ServiceProfile sharedInstance] email] completionBlock:^(NSString *dmailId, NSInteger statusCode) {
        if (dmailId) {
            self.dmailId = dmailId;
            DmailEntityItem *item = [[DmailEntityItem alloc] initWithClearObjects];
            item.dmailId = dmailId;
            //Send Participants to Dmail ========== Success --> MessageSentParticipants
            self.arrayAllParticipants = [self createParticipantsArray:composeModelItem.arrayTo arrayCc:composeModelItem.arrayCc arrayBcc:composeModelItem.arrayBcc];
            self.index = 0;
            [self sendParticipantsWithArray:self.arrayAllParticipants composeModelItem:composeModelItem item:item];
        }
        else {
            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationNewMessageSentError object:nil];
        }
    }];
}

- (NSArray *)createParticipantsArray:(NSArray *)arrayTo arrayCc:(NSArray *)arrayCc arrayBcc:(NSArray *)arrayBcc {
    
    NSMutableArray *arrayParticipants = [[NSMutableArray alloc] init];
    for (NSString *str in arrayTo) {
        NSDictionary *dict = @{@"recipient_type" : @"TO",
                               @"recipient_email" : str
                               };
        [arrayParticipants addObject:dict];
    }
    for (NSString *str in arrayCc) {
        NSDictionary *dict = @{@"recipient_type" : @"CC",
                               @"recipient_email" : str
                               };
        [arrayParticipants addObject:dict];
    }
    for (NSString *str in arrayBcc) {
        NSDictionary *dict = @{@"recipient_type" : @"BCC",
                               @"recipient_email" : str
                               };
        [arrayParticipants addObject:dict];
    }
    
    return [NSArray arrayWithArray:arrayParticipants];
}

- (void)sendParticipantsWithArray:(NSArray *)array composeModelItem:(ComposeModelItem *)composeModelItem item:(DmailEntityItem *)item {

    [[MessageService sharedInstance] sendRecipientsWithParameters:[array objectAtIndex:self.index] dmailId:self.dmailId completionBlock:^(BOOL success) {
        if (success) {
            self.index ++;
            if (self.index > [self.arrayAllParticipants count] - 1) {
                item.status = MessageSentParticipants;
                [[CoreDataManager sharedCoreDataManager] writeMessageToDmailEntityWithparameters:item];
                //Send Message to Gmail ========== Success --> MessageSentToGmail
                [[MessageService sharedInstance] sendMessageToGmailWithArrayTo:composeModelItem.arrayTo
                                                                       arrayCc:composeModelItem.arrayCc
                                                                      arrayBcc:composeModelItem.arrayBcc
                                                                       subject:composeModelItem.subject
                                                                       dmailId:(NSString *)self.dmailId
                                                           withCompletionBlock:^(NSString *gmailMessageId, NSInteger statusCode) {
                                                               if (gmailMessageId) {
                                                                   item.status = MessageSentToGmail;
                                                                   [[CoreDataManager sharedCoreDataManager] writeMessageToDmailEntityWithparameters:item];
                                                                   [[CoreDataManager sharedCoreDataManager] writeMessageToGmailEntityWithparameters:item];
                                                                   //Get Message from Gmail for getting identifier
                                                                   [[MessageService sharedInstance] getMessageFromGmailWithMessageId:gmailMessageId withCompletionBlock:^(NSDictionary *dict , NSInteger statusCode) {
                                                                       DmailEntityItem *item = [[CommonMethods sharedInstance] parseGmailMessageContent:dict];
                                                                       if(item.identifier) {
                                                                           //Send identifier to Dmail ========== Success --> MessageSentFull
                                                                           [[MessageService sharedInstance] sendMessageUniqueIdToDmailWithMessageDmailId:self.dmailId gmailUniqueId:item.identifier senderEmail:[[ServiceProfile sharedInstance] email]  withCompletionBlock:^(BOOL success) {
                                                                               if (success) {
                                                                                   item.subject = composeModelItem.subject;
                                                                                   item.fromEmail = [[ServiceProfile sharedInstance] email];
                                                                                   item.senderName = [[ServiceProfile sharedInstance] fullName];
                                                                                   item.receiverEmail = [composeModelItem.arrayTo firstObject];
                                                                                   item.type = Read;
                                                                                   item.dmailId = self.dmailId;
                                                                                   item.body = composeModelItem.body;
                                                                                   item.label = Sent;
                                                                                   item.status = MessageSentFull;
                                                                                   item.arrayTo = [[NSMutableArray alloc] initWithArray:composeModelItem.arrayTo];
                                                                                   item.arrayCc = [[NSMutableArray alloc] initWithArray:composeModelItem.arrayCc];
                                                                                   item.arrayBcc = [[NSMutableArray alloc] initWithArray:composeModelItem.arrayBcc];
                                                                                   [[CoreDataManager sharedCoreDataManager] writeMessageToDmailEntityWithparameters:item];
                                                                                   [[CoreDataManager sharedCoreDataManager] writeMessageToGmailEntityWithparameters:item];
                                                                                   
                                                                                   ProfileItem *profileItem = [[ProfileItem alloc] initWithEmail:item.receiverEmail name:item.receiverName];
                                                                                   [[CoreDataManager sharedCoreDataManager] writeOrUpdateParticipantWith:profileItem];
                                                                                   [[NSNotificationCenter defaultCenter] postNotificationName:NotificationNewMessageSent object:nil];
                                                                               }
                                                                           }];
                                                                       }
                                                                       else {
                                                                           [[NSNotificationCenter defaultCenter] postNotificationName:NotificationNewMessageSentError object:nil];
                                                                       }
                                                                   }];
                                                               }
                                                               else {
                                                                   [[NSNotificationCenter defaultCenter] postNotificationName:NotificationNewMessageSentError object:nil];
                                                               }
                                                           }];
            }
            else {
                [self sendParticipantsWithArray:array composeModelItem:composeModelItem item:item];
            }
        }
        else {
            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationNewMessageSentError object:nil];
        }
    }];
}

@end
