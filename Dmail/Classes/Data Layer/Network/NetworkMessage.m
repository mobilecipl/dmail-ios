//
//  NetworkMessage.m
//  Dmail
//
//  Created by Gevorg Ghukasyan on 6/30/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "NetworkMessage.h"
#import "Constants.h"

static NSString * const kUrlSyncMessages = @"mobile/recipients/sync";
static NSString * const kUrlSendMessage = @"api/message";
static NSString * const kUrlSendRecipient = @"api/message/%@/recipient";
static NSString * const kUrlMessageSent = @"mobile/message/sent";
static NSString * const kUrlGetMessage = @"api/message/%@/recipient/%@";


@implementation NetworkMessage

- (void)sendEncryptedMessage:(NSString *)encryptedMessage
                 senderEmail:(NSString *)senderEmail
             completionBlock:(CompletionBlock)completionBlock {
    
    NSDictionary *parameters = @{@"sender_email" : senderEmail,
                                 @"encrypted_message" : encryptedMessage};
    
    AFSuccessBlock successBlock = ^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSLog(@"sendEncryptedMessage JSON: %@", responseObject);
        switch (operation.response.statusCode) {
            case 201: //Success Response
            {
                if ([responseObject isKindOfClass:[NSDictionary class]]) {
                    
                    //TODO:
                    if (!responseObject[@"errorCode"] || (responseObject[@"errorCode"] && [responseObject[@"errorCode"] integerValue] == 0)) {
                        
                        if (completionBlock) {
                            completionBlock(responseObject, nil);
                        }
                    }
                    else {
                        
                        ErrorDataModel *error = [[ErrorDataModel alloc] initWithDictionary:responseObject];
                        completionBlock(nil, error);
                    }
                } else {
                    
                    ErrorDataModel *error = [[ErrorDataModel alloc] init];
                    error.statusCode = @400;
                    error.message = kErrorMessageNoServer;
                    completionBlock(nil, error);
                }
            }
                break;
            default:
            {
                ErrorDataModel *error = [[ErrorDataModel alloc] initWithDictionary:responseObject];
                completionBlock(nil, error);
            }
                break;
        }
    };
    
    [self makePostRequest:kUrlSendMessage
               withParams:parameters
                  success:successBlock
                  failure:[self constructFailureBlockWithBlock:completionBlock]];
}

- (void)sendRecipientEmail:(NSString *)recipientEmail
                       key:(NSString *)key
             recipientType:(NSString *)recipientType
                 messageId:(NSString *)messageId
           completionBlock:(CompletionBlock)completionBlock {
    
    NSDictionary *parameters = @{@"key" : key,
                                 @"recipient_type" : recipientType,
                                 @"recipient_email" : recipientEmail};
    
    AFSuccessBlock successBlock = ^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSLog(@"sendRecipientEmail JSON: %@", responseObject);
        switch (operation.response.statusCode) {
            case 201: //Success Response
            {
                if ([responseObject isKindOfClass:[NSDictionary class]]) {
                    
                    //TODO:
                    if (!responseObject[@"errorCode"] || (responseObject[@"errorCode"] && [responseObject[@"errorCode"] integerValue] == 0)) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (completionBlock) {
                                completionBlock(responseObject, nil);
                            }
                        });
                    }
                    else {
                        ErrorDataModel *error = [[ErrorDataModel alloc] initWithDictionary:responseObject];
                        completionBlock(nil, error);
                    }
                } else {
                    ErrorDataModel *error = [[ErrorDataModel alloc] init];
                    error.statusCode = @400;
                    error.message = kErrorMessageNoServer;
                    completionBlock(nil, error);
                }
            }
                break;
                
            default:
            {
                ErrorDataModel *error = [[ErrorDataModel alloc] initWithDictionary:responseObject];
                completionBlock(nil, error);
            }
                break;
        }
    };
    
    [self makePostRequest:[NSString stringWithFormat:kUrlSendRecipient, messageId]
               withParams:parameters
                  success:successBlock
                  failure:[self constructFailureBlockWithBlock:completionBlock]];
}

- (void)deleteRecipientEmail:(NSString *)recipientEmail
                   messageId:(NSString *)messageId
             completionBlock:(CompletionBlock)completionBlock {
    
    NSDictionary *parameters = @{@"recipient_email" : recipientEmail};
    
    AFSuccessBlock successBlock = ^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSLog(@"deleteRecipientEmail JSON: %@", responseObject);
        switch (operation.response.statusCode) {
            case 200: //Success Response
            {
                if ([responseObject isKindOfClass:[NSDictionary class]]) {
                    
                    //TODO:
                    if (!responseObject[@"errorCode"] || (responseObject[@"errorCode"] && [responseObject[@"errorCode"] integerValue] == 0)) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (completionBlock) {
                                completionBlock(responseObject, nil);
                            }
                        });
                    }
                    else {
                        ErrorDataModel *error = [[ErrorDataModel alloc] initWithDictionary:responseObject];
                        completionBlock(nil, error);
                    }
                } else {
                    ErrorDataModel *error = [[ErrorDataModel alloc] init];
                    error.statusCode = @400;
                    error.message = kErrorMessageNoServer;
                    completionBlock(nil, error);
                }
            }
                break;
                
            default:
            {
                ErrorDataModel *error = [[ErrorDataModel alloc] initWithDictionary:responseObject];
                completionBlock(nil, error);
            }
                break;
        }
    };
    
    [self makeDeleteRequest:[NSString stringWithFormat:kUrlSendRecipient, messageId]
                 withParams:parameters
                    success:successBlock
                    failure:[self constructFailureBlockWithBlock:completionBlock]];
}

- (void)sentEmail:(NSString *)senderEmail
        messageId:(NSString *)messageId
messageIdentifier:(NSString *)messageIdentifier
  completionBlock:(CompletionBlock)completionBlock {
    
    NSDictionary *parameters = @{@"message_id" : messageId,
                                 @"message_identifier" : messageIdentifier,
                                 @"sender_email" : senderEmail};
    
    AFSuccessBlock successBlock = ^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSLog(@"EmailAlredySent JSON: %@", responseObject);
        switch (operation.response.statusCode) {
            case 200: //Success Response
            {
                if ([responseObject isKindOfClass:[NSDictionary class]]) {
                    
                    //TODO:
                    if (!responseObject[@"errorCode"] || (responseObject[@"errorCode"] && [responseObject[@"errorCode"] integerValue] == 0)) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (completionBlock) {
                                completionBlock(responseObject, nil);
                            }
                        });
                    }
                    else {
                        ErrorDataModel *error = [[ErrorDataModel alloc] initWithDictionary:responseObject];
                        completionBlock(nil, error);
                    }
                } else {
                    ErrorDataModel *error = [[ErrorDataModel alloc] init];
                    error.statusCode = @400;
                    error.message = kErrorMessageNoServer;
                    completionBlock(nil, error);
                }
            }
                break;
                
            default:
            {
                ErrorDataModel *error = [[ErrorDataModel alloc] initWithDictionary:responseObject];
                completionBlock(nil, error);
            }
                break;
        }
    };
    
    [self makePostRequest:kUrlMessageSent
               withParams:parameters
                  success:successBlock
                  failure:[self constructFailureBlockWithBlock:completionBlock]];
}

- (void)syncMessagesForEmail:(NSString *)recipientEmail
                    position:(NSString *)position
                       count:(NSString *)count
             completionBlock:(CompletionBlock)completionBlock {
    
    NSDictionary *parameters = @{@"recipient_email" : recipientEmail,
                                 @"position" : position,
                                 @"count" : count};
    
    AFSuccessBlock successBlock = ^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSLog(@"syncMessages JSON: %@", responseObject);
        switch (operation.response.statusCode) {
            case 200: //Success Response
            {
                if ([responseObject isKindOfClass:[NSDictionary class]]) {
                    
                    //TODO:
                    if (!responseObject[@"errorCode"] || (responseObject[@"errorCode"] && [responseObject[@"errorCode"] integerValue] == 0)) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (completionBlock) {
                                completionBlock(responseObject, nil);
                            }
                        });
                    }
                    else {
                        ErrorDataModel *error = [[ErrorDataModel alloc] initWithDictionary:responseObject];
                        completionBlock(nil, error);
                    }
                } else {
                    ErrorDataModel *error = [[ErrorDataModel alloc] init];
                    error.statusCode = @400;
                    error.message = kErrorMessageNoServer;
                    completionBlock(nil, error);
                }
            }
                break;
                
            default:
            {
                ErrorDataModel *error = [[ErrorDataModel alloc] initWithDictionary:responseObject];
                completionBlock(nil, error);
            }
                break;
        }
    };
    
    [self makePostRequest:kUrlSyncMessages
               withParams:parameters
                  success:successBlock
                  failure:[self constructFailureBlockWithBlock:completionBlock]];
}

- (void)getEncryptedMessage:(NSString *)messageId
             recipientEmail:(NSString *)recipientEmail
            completionBlock:(CompletionBlock)completionBlock {
    
    //    NSDictionary *parameters = @{@"sender_email" : senderEmail,
    //                                 @"encrypted_message" : encryptedMessage};
    
    AFSuccessBlock successBlock = ^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSLog(@"getEncryptedMessage JSON: %@", responseObject);
        switch (operation.response.statusCode) {
            case 201: //Success Response
            {
                if ([responseObject isKindOfClass:[NSDictionary class]]) {
                    
                    //TODO:
                    if (!responseObject[@"errorCode"] || (responseObject[@"errorCode"] && [responseObject[@"errorCode"] integerValue] == 0)) {
                        
                        if (completionBlock) {
                            completionBlock(responseObject, nil);
                        }
                    }
                    else {
                        
                        ErrorDataModel *error = [[ErrorDataModel alloc] initWithDictionary:responseObject];
                        completionBlock(nil, error);
                    }
                } else {
                    
                    ErrorDataModel *error = [[ErrorDataModel alloc] init];
                    error.statusCode = @400;
                    error.message = kErrorMessageNoServer;
                    completionBlock(nil, error);
                }
            }
                break;
            default:
            {
                ErrorDataModel *error = [[ErrorDataModel alloc] initWithDictionary:responseObject];
                completionBlock(nil, error);
            }
                break;
        }
    };
    
    [self makeGetRequest:[NSString stringWithFormat:kUrlGetMessage, messageId, recipientEmail]
              withParams:nil
                 success:successBlock
                 failure:[self constructFailureBlockWithBlock:completionBlock]];
}

@end