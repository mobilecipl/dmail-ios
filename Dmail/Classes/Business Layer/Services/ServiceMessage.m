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

@interface ServiceMessage ()
@property (nonatomic, strong) DAOMessage *daoMessage;
@end

@implementation ServiceMessage

- (instancetype)init {
    
    if (self) {
        _daoMessage = [[DAOMessage alloc] init];
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
    
    return [self.daoMessage getInboxMessages];
}

- (NSArray *)getSentMessages {
    
    return [self.daoMessage getInboxMessages];
}

@end
