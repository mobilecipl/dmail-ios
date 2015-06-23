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
#import "DmailEntityItem.h"


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
        dmailEntityItem.internalDate = [requestReply[InternalDate] integerValue];
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
            if ([dict[Type] isEqualToString:@"SENDER"]) {
                dmailEntityItem.type = Sent;
            }
            else if([dict[Type] isEqualToString:@"TO"]) {
                dmailEntityItem.type = Inbox;
            }
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
- (void)getMessageListFromDmailWithPosition:(NSDictionary *)parameters withCompletionBlock:(void (^)(NSDictionary *requestData, NSInteger statusCode))completion {
    
    [[NetworkManager sharedManager] getMessageListFromDmailWithPosition:parameters withCompletionBlock:^(NSDictionary *requestData, NSInteger statusCode) {
        NSArray *recipients;
        if (statusCode == 200 || statusCode == 201) {
            recipients = requestData[Recipients];
        }
        completion(requestData, statusCode);
    }];
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
        NSString *gmailMessageId;
        if (statusCode == 200) {
            gmailMessageId = [self parseGmailMessage:requestData];
        }
        completion (gmailMessageId, statusCode);
    }];
}

- (void)getMessageFromGmailWithMessageId:(NSString *)messageId withCompletionBlock:(void (^)(DmailEntityItem *itemFromGmail, NSInteger statusCode))completion {
    
    [[NetworkManager sharedManager] getMessageFromGmailWithMessageId:messageId withCompletionBlock:^(NSDictionary *requestData, NSInteger statusCode) {
        DmailEntityItem *itemFromGmail;
        if (statusCode == 200) {
            itemFromGmail = [self parseGmailMessageContent:requestData];
        }
        completion(itemFromGmail, statusCode);
    }];
}

- (void)getMessageFromGmailWithMessageId:(NSString *)messageId dmailId:(NSString *)dmailId withCompletionBlock:(void (^)(NSInteger statusCode))completion {
    
    [[NetworkManager sharedManager] getMessageFromGmailWithMessageId:messageId withCompletionBlock:^(NSDictionary *requestData, NSInteger statusCode) {
        DmailEntityItem *dmailEntityItem;
        if (statusCode == 200) {
            dmailEntityItem = [self parseGmailMessageContent:requestData];
            dmailEntityItem.dmailId = dmailId;
//            [[CoreDataManager sharedCoreDataManager] writeDmailMessageParametersWith:@[dmailEntityItem]];
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
- (void)sendRecipientsWithParameters:(NSDictionary *)parameters dmailId:(NSString *)dmailId completionBlock:(void (^)(BOOL success))completion {
    
    
    [[NetworkManager sharedManager] sendRecipientsWithParameters:parameters dmailId:dmailId completionBlock:^(NSDictionary *requestData, NSInteger statusCode) {
        BOOL success = NO;
        if (statusCode == 200 || statusCode == 201) {
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
//            [[CoreDataManager sharedCoreDataManager] writeDmailMessageParametersWith:@[dmailEntityItem]];
        }
        completion(dmailId,statusCode);
    }];
}

- (void)sendMessageToGmailWithMessageGmailBody:(NSString *)gmailBody withCompletionBlock:(void (^)(NSString *gmailMessageId, NSInteger statusCode))completion {

//    Profile *receiverProfile = [[CoreDataManager sharedCoreDataManager] getProfileWithEmail:receiverEmail];
//    NSString *fullMessageBody;
//    if (receiverProfile.name && ![[[[GIDSignIn sharedInstance].currentUser profile] email] isEqualToString:receiverEmail]) {
//        fullMessageBody = [NSString stringWithFormat:@"From: %@ <%@>\nTo: %@ <%@>\nSubject: %@\n\n%@",[[UserService sharedInstance] name],[[[GIDSignIn sharedInstance].currentUser profile] email], @"Karen", receiverEmail, composeModelItem.subject, composeModelItem.body];
//    }
//    else {
//        fullMessageBody = [NSString stringWithFormat:@"From: %@ <%@>\nTo: <%@>\nSubject: %@\n\n%@",[[UserService sharedInstance] name],[[[GIDSignIn sharedInstance].currentUser profile] email], receiverEmail, composeModelItem.subject, composeModelItem.body];
//    }
    NSString *base64EncodedMessage = [self base64Encoding:gmailBody];
    [[NetworkManager sharedManager] sendMessageToGmailWithEncodedBody:base64EncodedMessage withCompletionBlock:^(NSDictionary *requestData, NSInteger statusCode) {
        NSString *messageId;
        if (statusCode == 200) {
            messageId = [self getMessageIdAfterSendMessage:requestData];
//            DmailEntityItem *dmailEntityItem = [[DmailEntityItem alloc] initWithClearObjects];
//            dmailEntityItem.subject = composeModelItem.subject;
//            dmailEntityItem.body = composeModelItem.body;
//            dmailEntityItem.status = MessageSentFull;
//            dmailEntityItem.dmailId = dmailId;
//            [[CoreDataManager sharedCoreDataManager] writeDmailMessageParametersWith:@[dmailEntityItem]];
        }
        completion(messageId,statusCode);
    }];
}

- (void)sendMessageUniqueIdToDmailWithMessageDmailId:(NSString*)dmailId gmailUniqueId:(NSString *)gmailUniqueId senderEmail:(NSString *)senderEmail withCompletionBlock:(void (^)(BOOL sucess))completion {
    
    [[NetworkManager sharedManager] sendMessageUniqueIdToDmailWithMessageDmailId:dmailId gmailUniqueId:gmailUniqueId senderEmail:senderEmail withCompletionBlock:^(NSDictionary *requestData, NSInteger statusCode) {
        BOOL success = NO;
        if (statusCode == 200 || statusCode == 201) {
            success = YES;
        }
        completion(success);
    }];
}

@end
