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

// model
#import "ModelMessage.h"

// view model
#import "VMInboxMessage.h"


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
    for (ModelMessage *message in [self.daoMessage getInboxMessages]) {
        
        VMInboxMessage *inboxMessageVM = [[VMInboxMessage alloc] initWithModel:message];
        if (inboxMessageVM) {
            [arrayItems addObject:inboxMessageVM];
        }
    }
    
    return arrayItems;
}

- (NSArray *)getSentMessages {
    
    NSMutableArray *arrayItems = [@[] mutableCopy];
    for (ModelMessage *message in [self.daoMessage getSentMessages]) {
        
        VMInboxMessage *inboxMessageVM = [[VMInboxMessage alloc] initWithModel:message];
        if (inboxMessageVM) {
            [arrayItems addObject:inboxMessageVM];
        }
    }
    
    return arrayItems;
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
