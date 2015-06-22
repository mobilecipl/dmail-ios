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

@implementation ComposeModel

- (void)sendMessageWithItem:(ComposeModelItem *)composeModelItem completionBlock:(void (^)(BOOL success))completion {
    
    //Send message body to Dmail
    [[MessageService sharedInstance] sendMessageToDmailWithEncriptedMessage:composeModelItem.body senderEmail:[[UserService sharedInstance] email] completionBlock:^(NSString *dmailId, NSInteger statusCode) {
        if (dmailId) {
            [[CoreDataManager sharedCoreDataManager] writeMessageBodyWithDmailId:dmailId messageBody:composeModelItem.body];
            //For any participant send email address to Dmail
            for (NSString *email in composeModelItem.arrayReceiversEmail) {
                NSDictionary *dictRecipients = @{RecipientType : @"TO", RecipientEmail : email};
                [[MessageService sharedInstance] sendRecipientsWithParameters:dictRecipients messageId:dmailId completionBlock:^(BOOL success) {
                    if (success) {
                        //Send Message to Gmail For getting gmail message Id
                        [[MessageService sharedInstance] sendMessageToGmailWithParamateres:composeModelItem receiverEmail:email dmailId:dmailId withCompletionBlock:^(NSString *gmailMessageId, NSInteger statusCode) {
                            if (gmailMessageId) {
                                [[MessageService sharedInstance] getMessageFromGmailWithMessageId:gmailMessageId dmailId:dmailId withCompletionBlock:^(NSInteger statusCode) {
                                    DmailMessage *dmailMessage = [[CoreDataManager sharedCoreDataManager] getDmailMessageWithMessageId:dmailId];
                                    if (dmailMessage.identifier) {
                                        [[MessageService sharedInstance] sendMessageUniqueIdToDmailWithMessageDmailId:dmailId gmailUniqueId:dmailMessage.identifier senderEmail:[[UserService sharedInstance] email] withCompletionBlock:^(NSString *gmailMessageId, NSInteger statusCode) {
                                            [[CoreDataManager sharedCoreDataManager] changeMessageStatusWithMessageId:dmailId messageStatus:MessageSentFull];
                                            completion(success);
                                        }];
                                    }
                                    else {
                                        completion(NO);
                                    }
                                }];
                            }
                            else {
                                completion(NO);
                            }
                        }];
                    }
                    else {
                        completion(success);
                    }
                }];
            }
        }
        else {
            completion(NO);
        }
    }];
}

@end
