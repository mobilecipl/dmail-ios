//
//  ServiceMessage.m
//  Dmail
//
//  Created by Armen Mkrtchian on 6/30/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "ServiceMessage.h"

// dao
#import "DAOMessage.h"

// view model
#import "VMInboxMessage.h"

#import <Realm.h>
#import "RMModelGmailMessage.h"

@interface ServiceMessage ()
@property (nonatomic, strong) DAOMessage *daoMessage;
@property (nonatomic, assign) NSInteger participantIndex;
@end

@implementation ServiceMessage

- (instancetype)init {
    
    if (self) {
        _daoMessage = [[DAOMessage alloc] init];
        _participantIndex = 0;
    }
    
    return self;
}

- (void)sendEncryptedMessage:(NSString *)encryptedMessage senderEmail:(NSString *)senderEmail completionBlock:(CompletionBlock)completionBlock {
    
    [self.daoMessage sendEncryptedMessage:encryptedMessage senderEmail:senderEmail completionBlock:^(id data, ErrorDataModel *error) {
        completionBlock(data, error);
    }];
}

- (void)sendRecipientEmail:(NSString *)recipientEmail key:(NSString *)key recipientType:(NSString *)recipientType messageId:(NSString *)messageId completionBlock:(CompletionBlock)completionBlock {
    
    [self.daoMessage sendRecipientEmail:recipientEmail key:key recipientType:recipientType messageId:messageId completionBlock:^(id data, ErrorDataModel *error) {
        completionBlock(data, error);
    }];
}

- (void)deleteRecipientEmail:(NSString *)recipientEmail messageId:(NSString *)messageId completionBlock:(CompletionBlock)completionBlock {
    
    [self.daoMessage deleteRecipientEmail:recipientEmail messageId:messageId completionBlock:^(id data, ErrorDataModel *error) {
        completionBlock(data, error);
    }];
}

- (void)sentEmail:(NSString *)senderEmail messageId:(NSString *)messageId messageIdentifier:(NSString *)messageIdentifier completionBlock:(CompletionBlock)completionBlock {
    
    [self.daoMessage sentEmail:senderEmail messageId:messageId messageIdentifier:messageIdentifier completionBlock:^(id data, ErrorDataModel *error) {
        completionBlock(data, error);
    }];
}

- (NSArray *)getInboxMessages {
    
    NSMutableArray *arrayItems = [@[] mutableCopy];
    for (RMModelGmailMessage *gmailMessage in [self.daoMessage getInboxMessages]) {
        
        VMInboxMessage *inboxMessageVM = [[VMInboxMessage alloc] init];
        inboxMessageVM.senderName = gmailMessage.from;
        inboxMessageVM.messageSubject = gmailMessage.subject;
        inboxMessageVM.messageDate = gmailMessage.messageDate;
        inboxMessageVM.messageIdentifier = gmailMessage.messageIdentifier;
        
        inboxMessageVM.read = gmailMessage.read;
        
        [arrayItems addObject:inboxMessageVM];
    }
    
    return arrayItems;
}

- (NSArray *)getSentMessages {
    
    return [self.daoMessage getSentMessages];
}

//- (void)deleteMessageWithMessageItem:(MessageItem *)item {
//    
//    [[CoreDataManager sharedCoreDataManager] removeGmailMessageWithDmailId:item.dmailId];
//    [[CoreDataManager sharedCoreDataManager] removeDmailMessageWithDmailId:item.dmailId];
//    [[MessageService sharedInstance] deleteMessageWithGmailId:item.gmailId completionBlock:^(BOOL success) {
//        
//    }];
//}

//- (void)destroyMessageWithMessageItem:(MessageItem *)item {
//    
//    NSMutableArray *arrayAllParticipants = [self getAllParticipantsWithMessageItem:item];
//    if ([arrayAllParticipants count] > 0) {
//        [[MessageService sharedInstance] revokeUserWithEmail:[arrayAllParticipants objectAtIndex:self.participantIndex] dmailId:item.dmailId completionBlock:^(BOOL success) {
//            if (success) {
//                self.participantIndex ++;
//                if (self.participantIndex > [arrayAllParticipants count] - 1) {
//                    self.participantIndex = 0;
//                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dmail"
//                                                                    message:@"Participants are successfully destroyed"
//                                                                   delegate:self
//                                                          cancelButtonTitle:@"Ok"
//                                                          otherButtonTitles:nil, nil];
//                    [alert show];
//                }
//                else {
//                    [self destroyMessageWithMessageItem:item];
//                }
//            }
//        }];
//    }
//}

//- (NSMutableArray *)getAllParticipantsWithMessageItem:(MessageItem *)messageItem {
//    
//    NSMutableArray *arrayAllParticipants = [[NSMutableArray alloc] init];
//    for (NSString *to in messageItem.arrayTo) {
//        [arrayAllParticipants addObject:to];
//    }
//    for (NSString *cc in messageItem.arrayCc) {
//        [arrayAllParticipants addObject:cc];
//    }
//    for (NSString *bcc in messageItem.arrayBcc) {
//        [arrayAllParticipants addObject:bcc];
//    }
//    
//    return arrayAllParticipants;
//}


@end
