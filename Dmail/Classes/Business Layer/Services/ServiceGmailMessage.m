//
//  ServiceGmailMessage.m
//  Dmail
//
//  Created by Gevorg Ghukasyan on 7/7/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "ServiceGmailMessage.h"

#import "DAOGmailMessage.h"

@interface ServiceGmailMessage ()

@property (nonatomic, strong) DAOGmailMessage *daoGmailMessage;

@end

@implementation ServiceGmailMessage

- (instancetype)init {
    
    self = [super init];
    if (self) {
        _daoGmailMessage = [[DAOGmailMessage alloc] init];
    }
    
    return self;
}

- (void)getMessageIdWithUniqueId:(NSString *)messageIdentifier userId:(NSString *)userID serverId:(NSString *)serverId completionBlock:(CompletionBlock)completionBlock {
    
    [self.daoGmailMessage getMessageIdWithUniqueId:messageIdentifier userId:userID serverId:serverId completionBlock:^(id data, ErrorDataModel *error) {
        completionBlock(data, error);
    }];
}

- (void)getMessageWithMessageId:(NSString *)messageId userId:(NSString *)userID completionBlock:(CompletionBlock)completionBlock {
    
    [self.daoGmailMessage getMessageWithMessageId:messageId userId:userID completionBlock:^(id data, ErrorDataModel *error) {
        completionBlock(data, error);
    }];
}

- (void)sendWithEncodedBody:(NSString *)encodedBody userId:(NSString *)userID completionBlock:(CompletionBlock)completionBlock {
    
    [self.daoGmailMessage sendWithEncodedBody:encodedBody userId:userID completionBlock:^(id data, ErrorDataModel *error) {
        completionBlock(data, error);
    }];
}

- (void)deleteWithGmailId:(NSString *)gmailId userId:(NSString *)userID completionBlock:(CompletionBlock)completionBlock {
    
    [self.daoGmailMessage deleteWithGmailId:gmailId userId:userID completionBlock:^(id data, ErrorDataModel *error) {
        completionBlock(data, error);
    }];
}

- (void)archiveMessageWithMessageId:(NSString *)messageID completionBlock:(CompletionBlock)completionBlock {
    
    [self getMessageLabelsWithMessageId:messageID completionBlock:^(NSArray *data, ErrorDataModel *error) {
        if (!error) {
            NSArray *filteredLabels = [self filterLabelsArray:data];
            [self deleteMessageLabels:filteredLabels messageId:messageID completionBlock:^(id data, ErrorDataModel *error) {
                if (!error) {
                    completionBlock(@(YES), nil);
                } else {
                    completionBlock(nil, error);
                }
            }];
        } else {
            completionBlock(nil, error);
        }
    }];
}

- (void)getMessageLabelsWithMessageId:(NSString *)messageID completionBlock:(CompletionBlock)completionBlock {
    
    [self.daoGmailMessage getMessageLabelsWithMessageId:messageID completionBlock:^(NSArray *data, ErrorDataModel *error) {
        completionBlock(data, error);
    }];
}

- (void)deleteMessageLabels:(NSArray *)labels messageId:(NSString *)messageID completionBlock:(CompletionBlock)completionBlock {
    
    [self.daoGmailMessage deleteMessageLabels:labels messageId:messageID completionBlock:^(id data, ErrorDataModel *error) {
        completionBlock(data, error);
    }];
}

- (NSArray*)filterLabelsArray:(NSArray *)labelsArr {
    
    NSMutableArray *arr = [NSMutableArray arrayWithArray:labelsArr];
    
    [arr removeObject:@"SENT"];
    [arr removeObject:@"DRAFT"];
    
    return [NSArray arrayWithArray:arr];
}

@end
