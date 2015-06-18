//
//  MessageService.m
//  Dmail
//
//  Created by Karen Petrosyan on 6/12/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "MessageService.h"
#import "NetworkManager.h"
#import <GoogleSignIn/GoogleSignIn.h>


@implementation MessageService

+ (MessageService *)sharedInstance {
    static MessageService *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[MessageService alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark - Private Methods
- (NSString *)base64Encoding:(NSString *)requestBody {
    
    NSString *encodedMessage;
    
    NSData *data = [requestBody dataUsingEncoding:NSUTF8StringEncoding];
    encodedMessage = [data base64EncodedStringWithOptions:0];
    
    return encodedMessage;
}

- (NSString *)getMessageIdAfterSendMessage:(NSDictionary *)requestReply {
    
    NSString *messageId;
    
    NSLog(@"requestReply === %@", requestReply);
    messageId = requestReply[@"id"];
    
    return messageId;
}

- (NSString *)getMessageUniqueIdFromMetadata:(NSDictionary *)requestReply {
    
    NSString *messageUniqueId;
    
    NSLog(@"requestReply === %@", requestReply);
    NSDictionary *dictPayload = requestReply[@"payload"];
    NSArray *arrayHeaders = dictPayload[@"headers"];
    for (NSDictionary *dict in arrayHeaders) {
        if ([dict[@"name"] isEqualToString:@"Message-Id"]) {
            messageUniqueId = dict[@"value"];
            break;
        }
    }
    
    return messageUniqueId;
}

- (NSDictionary *)parseGmailMessage:(NSDictionary *)dmailMessage {
    
    NSDictionary *parsedDict;
    
    return parsedDict;
}

- (NSString *)encodeMessage:(NSString *)decodedMessage {
    
    NSString *encodedMessage = decodedMessage;
    
    return encodedMessage;
}

- (NSString *)decodeMessage:(NSString *)encodedMessage {
    
    NSString *decodedMessage = encodedMessage;
    
    return decodedMessage;
}


#pragma mark - Public Methods
#pragma mark - Get Methods
- (void)getMessageListFromDmailWithPosition:(NSInteger)position count:(NSInteger)count senderEmail:(NSString *)senderEmail withCompletionBlock:(void (^)(NSArray *arrayInboxItems, NSInteger statusCode))completion {
    
    [[NetworkManager sharedManager] getMessageListFromDmailWithPosition:position count:count senderEmail:senderEmail withCompletionBlock:^(NSDictionary *requestData, NSInteger statusCode) {
        NSLog(@"requestData === %@", requestData);
        switch (statusCode) {
            case 200: {
                
            }
                break;
            case 0: {
                
            }
                break;
                
            default: {
                
            }
                break;
        }

        NSString *messageId;
        BOOL success = NO;
        if (requestData[@"message_id"]) {
            success = YES;
            messageId = requestData[@"message_id"];
        }
        NSArray *arrayIds;
        completion(arrayIds, statusCode);
    }];
}

- (void)getMessageUniqueIDsFromDmailWithUserId:(NSString *)userID withCompletionBlock:(void (^)(NSArray *arrayIDs, NSInteger statusCode))completion {
    
    
}

- (void)getDecodedMessageWithGmailUniqueId:(NSString *)gmailUniqueId withCompletionBlock:(void (^)(NSString *message, NSInteger statusCode))completion {
    
    [self getMessageFromDmailWithGmailUniqueId:gmailUniqueId withCompletionBlock:^(NSString *encodedMessage, NSInteger statusCode) {
        NSString *decodedMessage;
        if (statusCode == 200) {
            decodedMessage = [self decodeMessage:encodedMessage];
        }
        completion(decodedMessage, statusCode);
    }];
}

- (void)getMessageFromGmailWithMessageUniqueId:(NSString *)gmailUniqueId withCompletionBlock:(void (^)(NSDictionary *message, NSInteger statusCode))completion {
    
    [[NetworkManager sharedManager] getMessageFromGmailWithMessageUniqueId:gmailUniqueId withCompletionBlock:^(NSDictionary *requestData, NSInteger statusCode) {
        NSLog(@"requestReply :: %@ \n requestStatusCode :: %ld", [requestData description],(long)statusCode);
        NSDictionary *parsedDict;
        if (statusCode == 200) {
            parsedDict = [self parseGmailMessage:requestData];
        }
        completion (parsedDict, statusCode);
    }];
}

- (void)getMessageFromGmailWithMessageId:(NSString *)messageId withCompletionBlock:(void (^)(NSString *messageUniqueId, NSInteger statusCode))completion {
    
    [[NetworkManager sharedManager] getMessageFromGmailWithMessageId:messageId withCompletionBlock:^(NSDictionary *requestData, NSInteger statusCode) {
        NSLog(@"requestReply :: %@ \n requestStatusCode :: %ld", [requestData description],(long)statusCode);
        NSString *messageUniqueId;
        if (statusCode == 200) {
            messageUniqueId = [self getMessageUniqueIdFromMetadata:requestData];
        }
        completion(messageUniqueId, statusCode);
    }];
}

- (void)getMessageFromDmailWithGmailUniqueId:(NSString *)gmailUniqueId withCompletionBlock:(void (^)(NSString *encodedMessage, NSInteger statusCode))completion {
    
    
}


#pragma mark - Send Methods
- (void)sendMessageToDmailWithEncriptedMessage:(NSString *)encriptedMessage senderEmail:(NSString *)senderEmail completionBlock:(void (^)(NSString *messageId, NSInteger statusCode))completion {
    
    [[NetworkManager sharedManager] sendMessageToDmailWithEncriptedMessage:encriptedMessage senderEmail:senderEmail completionBlock:^(NSDictionary *requestData, NSInteger statusCode) {
        NSLog(@"requestReply :: %@ \n requestStatusCode :: %ld", [requestData description],(long)statusCode);
        NSString *messageId;
        if (statusCode == 200) {
            messageId = requestData[@"message_id"];
        }
        completion(messageId,statusCode);
    }];
}

- (void)sendMessageToGmailWithTo:(NSString *)to messageSubject:(NSString *)messageSubject messageBody:(NSString *)messageBody withCompletionBlock:(void (^)(NSString *gmailMessageId, NSInteger statusCode))completion {
    
    NSString *fullMessageBody = [NSString stringWithFormat:@"From: <%@>\nTo: <%@>\nSubject: %@\n\n%@",[[[GIDSignIn sharedInstance].currentUser profile] email], to, messageSubject, messageBody];
    NSString *base64EncodedMessage = [self base64Encoding:fullMessageBody];
    [[NetworkManager sharedManager] sendMessageToGmailWithEncodedBody:base64EncodedMessage withCompletionBlock:^(NSDictionary *requestData, NSInteger statusCode) {
        NSLog(@"requestReply :: %@ \n requestStatusCode :: %ld", [requestData description],(long)statusCode);
        NSString *messageId;
        if (statusCode == 200) {
            messageId = [self getMessageIdAfterSendMessage:requestData];
        }
        completion(messageId,statusCode);
    }];
}

- (void)sendMessageUniqueIdToDmailWithMessageDmailId:(NSString*)dmailId gmailUniqueId:(NSString *)gmailUniqueId senderEmail:(NSString *)senderEmail withCompletionBlock:(void (^)(NSString *gmailMessageId, NSInteger statusCode))completion {
    
    [[NetworkManager sharedManager] sendMessageUniqueIdToDmailWithMessageDmailId:dmailId gmailUniqueId:gmailUniqueId senderEmail:senderEmail withCompletionBlock:^(NSDictionary *requestData, NSInteger statusCode) {
        NSLog(@"requestReply :: %@ \n requestStatusCode :: %ld", [requestData description],(long)statusCode);
        NSString *messageId;
        if (statusCode == 200) {
            messageId = requestData[@"message_id"];
        }
        completion(messageId,statusCode);
    }];
}

@end
