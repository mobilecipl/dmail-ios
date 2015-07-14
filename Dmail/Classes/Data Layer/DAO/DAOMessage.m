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

// network
#import "NetworkMessage.h"

// model
#import "ModelMessage.h"
#import "ProfileModel.h"
#import "ModelSentMessage.h"

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

@interface DAOMessage ()
@property (nonatomic, strong) NetworkMessage *networkMessage;
@end

@implementation DAOMessage


#pragma mark - Intsance Methods
- (instancetype)init {
    
    if (self) {
        _networkMessage = [[NetworkMessage alloc] init];
    }
    
    return self;
}


#pragma mark - Public Methods
- (void)sendMessage:(NSString *)messageBody completionBlock:(CompletionBlock)completionBlock {
    
    NSString *encodedBody = [self encodeMessage:messageBody];
    DAOProfile *daoProfile = [[DAOProfile alloc] init];
    ProfileModel *model = [daoProfile getProfile];
    [self.networkMessage sendEncryptedMessage:encodedBody senderEmail:model.email completionBlock:^(id data, ErrorDataModel *error) {
        completionBlock(data, error);
    }];
}

- (void)sendRecipientEmail:(NSString *)recipientEmail key:(NSString *)key recipientType:(NSString *)recipientType messageId:(NSString *)messageId completionBlock:(CompletionBlock)completionBlock {
    
    [self.networkMessage sendRecipientEmail:recipientEmail key:key recipientType:recipientType messageId:messageId completionBlock:^(id data, ErrorDataModel *error) {
        completionBlock(data, error);
    }];
}

- (void)deleteRecipientEmail:(NSString *)recipientEmail messageId:(NSString *)messageId completionBlock:(CompletionBlock)completionBlock {
    
    [self.networkMessage deleteRecipientEmail:recipientEmail messageId:messageId completionBlock:^(id data, ErrorDataModel *error) {
        completionBlock(data, error);
    }];
}

- (void)sentEmail:(NSString *)senderEmail messageId:(NSString *)messageId messageIdentifier:(NSString *)messageIdentifier completionBlock:(CompletionBlock)completionBlock {
    
    [self.networkMessage sentEmail:senderEmail messageId:messageId messageIdentifier:messageIdentifier completionBlock:^(id data, ErrorDataModel *error) {
        completionBlock(data, error);
    }];
}

- (NSArray *)getInboxMessages {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    // TODO: get only inbox messages
    RLMResults *messages = [[RMModelMessage objectsInRealm:realm where:@"access = %@ AND type = %@", @"GRANTED", @"TO"] sortedResultsUsingProperty:@"position" ascending:NO];
    
    DAOProfile *daoProfile = [[DAOProfile alloc] init];
    ProfileModel *model = [daoProfile getProfile];
    
    NSMutableArray *arrayItems = [@[] mutableCopy];
    for (RMModelMessage *rmMessage in messages) {
//        ModelMessage *modelMessage = [self getMessageWithIdentifier:rmMessage.messageIdentifier fromEmail:nil toEmail:model.email];
//        if (modelMessage) {
//            [arrayItems addObject:modelMessage];
//        }
    }
    
    return arrayItems;
}


- (NSArray *)getSentMessages {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    // TODO: get only sent messages
    DAOProfile *daoProfile = [[DAOProfile alloc] init];
    ProfileModel *modelProfile = [daoProfile getProfile];
    RLMResults *recipients = [[RMModelRecipient objectsInRealm:realm where:@"type = %@ AND access = %@ AND recipient = %@", @"SENDER", @"GRANTED", modelProfile.email] sortedResultsUsingProperty:@"position" ascending:NO];
    NSMutableArray *arrayItems = [@[] mutableCopy];
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
            if (contact.fullName) {
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

- (void)getMessageBodyWithMessageId:(NSString *)messageId completionBlock:(CompletionBlock)completionBlock {
    
    DAOProfile *daoProfile = [[DAOProfile alloc] init];
    ProfileModel *model = [daoProfile getProfile];
    ModelMessage *modelMessage = [self getMessageWithMessageId:messageId];
    if (model) {
        [self.networkMessage getEncryptedMessage:messageId recipientEmail:model.email completionBlock:^(NSDictionary *data, ErrorDataModel *error) {
            NSLog(@"%@", data);
            NSString *encodedMessage = data[@"encrypted_message"];
            NSString *decodedMessage;
            
            //TODO: get public key and decode
            NSString *publicKey = modelMessage.publicKey;
            decodedMessage = [self decodeMessage:encodedMessage key:publicKey];
            
            RLMRealm *realm = [RLMRealm defaultRealm];
            RLMResults *results = [RMModelMessage objectsInRealm:realm where:@"messageId = %@", messageId];
            RMModelMessage *rmMessage = [results firstObject];
            [realm beginWriteTransaction];
            rmMessage.body = decodedMessage;
            [realm commitWriteTransaction];
            
            completionBlock(decodedMessage, error);
        }];
    }
}

- (NSString *)generatePublicKey {
    
    NSString *clientKey;
    NSDate *date = [NSDate date];
    NSTimeInterval timeInterval = [date timeIntervalSince1970];
    clientKey = [NSString stringWithFormat:@"%f", timeInterval];
    
    return clientKey;
}

- (NSString *)encodeMessage:(NSString *)message {
    
    NSString *clientKey = [self generatePublicKey];
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
        RMModelContact *contact = [RMModelContact objectInRealm:realm forPrimaryKey:message.fromEmail];
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
        
        recipients = [RMModelRecipient objectsInRealm:realm where:@"type = %@ AND access = %@ AND messageId = %@", @"SENDER", @"GRANTED", message.messageId];
        RMModelRecipient *recipient = [recipients firstObject];
        
        RLMResults *resultsProfiles = [RMModelProfile allObjectsInRealm:realm];
        RMModelProfile *profile = [resultsProfiles firstObject];
        NSString *imageUrl;
        if ([recipient.recipient isEqualToString:profile.email]) {
            imageUrl = profile.imageUrl;
        }
        else {
            NSString *token = profile.token;
            imageUrl = [NSString stringWithFormat:@"%@?access_token=%@", contact.imageUrl, token];
        }
        modelMessage.imageUrl = imageUrl;
    }
    
    return modelMessage;
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
    RLMResults *messages = [[RMModelMessage allObjectsInRealm:realm] sortedResultsUsingProperty:@"position" ascending:NO];
    for (RMModelMessage *dmailMessage in messages) {
        // get first result
        position = @(dmailMessage.position);
        break;
    }
    
    return position;
}
@end
