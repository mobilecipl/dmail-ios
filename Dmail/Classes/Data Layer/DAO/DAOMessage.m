//
//  DAOMessage.m
//  Dmail
//
//  Created by Armen Mkrtchian on 6/30/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "DAOMessage.h"

// dao
#import "DAOProfile.h"
#import "DAOGmailMessage.h"

// network
#import "NetworkMessage.h"
#import "NetworkGmailMessage.h"

// model
#import "ModelMessage.h"
#import "ModelRecipient.h"
#import "ProfileModel.h"
#import "ModelSentMessage.h"
#import "ModelInboxMessage.h"

// view model
#import "VMInboxMessageItem.h"

// Realm
#import <Realm/Realm.h>
#import "RMModelMessage.h"
#import "RMModelRecipient.h"
#import "RMModelContact.h"
#import "RMModelProfile.h"

// service
#import "NSString+AESCrypt.h"
#import <NSDate+DateTools.h>
#import <GoogleSignIn/GoogleSignIn.h>

@interface DAOMessage () <UIWebViewDelegate>

@property (nonatomic, strong) NetworkMessage *networkMessage;
@property (nonatomic, strong) NetworkGmailMessage *networkGmailMessage;
@property (nonatomic, strong) DAOGmailMessage *daoGmailMessage;
@property (nonatomic, strong) UIWebView *webViewEncryptDecrypt;
@property (nonatomic, strong) NSString *encryptedMessage;
@property (nonatomic, strong) NSString *messageForEncrypt;
@property (nonatomic, strong) NSString *publicKey;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) NSInteger participantIndex;
@property (nonatomic, assign) BOOL encryption;

@end

@implementation DAOMessage


#pragma mark - Intsance Methods
- (instancetype)init {
    
    self = [super init];
    if (self) {
        _networkMessage = [[NetworkMessage alloc] init];
        _networkGmailMessage = [[NetworkGmailMessage alloc] init];
        _daoGmailMessage = [[DAOGmailMessage alloc] init];
        _webViewEncryptDecrypt = [[UIWebView alloc] init];
        _webViewEncryptDecrypt.delegate = self;
    }
    
    return self;
}


#pragma mark - Public Methods
- (void)sendMessage:(NSString *)encryptedBopdy clientKey:(NSString *)clientKey messageSubject:(NSString *)messageSubject to:(NSArray *)to cc:(NSArray *)cc bcc:(NSArray *)bcc completionBlock:(CompletionBlock)completionBlock {
    
    [self sendMessage:encryptedBopdy clientKey:(NSString *)clientKey completionBlock:^(NSString *messageId, ErrorDataModel *error) {
        if (messageId) {
            NSArray *arrayAllParticipants = [self createParticipantsArray:to arrayCc:cc arrayBcc:bcc];
            self.index = 0;
            [self sendEncodedBodyWith:encryptedBopdy messageSubject:messageSubject to:to cc:cc bcc:bcc arrayAllParticipants:arrayAllParticipants messageId:messageId];
        }
        else {
            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationNewMessageSentError object:nil];
        }
        completionBlock(messageId, error);
    }];
}

- (void)sendMessage:(NSString *)encryptedBopdy clientKey:(NSString *)clientKey completionBlock:(CompletionBlock)completionBlock {
    
    DAOProfile *daoProfile = [[DAOProfile alloc] init];
    ProfileModel *model = [daoProfile getProfile];
    [self.networkMessage sendEncryptedMessage:encryptedBopdy senderEmail:model.email completionBlock:^(id data, ErrorDataModel *error) {
        NSString *messageId = nil;
        if (data) {
            messageId = data[@"message_id"];
            [self saveMessageWithMessageId:messageId clientKey:clientKey];
        }
        completionBlock(messageId, error);
    }];
}

- (void)sendEncodedBodyWith:(NSString *)messageBody messageSubject:(NSString *)messageSubject to:(NSArray *)to cc:(NSArray *)cc bcc:(NSArray *)bcc arrayAllParticipants:(NSArray *)arrayAllParticipants messageId:(NSString *)messageId {
    
    NSDictionary *dict = [arrayAllParticipants objectAtIndex:self.index];
    [self sendRecipientEmail:dict[@"recipient_email"] key:nil recipientType:dict[@"recipient_type"] messageId:messageId completionBlock:^(id data, ErrorDataModel *error) {
        if (data) {
            self.index ++;
            if (self.index > [arrayAllParticipants count] - 1) {
                NSString *publicKey = [self getClientKeyWithMessageId:messageId];
                NSString *gmailMessageBody = [self createMessageBodyForGmailWithArrayTo:to arrayCC:cc arrayBCC:bcc subject:messageSubject dmailId:messageId publicKey:publicKey];
                NSString *base64EncodedMessage = [self encodeBase64:gmailMessageBody];
                NSString * userID = [[[GIDSignIn sharedInstance].currentUser valueForKeyPath:@"userID"] description];
                [self.daoGmailMessage sendWithEncodedBody:base64EncodedMessage userId:userID completionBlock:^(id data, ErrorDataModel *error) {
                    if (data) {
                        NSString *gmailId = data[@"id"];
                        [self saveMessageWithMessageId:messageId gmailId:gmailId];
                        [self.daoGmailMessage getMessageWithMessageId:gmailId userId:userID completionBlock:^(NSString *messageIdentifier, ErrorDataModel *error) {
                            if(messageIdentifier) {
                                DAOProfile *daoProfile = [[DAOProfile alloc] init];
                                ProfileModel *model = [daoProfile getProfile];
                                [self.networkMessage sentEmail:model.email messageId:messageId messageIdentifier:messageIdentifier completionBlock:^(id data, ErrorDataModel *error) {
                                    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationNewMessageSent object:nil];
                                }];
                            }
                            else {
                                [[NSNotificationCenter defaultCenter] postNotificationName:NotificationNewMessageSentError object:nil];
                            }
                        }];
                    }
                    else {
                        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationNewMessageSentError object:nil];
                    }
                }];
            }
            else {
                [self sendEncodedBodyWith:messageBody messageSubject:messageSubject to:to cc:cc bcc:bcc arrayAllParticipants:arrayAllParticipants messageId:messageId];
            }
        }
        else {
            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationNewMessageSentError object:nil];
        }
    }];
}

- (void)sendParticipants:(NSArray *)arrayAllParticipants messageId:(NSString *)messageId completionBlock:(CompletionBlock)completionBlock {
    
    
}

- (NSString *)encodeBase64:(NSString *)requestBody {
    
    NSString *encodedMessage;
    
    NSData *data = [requestBody dataUsingEncoding:NSUTF8StringEncoding];
    encodedMessage = [data base64EncodedStringWithOptions:0];
    encodedMessage = [encodedMessage stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
    encodedMessage = [encodedMessage stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    
    return encodedMessage;
}

- (NSString *)decodeBase64:(NSString *)encodedString {
    
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:encodedString options:0];
    NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
    NSLog(@"%@", decodedString);
    
    return decodedString;
}

- (NSString *)createMessageBodyForGmailWithArrayTo:(NSArray *)arrayTO arrayCC:(NSArray *)arrayCC arrayBCC:(NSArray *)arrayBCC subject:(NSString *)subject dmailId:(NSString *)dmailId publicKey:(NSString *)publicKey {
    
    DAOProfile *daoProfile = [[DAOProfile alloc] init];
    ProfileModel *model = [daoProfile getProfile];
    NSString *messageBody = [NSString stringWithFormat:@"From: %@ <%@>\n",model.fullName,model.email];
    for (NSString *to in arrayTO) {
        NSString *stringTo = [NSString stringWithFormat:@"To: <%@>\n", to];
        messageBody = [messageBody stringByAppendingString:stringTo];
    }
    for (NSString *cc in arrayCC) {
        NSString *stringCC = [NSString stringWithFormat:@"Cc: <%@>\n", cc];
        messageBody = [messageBody stringByAppendingString:stringCC];
    }
    for (NSString *bcc in arrayBCC) {
        NSString *stringBCC = [NSString stringWithFormat:@"Bcc: <%@>\n", bcc];
        messageBody = [messageBody stringByAppendingString:stringBCC];
    }
    
    NSString *stringSubject = [NSString stringWithFormat:@"Subject: %@\n",subject];
    messageBody = [messageBody stringByAppendingString:stringSubject];
    
    messageBody = [messageBody stringByAppendingString:@"Content-Type: text/html; charset=utf-8\n"];
    messageBody = [messageBody stringByAppendingString:@"Content-Transfer-Encoding: quoted-printable\n\n"];    
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    RLMResults *resultsProfiles = [RMModelProfile allObjectsInRealm:realm];
    RMModelProfile *profile = [resultsProfiles firstObject];
    NSString *encodedTemplate = profile.bodyTemplate;
    NSString *decodedTemplate = [self decodeBase64:encodedTemplate];
    messageBody = [messageBody stringByAppendingString:decodedTemplate];
    messageBody = [messageBody stringByReplacingOccurrencesOfString:@"{{" withString:dmailId];
    messageBody = [messageBody stringByReplacingOccurrencesOfString:@"}}" withString:publicKey];
  
    NSLog(@"messageBody ====== %@", messageBody);
    return messageBody;
}

- (NSArray *)createParticipantsArray:(NSArray *)arrayTo arrayCc:(NSArray *)arrayCc arrayBcc:(NSArray *)arrayBcc {
    
    NSMutableArray *arrayParticipants = [[NSMutableArray alloc] init];
    for (NSString *str in arrayTo) {
        NSDictionary *dict = @{@"recipient_type" : @"TO",
                               @"recipient_email" : str
                               };
        [arrayParticipants addObject:dict];
    }
    for (NSString *str in arrayCc) {
        NSDictionary *dict = @{@"recipient_type" : @"CC",
                               @"recipient_email" : str
                               };
        [arrayParticipants addObject:dict];
    }
    for (NSString *str in arrayBcc) {
        NSDictionary *dict = @{@"recipient_type" : @"BCC",
                               @"recipient_email" : str
                               };
        [arrayParticipants addObject:dict];
    }
    
    return [NSArray arrayWithArray:arrayParticipants];
}

- (NSString *)getClientKeyWithMessageId:(NSString *)messageId {
    
    NSString *clientKey;
    RLMRealm *realm = [RLMRealm defaultRealm];
    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"messageId = %@", messageId];
    RLMResults *resultsGmailMessages = [RMModelMessage objectsInRealm:realm withPredicate:predicate];
    RMModelMessage *message = [resultsGmailMessages firstObject];
    if (message) {
        clientKey = message.publicKey;
    }
    
    return clientKey;
}

- (void)saveMessageWithMessageId:(NSString *)messageId gmailId:(NSString *)gmailId {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    RLMResults *results = [RMModelMessage objectsInRealm:realm where:@"messageId = %@", messageId];
    [realm beginWriteTransaction];
    for (RMModelMessage *realmModel in results) {
        realmModel.gmailId = gmailId;
    }
    [realm commitWriteTransaction];
}

- (void)sendRecipientEmail:(NSString *)recipientEmail key:(NSString *)key recipientType:(NSString *)recipientType messageId:(NSString *)messageId completionBlock:(CompletionBlock)completionBlock {
    
    [self.networkMessage sendRecipientEmail:recipientEmail key:key recipientType:recipientType messageId:messageId completionBlock:^(id data, ErrorDataModel *error) {
        ModelRecipient *recipient = [[ModelRecipient alloc] initWithDictionary:data];
        [self saveRecipient:recipient];
        completionBlock(data, error);
    }];
}

- (void)saveMessageWithMessageId:(NSString *)messageId clientKey:(NSString *)clientKey{
    
    ModelMessage *modelMessage = [[ModelMessage alloc] init];
    modelMessage.messageId = messageId;
    modelMessage.publicKey = clientKey;
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    RMModelMessage *realmModel = [[RMModelMessage alloc] initWithModel:modelMessage];
    [realm beginWriteTransaction];
    [RMModelMessage createOrUpdateInRealm:realm withValue:realmModel];
    [realm commitWriteTransaction];
}

- (void)saveRecipient:(ModelRecipient *)moderlrecipient {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    RMModelRecipient *realmModel = [[RMModelRecipient alloc] initWithModel:moderlrecipient];
    [realm beginWriteTransaction];
    [RMModelRecipient createOrUpdateInRealm:realm withValue:realmModel];
    [realm commitWriteTransaction];
}

- (void)deleteRecipientEmail:(NSString *)recipientEmail messageId:(NSString *)messageId completionBlock:(CompletionBlock)completionBlock {
    
    [self.networkMessage deleteRecipientEmail:recipientEmail messageId:messageId completionBlock:^(id data, ErrorDataModel *error) {
        completionBlock(data, error);
    }];
}

- (BOOL)hasInboxMessages {

    BOOL success = NO;
    RLMRealm *realm = [RLMRealm defaultRealm];
    DAOProfile *daoProfile = [[DAOProfile alloc] init];
    ProfileModel *modelProfile = [daoProfile getProfile];
    RLMResults *recipients = [[RMModelRecipient objectsInRealm:realm where:@"(type = %@ || type = %@ || type = %@) AND access = %@ AND recipient = %@", @"TO", @"CC", @"BCC", @"GRANTED", modelProfile.email] sortedResultsUsingProperty:@"position" ascending:NO];
    if ([recipients count] > 0) {
        success = YES;
    }
    return success;
}

- (NSArray *)getInboxMessages {
    
    DAOProfile *daoProfile = [[DAOProfile alloc] init];
    ProfileModel *modelProfile = [daoProfile getProfile];
    NSMutableArray *arrayItems = [@[] mutableCopy];
    if (modelProfile.email) {
        RLMRealm *realm = [RLMRealm defaultRealm];
        RLMResults *recipients = [[RMModelRecipient objectsInRealm:realm where:@"(type = %@ || type = %@ || type = %@) AND access = %@ AND recipient = %@", @"TO", @"CC", @"BCC", @"GRANTED", modelProfile.email] sortedResultsUsingProperty:@"position" ascending:NO];
        for (RMModelRecipient *rmRecipient in recipients) {
            RLMResults *messages = [[RMModelMessage objectsInRealm:realm where:@"messageId = %@ AND gmailId != ''",rmRecipient.messageId] sortedResultsUsingProperty:@"position" ascending:NO];
            ModelMessage *modelMessage = [messages firstObject];
            if (modelMessage) {
                ModelInboxMessage *modelInbox = [[ModelInboxMessage alloc] init];
                modelInbox.messageId = rmRecipient.messageId;
                modelInbox.messageIdentifier = rmRecipient.messageIdentifier;
                modelInbox.subject = modelMessage.subject;
                modelInbox.internalDate = modelMessage.internalDate;
                modelInbox.fromEmail = modelMessage.fromEmail;
                modelInbox.read = modelMessage.read;
                modelInbox.imageUrl = [self getRecipientImageUrlWithMessageId:rmRecipient.messageId];
                RLMResults *recipients = [[RMModelRecipient objectsInRealm:realm where:@"type = %@ AND messageId = %@", @"SENDER", rmRecipient.messageId] sortedResultsUsingProperty:@"position" ascending:NO];
                modelInbox.fromName = [self getRecipientsName:recipients];
                [arrayItems addObject:modelInbox];
            }
        }
    }
    
    return arrayItems;
}

- (NSArray *)getSentMessages {
    
    DAOProfile *daoProfile = [[DAOProfile alloc] init];
    ProfileModel *modelProfile = [daoProfile getProfile];
    NSMutableArray *arrayItems = [@[] mutableCopy];
    if (modelProfile.email) {
        RLMRealm *realm = [RLMRealm defaultRealm];
        RLMResults *recipients = [[RMModelRecipient objectsInRealm:realm where:@"type = %@ AND access = %@ AND recipient = %@", @"SENDER", @"GRANTED", modelProfile.email] sortedResultsUsingProperty:@"position" ascending:NO];
        for (RMModelRecipient *rmRecipient in recipients) {
            RLMResults *messages = [[RMModelMessage objectsInRealm:realm where:@"messageId = %@ AND gmailId != ''",rmRecipient.messageId] sortedResultsUsingProperty:@"position" ascending:NO];
            ModelMessage *modelMessage = [messages firstObject];
            if (modelMessage) {
                ModelSentMessage *modelSent = [[ModelSentMessage alloc] init];
                modelSent.messageId = rmRecipient.messageId;
                modelSent.subject = modelMessage.subject;
                modelSent.internalDate = modelMessage.internalDate;
                RLMResults *recipients = [[RMModelRecipient objectsInRealm:realm where:@"(type = %@ || type = %@ || type = %@) AND messageId = %@", @"TO", @"CC", @"BCC", rmRecipient.messageId] sortedResultsUsingProperty:@"position" ascending:NO];
                modelSent.recipientName = [self getRecipientsName:recipients];
                [arrayItems addObject:modelSent];
            }
        }
    }
    
    return arrayItems;
}

- (NSString *)getRecipientsName:(RLMResults *)result {
    
    NSString *name = @"";
    DAOProfile *daoProfile = [[DAOProfile alloc] init];
    ProfileModel *modelProfile = [daoProfile getProfile];
    RLMRealm *realm = [RLMRealm defaultRealm];
    for (RMModelRecipient *recipient in result) {
        RLMResults *contacts = [RMModelContact objectsInRealm:realm where:@"email = %@", recipient.recipient];
        RMModelContact *contact = [contacts firstObject];
        if ([contact.email isEqualToString:modelProfile.email]) {
            name = [name stringByAppendingString:modelProfile.fullName];
        }
        else {
            if (contact.fullName.length > 0) {
                name = [name stringByAppendingString:contact.fullName];
            }
            else {
                name = [name stringByAppendingString:recipient.recipient];
            }
        }
        name = [name stringByAppendingString:@","];
    }
    if (name.length > 0) {
        name = [name substringToIndex:[name length] - 1];
    }
    
    return name;
}

- (void)getMessageBodyWithMessageId:(NSString *)messageId {
    
    DAOProfile *daoProfile = [[DAOProfile alloc] init];
    ProfileModel *model = [daoProfile getProfile];
    ModelMessage *modelMessage = [self getMessageWithMessageId:messageId];
    if (model) {
        [self.networkMessage getEncryptedMessage:messageId recipientEmail:model.email completionBlock:^(NSDictionary *data, ErrorDataModel *error) {
            NSLog(@"%@", data);
            self.encryptedMessage = data[@"encrypted_message"];
            self.encryption = NO;
            self.publicKey = modelMessage.publicKey;
            [self.webViewEncryptDecrypt loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"GiberishEnc" ofType:@"html"]isDirectory:NO]]];
        }];
    }
}

- (void)writeDecryptedBodyWithMessageId:(NSString *)messageId body:(NSString *)body {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    RLMResults *results = [RMModelMessage objectsInRealm:realm where:@"messageId = %@", messageId];
    RMModelMessage *rmMessage = [results firstObject];
    [realm beginWriteTransaction];
    rmMessage.body = body;
    [realm commitWriteTransaction];
}

- (NSString *)generatePublicKey {
    
    NSString *clientKey;
    NSDate *date = [NSDate date];
    NSTimeInterval timeInterval = [date timeIntervalSince1970];
    clientKey = [NSString stringWithFormat:@"%f", timeInterval];
    
    return clientKey;
}

- (NSString *)encodeMessage:(NSString *)message clientKey:(NSString *)clientKey{
    
    NSString *encryptedText = [message AES256EncryptWithKey:clientKey];
    if (!encryptedText) {
        encryptedText = @"";
    }
    
    return encryptedText;
}

- (NSString *)decodeMessage:(NSString *)encodedMessage key:(NSString *)publicKey{
    
    NSString *decryptedText = [encodedMessage AES256DecryptWithKey:publicKey];
    return decryptedText;
}

- (ModelMessage *)getMessageWithMessageId:(NSString *)messageId{
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"messageId = %@", messageId];
    RLMResults *resultsGmailMessages = [RMModelMessage objectsInRealm:realm withPredicate:predicate];
    RMModelMessage *message = [resultsGmailMessages firstObject];
    
    ModelMessage *modelMessage = nil;
    
    if (message) {
        modelMessage = [[ModelMessage alloc] init];
        modelMessage.messageIdentifier = message.messageIdentifier;
        modelMessage.internalDate = message.internalDate;
        modelMessage.messageId = message.messageId;
        modelMessage.gmailId = message.gmailId;
        modelMessage.type = message.type;
        modelMessage.read = message.read;
        if (message.body.length != 0) {
            modelMessage.body = message.body;
        }
        RLMResults *recipients = [RMModelRecipient objectsInRealm:realm where:@"type = %@ AND messageId = %@", @"TO", message.messageId];
        modelMessage.to = [self arrayRecipients:recipients];
        recipients = [RMModelRecipient objectsInRealm:realm where:@"type = %@ AND messageId = %@", @"CC", message.messageId];
        modelMessage.cc = [self arrayRecipients:recipients];
        recipients = [RMModelRecipient objectsInRealm:realm where:@"type = %@ AND messageId = %@", @"BCC", message.messageId];
        modelMessage.bcc = [self arrayRecipients:recipients];
        modelMessage.subject = message.subject;
        modelMessage.fromName = message.fromName;
        modelMessage.fromEmail = message.fromEmail;
        modelMessage.publicKey = message.publicKey;
        modelMessage.imageUrl = [self getRecipientImageUrlWithMessageId:message.messageId];
    }
    
    return modelMessage;
}

- (NSString *)getRecipientImageUrlWithMessageId:(NSString *)messageId {
    
    NSString *imageUrl;
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    RLMResults *recipients = [RMModelRecipient objectsInRealm:realm where:@"type = %@ AND access = %@ AND messageId = %@", @"SENDER", @"GRANTED", messageId];
    RMModelRecipient *modelRecipient = [recipients firstObject];
    if (modelRecipient) {
        RMModelContact *contact = [RMModelContact objectInRealm:realm forPrimaryKey:modelRecipient.recipient];
        
        RLMResults *resultsProfiles = [RMModelProfile allObjectsInRealm:realm];
        RMModelProfile *profile = [resultsProfiles firstObject];
        if ([modelRecipient.recipient isEqualToString:profile.email]) {
            imageUrl = profile.imageUrl;
        }
        else {
            NSString *token = profile.token;
            imageUrl = [NSString stringWithFormat:@"%@?access_token=%@", contact.imageUrl, token];
        }
    }
    
    return imageUrl;
}

- (NSArray *)arrayRecipients:(RLMResults *)results {
    
    NSMutableArray *arrayrecipients = [[NSMutableArray alloc] init];
    for (RMModelRecipient *recipient in results) {
        [arrayrecipients addObject:recipient.recipient];
    }
    
    return [NSArray arrayWithArray:arrayrecipients];
}

- (RMModelMessage *)getLastGmailUniqueId {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    RLMResults *messages = [[RMModelMessage objectsInRealm:realm where:@"access = %@ AND gmailId = ''", @"GRANTED"] sortedResultsUsingProperty:@"position" ascending:NO];
    RMModelMessage *message = [messages firstObject];
    
    return message;
}

- (NSString *)getLastGmailMessageId {
    
    NSString *gmailMessageId = nil;
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    RLMResults *messages = [[RMModelMessage objectsInRealm:realm where:@"gmailId != '' AND internalDate = 0"] sortedResultsUsingProperty:@"position" ascending:NO];
    RMModelMessage *message = [messages firstObject];
    gmailMessageId = message.gmailId;
    
    return gmailMessageId;
}

- (NSNumber *)getLastDmailPosition {
    
    NSNumber *position = @0;
    RLMRealm *realm = [RLMRealm defaultRealm];
    RLMResults *recipients = [[RMModelRecipient allObjectsInRealm:realm] sortedResultsUsingProperty:@"position" ascending:NO];
    for (RMModelRecipient *recipient in recipients) {
        // get first result
        position = @(recipient.position);
        break;
    }
    
    return position;
}

- (void)deleteMessageWithMessageId:(NSString *)messageId {
    
    NSString *gmailId;
    RLMRealm *realm = [RLMRealm defaultRealm];
    RLMResults *results = [RMModelMessage objectsInRealm:realm where:@"messageId = %@", messageId];
    RMModelMessage *realmModel = [results firstObject];
    gmailId = realmModel.gmailId;
    
    NSString * userID = [[[GIDSignIn sharedInstance].currentUser valueForKeyPath:@"userID"] description];
    [self.networkGmailMessage deleteWithGmailId:gmailId userId:userID completionBlock:^(id data, ErrorDataModel *error) {
        if ([data isEqual:@(YES)]) {
            [realm beginWriteTransaction];
            [realm deleteObject:realmModel];
            [realm commitWriteTransaction];
        }
    }];
}

- (void)unreadMessageWithMessageId:(NSString *)messageId {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    RLMResults *results = [RMModelMessage objectsInRealm:realm where:@"messageId = %@", messageId];
    RMModelMessage *realmModel = [results firstObject];
    [realm beginWriteTransaction];
    realmModel.read = NO;
    [realm commitWriteTransaction];
}

- (void)destroyMessageWithMessageId:(NSString *)messageId participant:(NSString *)participant {
    
    self.participantIndex = 0;
    if (participant) {
        [self destroWithArrayParticipants:@[participant] messageId:messageId];
    }
    else {
        NSMutableArray *arrayRecipients = [[NSMutableArray alloc] init];
        RLMRealm *realm = [RLMRealm defaultRealm];
        RLMResults *recipients = [RMModelRecipient objectsInRealm:realm where:@"(type = %@ || type = %@ || type = %@) AND messageId = %@", @"TO", @"CC", @"BCC", messageId];
        for (RMModelRecipient *rmRecipient in recipients) {
            [arrayRecipients addObject:rmRecipient.recipient];
        }
        [self destroWithArrayParticipants:arrayRecipients messageId:messageId];
    }
}

- (void)destroWithArrayParticipants:(NSArray *)arrayParticipants messageId:(NSString *)messageId {
    
    if ([arrayParticipants count] > 0) {
        [self.networkMessage revokeUserWithMessageId:messageId email:[arrayParticipants objectAtIndex:self.participantIndex] completionBlock:^(id data, ErrorDataModel *error) {
            if ([data isEqual:@(YES)]) {
                RLMRealm *realm = [RLMRealm defaultRealm];
                RLMResults *results = [RMModelRecipient objectsInRealm:realm where:@"recipient = %@  AND messageId = %@",[arrayParticipants objectAtIndex:self.participantIndex], messageId];
                [realm beginWriteTransaction];
                for (RMModelRecipient *model in results) {
                    model.access = @"REVOKED";
                }
                [realm commitWriteTransaction];
                
                self.participantIndex++;
                if (self.participantIndex > [arrayParticipants count] - 1) {
                    self.participantIndex = 0;
                    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationDestroySuccess object:nil];
                }
                else {
                    [self destroWithArrayParticipants:arrayParticipants messageId:messageId];
                }
            }
            else {
                [[NSNotificationCenter defaultCenter] postNotificationName:NotificationDestroyFailed object:nil];
            }
        }];
    }
}

- (void)getTemplateWithCompletionBlock:(CompletionBlock)completionBlock {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    RLMResults *resultsProfiles = [RMModelProfile allObjectsInRealm:realm];
    RMModelProfile *profile = [resultsProfiles firstObject];
    NSDate *templateLastUpdate = [NSDate dateWithTimeIntervalSince1970:profile.templateLastUpdateDate];
    NSDate *date = [[NSDate alloc] init];
    double time = [date hoursFrom:templateLastUpdate];
    if (profile.templateLastUpdateDate == 0 || time >= 12) {
        [self.networkMessage getTemplateWithCompletionBlock:^(NSDictionary *data, ErrorDataModel *error) {
            if ([[data allKeys] containsObject:@"body"]) {
                [realm beginWriteTransaction];
                profile.bodyTemplate = data[@"body"];
                profile.templateLastUpdateDate = [[NSDate date] timeIntervalSince1970];
                [realm commitWriteTransaction];
                completionBlock (nil, nil);
            }
            else {
                completionBlock (nil, nil);
            }
        }];
    }
}

- (NSString *)getGmailIDWithMessageId:(NSString *)messageId {
    
    NSString *messageID;
    RLMRealm *realm = [RLMRealm defaultRealm];
    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"messageId = %@", messageId];
    RLMResults *resultsGmailMessages = [RMModelMessage objectsInRealm:realm withPredicate:predicate];
    RMModelMessage *message = [resultsGmailMessages firstObject];
    if (message) {
        messageID = message.gmailId;
    }
    
    return messageID;
}

- (void)changeMessageStatusToReadWithMessageId:(NSString *)messageId {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    RLMResults *results = [RMModelMessage objectsInRealm:realm where:@"messageId = %@", messageId];
    RMModelMessage *realmModel = [results firstObject];
    [realm beginWriteTransaction];
    realmModel.read = YES;
    [realm commitWriteTransaction];
}

- (void)clearAllData {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm deleteAllObjects];
    [realm commitWriteTransaction];
}

- (void)cancelAllRequests {
    
    [self.networkMessage cancellAllRequests];
    [self.networkGmailMessage cancellAllRequests];
}


#pragma mark - UIWebViewDelegate Methods
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    if(self.encryption) {
        NSString *jsFunction = [NSString stringWithFormat:@"GibberishAES.enc('%@', '%@')",self.messageForEncrypt, self.publicKey];
        NSString *decryptedMessage = [self.webViewEncryptDecrypt stringByEvaluatingJavaScriptFromString:jsFunction];
        NSDictionary *userInfo = @{@"decryptedMessage" : decryptedMessage};
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationGetDecryptedMessage object:nil userInfo:userInfo];
    }
    else {
        self.encryptedMessage = [self.encryptedMessage stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        NSString *jsFunction = [NSString stringWithFormat:@"GibberishAES.dec('%@', '%@')",self.encryptedMessage, self.publicKey];
        NSLog(@"=========================== %@ ==========================",jsFunction);
        NSString *decryptedMessage = [self.webViewEncryptDecrypt stringByEvaluatingJavaScriptFromString:jsFunction];
        NSDictionary *userInfo = @{@"decryptedMessage" : decryptedMessage};
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationGetDecryptedMessage object:nil userInfo:userInfo];
    }
    self.encryptedMessage = nil;
    self.publicKey = nil;
}

@end
