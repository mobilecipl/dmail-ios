//
//  MessageService.m
//  Dmail
//
//  Created by Karen Petrosyan on 6/12/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "MessageService.h"
#import "NetworkManager.h"
#import "UserService.h"
#import "CoreDataManager.h"
#import "DmailEntityItem.h"
#import "ComposeModelItem.h"
#import "Profile.h"


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
    
    messageId = requestReply[@"id"];
    
    return messageId;
}

- (DmailEntityItem *)parseGmailMessageContent:(NSDictionary *)requestReply {
    
    DmailEntityItem *dmailEntityItem = [[DmailEntityItem alloc] initWithClearObjects];
    if ([[requestReply allKeys] containsObject:Payload]) {
        NSDictionary *payload = requestReply[Payload];
        if ([[payload allKeys] containsObject:Headers]) {
            NSArray *headers = payload[Headers];
            for (NSDictionary *dict in headers) {
                if ([dict[Name] isEqualToString:From]) {
                    NSArray *arraySubStrings = [dict[Value] componentsSeparatedByString:@"<"];
                    NSString *name = [arraySubStrings firstObject];
                    dmailEntityItem.senderName = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    NSString *email = [[arraySubStrings objectAtIndex:1] substringToIndex:[[arraySubStrings objectAtIndex:1] length]-1];
                    dmailEntityItem.senderEmail = email;
                }
                if ([dict[Name] isEqualToString:Subject]) {
                    dmailEntityItem.subject = dict[Value];
                }
                if ([dict[Name] isEqualToString:Message_Id]) {
                    dmailEntityItem.identifier = dict[Value];
                }
                dmailEntityItem.status = MessageFetched;
            }
        }
    }
    
    return dmailEntityItem;
}

- (NSMutableArray *)parseDmailMessageToItems:(NSArray *)arrayRecipients {
    
    NSMutableArray *arrayParsedItems = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in arrayRecipients) {
        if ([[dict allKeys] containsObject:MessageIdentifier]) {
            DmailEntityItem *dmailEntityItem = [[DmailEntityItem alloc] initWithClearObjects];
            dmailEntityItem.access = dict[Access];
            dmailEntityItem.dmailId = dict[MessageId];
            dmailEntityItem.identifier = dict[MessageIdentifier];
            dmailEntityItem.position = [dict[Position] floatValue];
            dmailEntityItem.type = [dict[Type] integerValue];
            dmailEntityItem.status = MessageFetchedPartly;
            [arrayParsedItems addObject:dmailEntityItem];
        }
    }
    
    return arrayParsedItems;
}

- (NSString *)parseGmailMessage:(NSDictionary *)dmailMessage {
    
    NSString *gmailMessageId;
    if ([[dmailMessage allKeys] containsObject:@"messages"]) {
        NSArray *arrayIds = dmailMessage[@"messages"];
        NSDictionary *dict = [arrayIds firstObject];
        gmailMessageId = dict[@"id"];
    }
    
    return gmailMessageId;
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
- (void)getMessageListFromDmailWithPosition:(NSDictionary *)parameters withCompletionBlock:(void (^)(NSArray *arrayMessagesIdentifiers, NSInteger statusCode))completion {
    
    __block NSArray *arrayMessagesIdentifiers;
    [[NetworkManager sharedManager] getMessageListFromDmailWithPosition:parameters withCompletionBlock:^(NSDictionary *requestData, NSInteger statusCode) {
        NSArray *recipients;
        if (statusCode == 200 || statusCode == 201) {
            recipients = requestData[Recipients];
            NSMutableArray *arrayParsedItems = [self parseDmailMessageToItems:requestData[Recipients]];
            arrayMessagesIdentifiers = [[CoreDataManager sharedCoreDataManager] writeDmailMessageParametersWith:arrayParsedItems];
        }
        completion(arrayMessagesIdentifiers, statusCode);
    }];
}

- (void)getMessageUniqueIDsFromDmailWithUserId:(NSString *)userID withCompletionBlock:(void (^)(NSArray *arrayIDs, NSInteger statusCode))completion {
    
    
}

- (void)getDecodedMessageWithGmailUniqueId:(NSString *)dmailMessageId withCompletionBlock:(void (^)(NSString *message, NSInteger statusCode))completion {
    
    [self getMessageFromDmailWithGmailUniqueId:dmailMessageId withCompletionBlock:^(NSString *encodedMessage, NSInteger statusCode) {
        NSString *decodedMessage;
        if (statusCode == 200) {
            decodedMessage = [self decodeMessage:encodedMessage];
            [[CoreDataManager sharedCoreDataManager] writeMessageBodyWithDmailId:dmailMessageId messageBody:decodedMessage];
        }
        completion(decodedMessage, statusCode);
    }];
}

- (void)getGmailMessageIdFromGmailWithIdentifier:(NSString *)gmailUniqueId withCompletionBlock:(void (^)(NSString *gmailMessageId, NSInteger statusCode))completion {
    
    [[NetworkManager sharedManager] getGmailMessageIdFromGmailWithMessageUniqueId:gmailUniqueId withCompletionBlock:^(NSDictionary *requestData, NSInteger statusCode) {
        NSString *identifier;
        if (statusCode == 200) {
            identifier = [self parseGmailMessage:requestData];
        }
        completion (identifier, statusCode);
    }];
}

- (void)getMessageFromGmailWithMessageId:(NSString *)messageId withCompletionBlock:(void (^)(NSInteger statusCode))completion {
    
    [[NetworkManager sharedManager] getMessageFromGmailWithMessageId:messageId withCompletionBlock:^(NSDictionary *requestData, NSInteger statusCode) {
        DmailEntityItem *dmailEntityItem;
        if (statusCode == 200) {
            dmailEntityItem = [self parseGmailMessageContent:requestData];
            [[CoreDataManager sharedCoreDataManager] writeDmailMessageParametersWith:@[dmailEntityItem]];
        }
        completion(statusCode);
    }];
}

- (void)getMessageFromGmailWithMessageId:(NSString *)messageId dmailId:(NSString *)dmailId withCompletionBlock:(void (^)(NSInteger statusCode))completion {
    
    [[NetworkManager sharedManager] getMessageFromGmailWithMessageId:messageId withCompletionBlock:^(NSDictionary *requestData, NSInteger statusCode) {
        DmailEntityItem *dmailEntityItem;
        if (statusCode == 200) {
            dmailEntityItem = [self parseGmailMessageContent:requestData];
            dmailEntityItem.dmailId = dmailId;
            [[CoreDataManager sharedCoreDataManager] writeDmailMessageParametersWith:@[dmailEntityItem]];
        }
        completion(statusCode);
    }];
}

- (void)getMessageFromDmailWithGmailUniqueId:(NSString *)dmailMessageId withCompletionBlock:(void (^)(NSString *encodedMessage, NSInteger statusCode))completion {
    
    [[NetworkManager sharedManager] getMessageFromDmailWithGmailUniqueId:dmailMessageId withCompletionBlock:^(NSDictionary *requestData, NSInteger statusCode) {
        completion(requestData[@"encrypted_message"], statusCode);
    }];
}


#pragma mark - Send Methods
- (void)sendRecipientsWithParameters:(NSDictionary *)parameters messageId:(NSString *)messageId completionBlock:(void (^)(BOOL success))completion {
    
    [[NetworkManager sharedManager] sendRecipientsWithParameters:parameters messageId:messageId completionBlock:^(NSDictionary *requestData, NSInteger statusCode) {
        BOOL success = NO;
        if (statusCode == 200 || statusCode == 201) {
            [[CoreDataManager sharedCoreDataManager] changeMessageStatusWithMessageId:messageId messageStatus:MessageSentParticipants];
            success = YES;
        }
        completion(success);
    }];
}

- (void)sendMessageToDmailWithEncriptedMessage:(NSString *)encriptedMessage senderEmail:(NSString *)senderEmail completionBlock:(void (^)(NSString *messageId, NSInteger statusCode))completion {
    
    [[NetworkManager sharedManager] sendMessageToDmailWithEncriptedMessage:encriptedMessage senderEmail:senderEmail completionBlock:^(NSDictionary *requestData, NSInteger statusCode) {
        NSString *dmailId;
        if (statusCode == 201) {
            dmailId = requestData[@"message_id"];
            DmailEntityItem *dmailEntityItem = [[DmailEntityItem alloc] initWithClearObjects];
            dmailEntityItem.access = @"GRANTED";
            dmailEntityItem.dmailId = dmailId;
            NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
            dmailEntityItem.position = timeInterval*1000;
            dmailEntityItem.type = Sent;
            dmailEntityItem.status = MessageSentOnlyBody;
            [[CoreDataManager sharedCoreDataManager] writeDmailMessageParametersWith:@[dmailEntityItem]];
        }
        completion(dmailId,statusCode);
    }];
}

- (void)sendMessageToGmailWithParamateres:(ComposeModelItem *)composeModelItem receiverEmail:(NSString *)receiverEmail dmailId:(NSString *)dmailId withCompletionBlock:(void (^)(NSString *gmailMessageId, NSInteger statusCode))completion {
    
    Profile *receiverProfile = [[CoreDataManager sharedCoreDataManager] getProfileWithEmail:receiverEmail];
    NSString *fullMessageBody;
    if (receiverProfile.name && ![[[[GIDSignIn sharedInstance].currentUser profile] email] isEqualToString:receiverEmail]) {
        fullMessageBody = [NSString stringWithFormat:@"From: %@ <%@>\nTo: %@ <%@>\nSubject: %@\n\n%@",[[UserService sharedInstance] name],[[[GIDSignIn sharedInstance].currentUser profile] email], @"Karen", receiverEmail, composeModelItem.subject, composeModelItem.body];
    }
    else {
        fullMessageBody = [NSString stringWithFormat:@"From: %@ <%@>\nTo: <%@>\nSubject: %@\n\n%@",[[UserService sharedInstance] name],[[[GIDSignIn sharedInstance].currentUser profile] email], receiverEmail, composeModelItem.subject, composeModelItem.body];
    }
    NSString *base64EncodedMessage = [self base64Encoding:fullMessageBody];
    [[NetworkManager sharedManager] sendMessageToGmailWithEncodedBody:base64EncodedMessage withCompletionBlock:^(NSDictionary *requestData, NSInteger statusCode) {
        NSString *messageId;
        if (statusCode == 200) {
            messageId = [self getMessageIdAfterSendMessage:requestData];
            DmailEntityItem *dmailEntityItem = [[DmailEntityItem alloc] initWithClearObjects];
            dmailEntityItem.subject = composeModelItem.subject;
            dmailEntityItem.body = composeModelItem.body;
            dmailEntityItem.status = MessageSentFull;
            dmailEntityItem.dmailId = dmailId;
            [[CoreDataManager sharedCoreDataManager] writeDmailMessageParametersWith:@[dmailEntityItem]];
        }
        completion(messageId,statusCode);
    }];
}

- (void)sendMessageUniqueIdToDmailWithMessageDmailId:(NSString*)dmailId gmailUniqueId:(NSString *)gmailUniqueId senderEmail:(NSString *)senderEmail withCompletionBlock:(void (^)(NSString *gmailMessageId, NSInteger statusCode))completion {
    
    [[NetworkManager sharedManager] sendMessageUniqueIdToDmailWithMessageDmailId:dmailId gmailUniqueId:gmailUniqueId senderEmail:senderEmail withCompletionBlock:^(NSDictionary *requestData, NSInteger statusCode) {
        NSString *messageId;
        if (statusCode == 200) {
            messageId = requestData[@"message_id"];
        }
        completion(messageId,statusCode);
    }];
}

@end
