//
//  InboxModel.m
//  Dmail
//
//  Created by Karen Petrosyan on 6/18/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "InboxModel.h"
#import "NetworkManager.h"
#import "MessageService.h"


@interface InboxModel ()

@property (nonatomic, assign) MessageType messageType;

@end

@implementation InboxModel

- (id)initWithMessageType:(MessageType)messageType {
    
    self = [super init];
    if (self != nil) {
        self.messageType = messageType;
    }
    
    return  self;
}


#pragma mark - Public Methods
- (void)getMessageListWithPosition:(NSInteger)position count:(NSInteger)count senderEmail:(NSString *)senderEmail withCompletionBlock:(void (^)(NSArray *arrayMessages, NSInteger statusCode))completion {
    
    NSMutableArray *arraMessageList = [[NSMutableArray alloc] init];
    __block NSInteger status = 0;
    [[NetworkManager sharedManager] getMessageListFromDmailWithPosition:position count:count senderEmail:senderEmail withCompletionBlock:^(NSDictionary *requestData, NSInteger statusCode) {
        status = statusCode;
        if (requestData) {
            NSArray *arrayDmailList = requestData[@"arrayDmailList"];
            for (NSDictionary *dict in arrayDmailList) {
                NSString *gmailUniqueId = dict[@"gmailUniqueId"];
                [[MessageService sharedInstance] getMessageFromGmailWithMessageUniqueId:gmailUniqueId withCompletionBlock:^(NSDictionary *message, NSInteger statusCode) {
                    //Write Message public key to DB
                    status = statusCode;
                    [arraMessageList addObject:message];
                }];
            }
        }
        completion(arraMessageList, status);
    }];
}

@end
