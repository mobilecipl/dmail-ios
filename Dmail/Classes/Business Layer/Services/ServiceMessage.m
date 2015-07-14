//
//  ServiceMessage.m
//  Dmail
//
//  Created by Armen Mkrtchian on 6/30/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "ServiceMessage.h"

// service
#import "ServiceProfile.h"

// dao
#import "DAOMessage.h"
#import "DAOGmailMessage.h"

// model
#import "ModelMessage.h"
#import "ModelRecipient.h"
#import "ModelSentMessage.h"

// view model
#import "VMInboxMessageItem.h"
#import "VMSentMessageItem.h"
#import "VMSentMessage.h"

#import "MessageService.h"


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

- (NSArray *)getInboxMessages {
    
    NSMutableArray *arrayItems = [@[] mutableCopy];
    for (ModelMessage *modelMessage in [self.daoMessage getInboxMessages]) {
        VMInboxMessageItem *inboxMessageVM = [[VMInboxMessageItem alloc] initWithModel:modelMessage];
        if (inboxMessageVM) {
            [arrayItems addObject:inboxMessageVM];
        }
    }
    
    return arrayItems;
}

- (NSArray *)getSentMessages {
    
    NSMutableArray *arrayItems = [@[] mutableCopy];
    for (ModelSentMessage *modelSentMessage in [self.daoMessage getSentMessages]) {
        VMSentMessageItem *sentMessageVM = [[VMSentMessageItem alloc] initWithModel:modelSentMessage];
        if (sentMessageVM) {
            [arrayItems addObject:sentMessageVM];
        }
    }
    
    return arrayItems;
}

- (VMInboxMessageItem *)getInboxMessageWithMessageId:(NSString *)messageId {
    
    ModelMessage *modelMessage = [self.daoMessage getMessageWithMessageId:messageId];
    VMInboxMessageItem *inboxMessageVM = [[VMInboxMessageItem alloc] initWithModel:modelMessage];
    
    return inboxMessageVM;
}

- (VMSentMessage *)getSentMessageWithMessageId:(NSString *)messageId {
    
    ModelMessage *modelMessage = [self.daoMessage getMessageWithMessageId:messageId];
    VMSentMessage *sentMessageVM = [[VMSentMessage alloc] initWithModel:modelMessage];
    
    return sentMessageVM;
}

- (void)getMessageBodyWithIdentifier:(NSString *)messageId completionBlock:(CompletionBlock)completionBlock {
    
    [self.daoMessage getMessageBodyWithMessageId:messageId completionBlock:^(id data, ErrorDataModel *error) {
        completionBlock(data, error);
    }];
}

- (void)sendMessage:(NSString *)messageBody messageSubject:(NSString *)messageSubject to:(NSArray *)to cc:(NSArray *)cc bcc:(NSArray *)bcc completionBlock:(CompletionBlock)completionBlock {
    
    [self.daoMessage sendMessage:messageBody messageSubject:messageSubject to:to cc:cc bcc:bcc completionBlock:^(id data, ErrorDataModel *error) {
        completionBlock(data,error);
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

//- (void)deleteMessageWithMessageItem:(MessageItem *)item {
//    
//    [[CoreDataManager sharedCoreDataManager] removeGmailMessageWithDmailId:item.dmailId];
//    [[CoreDataManager sharedCoreDataManager] removeDmailMessageWithDmailId:item.dmailId];
//    [[MessageService sharedInstance] deleteMessageWithGmailId:item.gmailId completionBlock:^(BOOL success) {
//        
//    }];
//}

- (void)destroWithArrayParticipants:(NSArray *)arrayParticipants messageId:(NSString *)messageId {
    
    NSLog(@"%ld",(long)self.participantIndex);
    if ([arrayParticipants count] > 0) {
        [[MessageService sharedInstance] revokeUserWithEmail:[arrayParticipants objectAtIndex:self.participantIndex] dmailId:messageId completionBlock:^(BOOL success) {
            if (success) {
                self.participantIndex ++;
                if (self.participantIndex > [arrayParticipants count] - 1) {
                    self.participantIndex = 0;
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dmail"
                                                                    message:@"Participants are successfully destroyed"
                                                                   delegate:self
                                                          cancelButtonTitle:@"Ok"
                                                          otherButtonTitles:nil, nil];
                    [alert show];
                }
                else {
                    [self destroWithArrayParticipants:arrayParticipants messageId:messageId];
                }
            }
        }];
    }

}

- (void)destroyMessageWithMessageItem:(NSArray *)arrayParticipants messageId:(NSString *)messageId {
    
    self.participantIndex = 0;
    [self destroWithArrayParticipants:arrayParticipants messageId:messageId];
}

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
