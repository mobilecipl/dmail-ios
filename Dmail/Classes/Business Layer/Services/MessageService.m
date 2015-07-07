//
//  MessageService.m
//  Dmail
//
//  Created by Karen Petrosyan on 6/12/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "MessageService.h"
#import "NetworkManager.h"
#import "ServiceProfile.h"
#import "CoreDataManager.h"
#import "DmailEntityItem.h"
#import "ComposeModelItem.h"
#import "Profile.h"
#import "DmailEntityItem.h"
#import "NSString+AESCrypt.h"


@interface MessageService ()

@property (nonatomic, strong) NSString *publicKey;

@end

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
    encodedMessage = [encodedMessage stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
    
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
        dmailEntityItem.internalDate = [requestReply[InternalDate] doubleValue];
        NSDictionary *payload = requestReply[Payload];
        if ([[payload allKeys] containsObject:Headers]) {
            NSArray *headers = payload[Headers];
            for (NSDictionary *dict in headers) {
                if ([dict[Name] isEqualToString:From]) {
                    NSArray *arraySubStrings = [dict[Value] componentsSeparatedByString:@"<"];
                    NSString *name = [arraySubStrings firstObject];
                    dmailEntityItem.senderName = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    NSString *email = [[arraySubStrings objectAtIndex:1] substringToIndex:[[arraySubStrings objectAtIndex:1] length]-1];
                    dmailEntityItem.fromEmail = email;
                }
                if ([dict[Name] isEqualToString:Subject]) {
                    dmailEntityItem.subject = dict[Value];
                }
                if ([dict[Name] isEqualToString:Message_Id]) {
                    dmailEntityItem.identifier = dict[Value];
                }
                dmailEntityItem.status = MessageFetchedFull;
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
                dmailEntityItem.label = Sent;
            }
            else if([dict[Type] isEqualToString:@"TO"]) {
                dmailEntityItem.label = Inbox;
            }
            dmailEntityItem.status = MessageFetchedOnlyIds;
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

- (NSString *)createMessageBodyForGmailWithArrayTo:(NSArray *)arrayTO arrayCC:(NSArray *)arrayCC arrayBCC:(NSArray *)arrayBCC subject:(NSString *)subject dmailId:(NSString *)dmailId {
    
    NSString *from = [NSString stringWithFormat:@"From: %@ <%@>\n",[[ServiceProfile sharedInstance] fullName],[[ServiceProfile sharedInstance] email]];
    for (NSString *to in arrayTO) {
        NSString *stringTo = [NSString stringWithFormat:@"To: <%@>\n", to];
        from = [from stringByAppendingString:stringTo];
    }
    for (NSString *cc in arrayCC) {
        NSString *stringCC = [NSString stringWithFormat:@"Cc: <%@>\n", cc];
        from = [from stringByAppendingString:stringCC];
    }
    for (NSString *bcc in arrayBCC) {
        NSString *stringBCC = [NSString stringWithFormat:@"Bcc: <%@>\n", bcc];
        from = [from stringByAppendingString:stringBCC];
    }
    
    NSString *stringSubject = [NSString stringWithFormat:@"Subject: %@\n",subject];
    from = [from stringByAppendingString:stringSubject];
    
    NSString *publicKey = [NSString stringWithFormat:@"PublicKey: %@\n",self.publicKey];
    from = [from stringByAppendingString:publicKey];
    
    NSString *messageDmailId = [NSString stringWithFormat:@"DmailId: %@\n\n",dmailId];
    from = [from stringByAppendingString:messageDmailId];
    
    NSString *publicKeyAndDmailId = [NSString stringWithFormat:@"DmailId=%@&PublicKey=%@", dmailId, self.publicKey];
    from = [from stringByAppendingString:publicKeyAndDmailId];
    
    return from;
}

- (NSString *)generatePublicKey {
    
    if (self.publicKey) {
        self.publicKey = nil;
    }
    NSDate *date = [NSDate date];
    NSTimeInterval timeInterval = [date timeIntervalSince1970];
    self.publicKey = [NSString stringWithFormat:@"%f", timeInterval];
    
    return self.publicKey;
}

- (NSString *)encodeMessage:(NSString *)message {
    
    NSString *publicKey = [self generatePublicKey];
    NSString *encryptedText = [message AES256EncryptWithKey:publicKey];
    if (!encryptedText) {
        encryptedText = @"";
    }
    
    return encryptedText;
}

- (NSString *)decodeMessage:(NSString *)encodedMessage key:(NSString *)publicKey{
    
    NSString *decryptedText = [encodedMessage AES256DecryptWithKey:publicKey];
    
    return decryptedText;
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
            NSString *publicKey = [[CoreDataManager sharedCoreDataManager] getPublicKeyWithDmailId:dmailMessageId];
            decodedMessage = [self decodeMessage:encodedMessage key:publicKey];
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

- (void)getMessageFromGmailWithMessageId:(NSString *)messageId withCompletionBlock:(void (^)(NSDictionary *requestData, NSInteger statusCode))completion {
    
    [[NetworkManager sharedManager] getMessageFromGmailWithMessageId:messageId withCompletionBlock:^(NSDictionary *requestData, NSInteger statusCode) {
        completion(requestData, statusCode);
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

- (void)sendMessageToDmailWithMessageBody:(NSString *)messageBody senderEmail:(NSString *)senderEmail completionBlock:(void (^)(NSString *dmailId, NSInteger statusCode))completion {
    
    NSString *encriptedMessage = [self encodeMessage:messageBody];
    [[NetworkManager sharedManager] sendMessageToDmailWithEncriptedMessage:encriptedMessage senderEmail:senderEmail completionBlock:^(NSDictionary *requestData, NSInteger statusCode) {
        NSString *dmailId;
        if (statusCode == 201) {
            dmailId = requestData[@"message_id"];
            DmailEntityItem *item = [[DmailEntityItem alloc] initWithClearObjects];
            item.dmailId = dmailId;
            item.access = @"GRANTED";
            item.body = encriptedMessage;
            item.status = MessageSentOnlyBody;
            item.publicKey = self.publicKey;
            item.label = Sent;
            [[CoreDataManager sharedCoreDataManager] writeMessageToDmailEntityWithparameters:item];
            [[CoreDataManager sharedCoreDataManager] writeMessageToGmailEntityWithparameters:item];
        }
        completion(dmailId, statusCode);
    }];
}

- (void)sendMessageToGmailWithArrayTo:(NSArray *)arrayTo
                              arrayCc:(NSArray *)arrayCc
                             arrayBcc:(NSArray *)arrayBcc
                              subject:(NSString *)subject
                              dmailId:(NSString *)dmailId
                  withCompletionBlock:(void (^)(NSString *gmailMessageId, NSInteger statusCode))completion {

    NSString *gmailMessageBody = [self createMessageBodyForGmailWithArrayTo:arrayTo
                                                                    arrayCC:arrayCc
                                                                   arrayBCC:arrayBcc
                                                                    subject:subject
                                                                    dmailId:dmailId];
    NSString *base64EncodedMessage = [self base64Encoding:gmailMessageBody];
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

- (void)revokeUserWithEmail:(NSString *)email dmailId:(NSString *)dmailId completionBlock:(void (^)(BOOL success))completion {
    
    [[NetworkManager sharedManager] revokeUserWithEmail:email dmailId:dmailId completionBlock:^(NSDictionary *requestData, NSInteger statusCode) {
        BOOL success = NO;
        if (statusCode == 200 || statusCode == 201) {
            success = YES;
        }
        completion(success);
    }];
}

- (void)deleteMessageWithGmailId:(NSString *)gmailId completionBlock:(void (^)(BOOL success))completion {
    
    [[NetworkManager sharedManager] deleteMessageWithGmailId:gmailId withCompletionBlock:^(NSDictionary *requestData, NSInteger statusCode) {
        BOOL success = NO;
        if (statusCode == 200) {
            success = YES;
        }
        completion(success);
    }];
}

@end
