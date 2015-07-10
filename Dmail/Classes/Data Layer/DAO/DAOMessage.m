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
#import "RMModelDmailMessage.h"
#import "RMModelGmailMessage.h"
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
- (void)sendEncryptedMessage:(NSString *)encryptedMessage senderEmail:(NSString *)senderEmail completionBlock:(CompletionBlock)completionBlock {
    
    [self.networkMessage sendEncryptedMessage:encryptedMessage senderEmail:senderEmail completionBlock:^(id data, ErrorDataModel *error) {
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
    RLMResults *messages = [RMModelMessage allObjectsInRealm:realm];
    
    NSMutableArray *arrayItems = [@[] mutableCopy];
    
    for (RMModelMessage *rmMessage in messages) {
        
        ModelMessage *modelMessage = [self getMessageWithIdentifier:rmMessage.messageIdentifier];
        if (modelMessage) {
            [arrayItems addObject:modelMessage];
        }
    }
    
    return arrayItems;
}


- (NSArray *)getSentMessages {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    // TODO: get only sent messages
    RLMResults *messages = [RMModelMessage allObjectsInRealm:realm];
    
    NSMutableArray *arrayItems = [@[] mutableCopy];
    
    for (RMModelMessage *rmMessage in messages) {
        
        ModelMessage *modelMessage = [self getMessageWithIdentifier:rmMessage.messageIdentifier];
        if (modelMessage) {
            [arrayItems addObject:modelMessage];
        }
    }
    
    return arrayItems;
}

- (void)getMessageBodyWithIdentifier:(NSString *)messageIdentifier
                           completionBlock:(CompletionBlock)completionBlock {
    
    DAOProfile *daoProfile = [[DAOProfile alloc] init];
    ProfileModel *model = [daoProfile getProfile];
    
    ModelMessage *modelMessage = [self getMessageWithIdentifier:messageIdentifier];
    if (model) {
        
        [self.networkMessage getEncryptedMessage:modelMessage.dmailId
                                  recipientEmail:model.email
                                 completionBlock:^(NSDictionary *data, ErrorDataModel *error) {
                                     
                                     
                                     NSLog(@"%@", data);
                                     NSString *encodedMessage = data[@"encrypted_message"];
                                     NSString *decodedMessage;
                                     
                                     //TODO: get public key and decode
                                     NSString *publicKey = @"";
                                     decodedMessage = [self decodeMessage:encodedMessage key:publicKey];

                                     completionBlock(encodedMessage, error);
                                 }];
    }
}

- (NSString *)decodeMessage:(NSString *)encodedMessage key:(NSString *)publicKey{
    
    NSString *decryptedText = [encodedMessage AES256DecryptWithKey:publicKey];
    return decryptedText;
}


- (ModelMessage *)getMessageWithIdentifier:(NSString *)identifier {
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    RLMResults *resultsGmailMessages = [RMModelGmailMessage objectsInRealm:realm where:@"messageIdentifier = %@", identifier];
    RMModelGmailMessage *gmailMessage = [resultsGmailMessages firstObject];
    
    RLMResults *resultsDmailMessages = [RMModelDmailMessage objectsInRealm:realm where:@"messageIdentifier = %@", identifier];
    RMModelDmailMessage *dmailMessage = [resultsDmailMessages firstObject];
    
    RMModelContact *contact = [RMModelContact objectInRealm:realm forPrimaryKey:gmailMessage.fromEmail];
    RMModelProfile *profile = [RMModelProfile objectInRealm:realm forPrimaryKey:gmailMessage.fromEmail];
    
    ModelMessage *modelMessage = [[ModelMessage alloc] init];
    modelMessage.messageIdentifier = identifier;
    modelMessage.internalDate = gmailMessage.internalDate;
    modelMessage.dmailId = dmailMessage.dmailId;
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
        imageUrl = [NSString stringWithFormat:@"%@?access_token=%@",contact.imageUrl,token];
    }
    
    modelMessage.imageUrl = imageUrl;
    
    return modelMessage;
}


- (NSString *)getLastGmailUniqueId {
    
    NSString *gmailUniqueId = nil;
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    NSPredicate *predicate =  [NSPredicate predicateWithFormat:@"access = %@ AND type = %@", @"GRANTED", @"SENDER"];
    RLMResults *messages = [[RMModelDmailMessage objectsInRealm:realm withPredicate:predicate]
                            sortedResultsUsingProperty:@"position" ascending:NO];
    
    for (RMModelDmailMessage *dmailMessage in messages) {
        
        // get first result
        gmailUniqueId = dmailMessage.messageIdentifier;
        break;
    }

    
    return gmailUniqueId;
}

- (NSString *)getLastGmailMessageId {
    
    NSString *gmailMessageId = nil;
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    RLMResults *messages = [[RMModelDmailMessage objectsInRealm:realm where:@"gmailId != ''"]
                            sortedResultsUsingProperty:@"position" ascending:NO];
    
    for (RMModelDmailMessage *dmailMessage in messages) {
        
        // get first result
        gmailMessageId = dmailMessage.gmailId;
        break;
    }
    
    
    return gmailMessageId;
}
@end
