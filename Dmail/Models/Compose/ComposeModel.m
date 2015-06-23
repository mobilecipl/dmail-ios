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
    for (NSString *cc in arrayCC) {
        [dict setObject:@"CC" forKey:@"recipient_type"];
        [dict setObject:cc forKey:@"recipient_email"];
    }
    for (NSString *bcc in arrayBCC) {
        [dict setObject:@"BCC" forKey:@"recipient_type"];
        [dict setObject:bcc forKey:@"recipient_email"];
    }
    
    return [NSDictionary dictionaryWithDictionary:dict];
}

- (NSString *)createMessageBodyForGmailWithArrayTo:(NSArray *)arrayTO arrayCC:(NSArray *)arrayCC arrayBCC:(NSArray *)arrayBCC subject:(NSString *)subject body:(NSString *)body{
    
    NSString *from = [NSString stringWithFormat:@"From: %@ <%@>\n",[[UserService sharedInstance] name],[[UserService sharedInstance] email]];
    for (NSString *to in arrayTO) {
        NSString *stringTo = [NSString stringWithFormat:@"To: <%@>\n", to];
        from = [from stringByAppendingString:stringTo];
    }
    for (NSString *cc in arrayCC) {
        NSString *stringCC = [NSString stringWithFormat:@"Cc: <%@>\n", cc];
        from = [from stringByAppendingString:stringCC];
    }
    for (NSString *bcc in arrayBCC) {
        NSString *stringBCC = [NSString stringWithFormat:@"Bcc: <%@>\n", bcc];
        from = [from stringByAppendingString:stringBCC];
    }
    
    NSString *stringSubject = [NSString stringWithFormat:@"Subject: %@\n\n",subject];
    from = [from stringByAppendingString:stringSubject];
    
    from = [from stringByAppendingString:body];
    
    return from;
}


#pragma mark - Public Methods
- (void)sendMessageWithItem:(ComposeModelItem *)composeModelItem completionBlock:(void (^)(BOOL success))completion {
    
    //Send message body to Dmail ========== Success --> MessageSentOnlyBody
    __block BOOL messageSendSuccessfuly = NO;
    [[MessageService sharedInstance] sendMessageToDmailWithEncriptedMessage:composeModelItem.body senderEmail:[[UserService sharedInstance] email] completionBlock:^(NSString *dmailId, NSInteger statusCode) {
        if (dmailId) {
            DmailEntityItem *item = [[DmailEntityItem alloc] initWithClearObjects];
            item.dmailId = dmailId;
            item.body = composeModelItem.body;
            item.subject = composeModelItem.subject;
            item.senderEmail = [[UserService sharedInstance] email];
            item.status = MessageSentOnlyBody;
            
            [[CoreDataManager sharedCoreDataManager] writeMessageWithparameters:item];
            
            NSDictionary *recipients = [self createRecipientsDictWithArrayTo:composeModelItem.arrayTo arrayCC:composeModelItem.arrayCC arrayBCC:composeModelItem.arrayBCC];
            //Send Participants to Dmail ========== Success --> MessageSentParticipants
            [[MessageService sharedInstance] sendRecipientsWithParameters:recipients dmailId:dmailId completionBlock:^(BOOL success) {
                if (success) {
                    item.status = MessageSentParticipants;
                    [[CoreDataManager sharedCoreDataManager] writeMessageWithparameters:item];
                    NSString *gmailMessageBody = [self createMessageBodyForGmailWithArrayTo:composeModelItem.arrayTo
                                                                                    arrayCC:composeModelItem.arrayCC
                                                                                   arrayBCC:composeModelItem.arrayBCC
                                                                                    subject:composeModelItem.subject
                                                                                       body:composeModelItem.body];
                    //Send Message to Gmail ========== Success --> MessageSentToGmail
                    [[MessageService sharedInstance] sendMessageToGmailWithMessageGmailBody:gmailMessageBody withCompletionBlock:^(NSString *gmailMessageId, NSInteger statusCode) {
                        if (gmailMessageId) {
                            item.status = MessageSentToGmail;
                            [[CoreDataManager sharedCoreDataManager] writeMessageWithparameters:item];
                            //Get Message from Gmail for getting identifier
                            [[MessageService sharedInstance] getMessageFromGmailWithMessageId:gmailMessageId withCompletionBlock:^(DmailEntityItem *item, NSInteger statusCode) {
                                if(item.identifier) {
                                    //Send identifier to Dmail ========== Success --> MessageSentFull
                                    [[MessageService sharedInstance] sendMessageUniqueIdToDmailWithMessageDmailId:dmailId gmailUniqueId:item.identifier senderEmail:[[UserService sharedInstance] email]  withCompletionBlock:^(BOOL success) {
                                        if (success) {
                                            item.status = MessageSentFull;
                                            item.dmailId = dmailId;
                                            item.type = Sent;
                                            [[CoreDataManager sharedCoreDataManager] writeMessageWithparameters:item];
                                            messageSendSuccessfuly = YES;
                                            completion(messageSendSuccessfuly);
                                        }
                                    }];
                                }
                                else {
                                    completion(messageSendSuccessfuly);
                                }
                            }];
                        }
                        else {
                            completion(messageSendSuccessfuly);
                        }
                    }];
                }
                else {
                    completion(messageSendSuccessfuly);
                }
            }];
        }
        else {
            completion(messageSendSuccessfuly);
        }
    }];
}

@end
