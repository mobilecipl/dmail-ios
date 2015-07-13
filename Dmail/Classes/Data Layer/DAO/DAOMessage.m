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

// view model
#import "VMInboxMessageItem.h"

// Realm
#import <Realm/Realm.h>
#import "RMModelMessage.h"
#import "RMModelMessage.h"
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
        ModelMessage *modelMessage = [self getMessageWithIdentifier:rmMessage.messageIdentifier fromEmail:nil toEmail:model.email];
        if (modelMessage) {
            [arrayItems addObject:modelMessage];
        }
    }
    
    return arrayItems;
}


- (NSArray *)getSentMessages {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    // TODO: get only sent messages
    RLMResults *messages = [[RMModelMessage objectsInRealm:realm where:@"type = %@", @"SENDER"] sortedResultsUsingProperty:@"position" ascending:NO];
    DAOProfile *daoProfile = [[DAOProfile alloc] init];
    ProfileModel *model = [daoProfile getProfile];
    NSMutableArray *arrayItems = [@[] mutableCopy];
    for (RMModelMessage *rmMessage in messages) {
        ModelMessage *modelMessage = [self getMessageWithIdentifier:rmMessage.messageIdentifier fromEmail:model.email toEmail:nil];
        if (modelMessage) {
            [arrayItems addObject:modelMessage];
        }
    }
    
    return arrayItems;
}

- (void)getMessageBodyWithIdentifier:(NSString *)messageIdentifier completionBlock:(CompletionBlock)completionBlock {
    
    DAOProfile *daoProfile = [[DAOProfile alloc] init];
    ProfileModel *model = [daoProfile getProfile];
    ModelMessage *modelMessage = [self getMessageWithIdentifier:messageIdentifier];
    if (model) {
        [self.networkMessage getEncryptedMessage:modelMessage.messageId
                                  recipientEmail:model.email
                                 completionBlock:^(NSDictionary *data, ErrorDataModel *error) {
                                     NSLog(@"%@", data);
                                     NSString *encodedMessage = data[@"encrypted_message"];
                                     NSString *decodedMessage;
                                     
                                     //TODO: get public key and decode
                                     NSString *publicKey = modelMessage.publicKey;
                                     decodedMessage = [self decodeMessage:encodedMessage key:publicKey];
                                     
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

- (ModelMessage *)getMessageWithIdentifier:(NSString *)identifier {
    
    return [self getMessageWithIdentifier:identifier fromEmail:nil toEmail:nil];
}

- (ModelMessage *)getMessageWithIdentifier:(NSString *)identifier fromEmail:(NSString *)fromEmail toEmail:(NSString *)toEmail {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    NSPredicate *predicate;
    if (fromEmail) {
        predicate = [NSPredicate predicateWithFormat:@"messageIdentifier = %@ AND fromEmail = %@", identifier, fromEmail];
    }  else if(toEmail) {
        predicate = [NSPredicate predicateWithFormat:@"messageIdentifier = %@ AND to CONTAINS[c] %@", identifier, toEmail];
    } else {
        predicate = [NSPredicate predicateWithFormat:@"messageIdentifier = %@", identifier];
    }
    
    RLMResults *resultsGmailMessages = [RMModelMessage objectsInRealm:realm withPredicate:predicate];
    RMModelMessage *gmailMessage = [resultsGmailMessages firstObject];
    
    ModelMessage *modelMessage = nil;
    
    if (gmailMessage) {
        RLMResults *resultsDmailMessages = [RMModelMessage objectsInRealm:realm where:@"messageIdentifier = %@", identifier];
        RMModelMessage *dmailMessage = [resultsDmailMessages firstObject];
        
        RMModelContact *contact = [RMModelContact objectInRealm:realm forPrimaryKey:gmailMessage.fromEmail];
        
        RLMResults *resultsProfiles = [RMModelProfile allObjectsInRealm:realm];
        RMModelProfile *profile = [resultsProfiles firstObject];
        
        modelMessage = [[ModelMessage alloc] init];
        modelMessage.messageIdentifier = identifier;
        modelMessage.internalDate = gmailMessage.internalDate;
        modelMessage.messageId = dmailMessage.messageId;
        modelMessage.gmailId = dmailMessage.gmailId;
        modelMessage.type = dmailMessage.type;
        modelMessage.read = gmailMessage.read;
        modelMessage.to = gmailMessage.to;
        //        self.cc = gmailMessage.cc;
        //        self.bcc = gmailMessage.bcc;
        
        modelMessage.subject = gmailMessage.subject;
        modelMessage.fromName = gmailMessage.fromName;
        modelMessage.fromEmail = gmailMessage.fromEmail;
        
        NSString *imageUrl;
        if(profile.email && [modelMessage.fromEmail isEqualToString:profile.email]) {
            imageUrl = profile.imageUrl;
        }
        else if (contact.imageUrl) {
            NSString *token = profile.token;
            imageUrl = [NSString stringWithFormat:@"%@?access_token=%@", contact.imageUrl, token];
        }
        
        modelMessage.imageUrl = imageUrl;
        
        RMModelMessage *rmModelMessage = [RMModelMessage objectInRealm:realm forPrimaryKey:identifier];
        modelMessage.publicKey = rmModelMessage.publicKey;
    }
    
    
    return modelMessage;
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
    RLMResults *messages = [[RMModelMessage objectsInRealm:realm where:@"gmailId != ''"] sortedResultsUsingProperty:@"position" ascending:NO];
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
