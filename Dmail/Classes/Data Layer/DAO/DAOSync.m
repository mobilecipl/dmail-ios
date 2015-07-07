//
//  DAOSync.m
//  Dmail
//
//  Created by Armen Mkrtchian on 7/7/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "DAOSync.h"

// network
#import "NetworkMessage.h"

// model
#import "MessageItem.h"

@interface DAOSync ()
@property (nonatomic, strong) NetworkMessage *networkMessage;
@end

@implementation DAOSync
#pragma mark - Intsance Methods
- (instancetype)init {
    
    if (self) {
        _networkMessage = [[NetworkMessage alloc] init];
    }
    
    return self;
}

- (void)syncMessagesForEmail:(NSString *)recipientEmail position:(NSNumber *)position count:(NSNumber *)count completionBlock:(CompletionBlock)completionBlock {
    
    [self.networkMessage syncMessagesForEmail:recipientEmail position:position count:count completionBlock:^(id data, ErrorDataModel *error) {
        completionBlock(data, error);
    }];
}

@end
