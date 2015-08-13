//
//  NetworkMessage.m
//  Dmail
//
//  Created by Gevorg Ghukasyan on 6/30/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "NetworkMessage.h"
#import "Constants.h"
#import "DAOProfile.h"
#import "ProfileModel.h"

static NSString * const kUrlSyncMessages = @"mobile/recipients/sync";
static NSString * const kUrlSendMessage = @"api/message";
static NSString * const kUrlSendRecipient = @"api/message/%@/recipient";
static NSString * const kUrlMessageSent = @"mobile/message/sent";
static NSString * const kUrlGetMessage = @"api/message/%@";
static NSString * const kUrlRevokeUser = @"api/message/%@/recipient/%@";
static NSString * const kUrlTemplate = @"view/templateBase64";


@implementation NetworkMessage

- (void)getEncryptedMessage:(NSString *)messageId recipientEmail:(NSString *)recipientEmail completionBlock:(CompletionBlock)completionBlock {
    
    AFSuccessBlock successBlock = ^(AFHTTPRequestOperation *operation, id responseObject) {
        switch (operation.response.statusCode) {
            case 200: {
                if ([responseObject isKindOfClass:[NSDictionary class]]) {
                    //TODO:
                    if (completionBlock) {
                        completionBlock(responseObject, nil);
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
            default: {
                ErrorDataModel *error = [[ErrorDataModel alloc] initWithDictionary:responseObject];
                completionBlock(nil, error);
            }
                break;
        }
    };
    
    DAOProfile *daoProfile = [[DAOProfile alloc] init];
    ProfileModel *model = [daoProfile getProfile];
    [manager.requestSerializer setValue:model.email forHTTPHeaderField:@"identified_email"];
    
    NSString *urlString = [NSString stringWithFormat:kUrlGetMessage, messageId];
    [self makeGetRequest:urlString withParams:nil success:successBlock failure:[self constructFailureBlockWithBlock:completionBlock]];
}

- (void)sendEncryptedMessage:(NSString *)encryptedMessage senderEmail:(NSString *)senderEmail completionBlock:(CompletionBlock)completionBlock {
    
    NSDictionary *parameters = @{@"sender_email" : senderEmail,
                                 @"encrypted_message" : encryptedMessage};
    
    AFSuccessBlock successBlock = ^(AFHTTPRequestOperation *operation, id responseObject) {
        switch (operation.response.statusCode) {
            case 201: {
                if ([responseObject isKindOfClass:[NSDictionary class]]) {
                    //TODO:
                    if (completionBlock) {
                        completionBlock(responseObject, nil);
                    }
                } else {
                    ErrorDataModel *error = [[ErrorDataModel alloc] init];
                    error.statusCode = @400;
                    error.message = kErrorMessageNoServer;
                    completionBlock(nil, error);
                }
            }
                break;
            default: {
                ErrorDataModel *error = [[ErrorDataModel alloc] initWithDictionary:responseObject];
                completionBlock(nil, error);
            }
                break;
        }
    };
    
    DAOProfile *daoProfile = [[DAOProfile alloc] init];
    ProfileModel *model = [daoProfile getProfile];
    [manager.requestSerializer setValue:model.email forHTTPHeaderField:@"identified_email"];
    
    [self makePostRequest:kUrlSendMessage withParams:parameters success:successBlock failure:[self constructFailureBlockWithBlock:completionBlock]];
}

- (void)sendRecipientEmail:(NSString *)recipientEmail key:(NSString *)key recipientType:(NSString *)recipientType messageId:(NSString *)messageId completionBlock:(CompletionBlock)completionBlock {
    
    NSDictionary *parameters = @{@"recipient_type" : recipientType,
                                 @"recipient_email" : recipientEmail};
    
    AFSuccessBlock successBlock = ^(AFHTTPRequestOperation *operation, id responseObject) {
        switch (operation.response.statusCode) {
            case 201: {
                if ([responseObject isKindOfClass:[NSDictionary class]]) {
                    //TODO:
                    if (completionBlock) {
                        completionBlock(responseObject, nil);
                    }
                } else {
                    ErrorDataModel *error = [[ErrorDataModel alloc] init];
                    error.statusCode = @400;
                    error.message = kErrorMessageNoServer;
                    completionBlock(nil, error);
                }
            }
                break;
                
            default: {
                ErrorDataModel *error = [[ErrorDataModel alloc] initWithDictionary:responseObject];
                completionBlock(nil, error);
            }
                break;
        }
    };
    
    DAOProfile *daoProfile = [[DAOProfile alloc] init];
    ProfileModel *model = [daoProfile getProfile];
    [manager.requestSerializer setValue:model.email forHTTPHeaderField:@"identified_email"];
    
    NSString *urlString = [NSString stringWithFormat:kUrlSendRecipient, messageId];
    [self makePostRequest:urlString withParams:parameters success:successBlock failure:[self constructFailureBlockWithBlock:completionBlock]];
}

- (void)deleteRecipientEmail:(NSString *)recipientEmail messageId:(NSString *)messageId completionBlock:(CompletionBlock)completionBlock {
    
    NSDictionary *parameters = @{@"recipient_email" : recipientEmail};
    AFSuccessBlock successBlock = ^(AFHTTPRequestOperation *operation, id responseObject) {
        switch (operation.response.statusCode) {
            case 200: {
                if ([responseObject isKindOfClass:[NSDictionary class]]) {
                    //TODO:
                    if (completionBlock) {
                        completionBlock(responseObject, nil);
                    }
                } else {
                    ErrorDataModel *error = [[ErrorDataModel alloc] init];
                    error.statusCode = @400;
                    error.message = kErrorMessageNoServer;
                    completionBlock(nil, error);
                }
            }
                break;
                
            default: {
                ErrorDataModel *error = [[ErrorDataModel alloc] initWithDictionary:responseObject];
                completionBlock(nil, error);
            }
                break;
        }
    };
    
    DAOProfile *daoProfile = [[DAOProfile alloc] init];
    ProfileModel *model = [daoProfile getProfile];
    [manager.requestSerializer setValue:model.email forHTTPHeaderField:@"identified_email"];
    
    NSString *urlString = [NSString stringWithFormat:kUrlSendRecipient, messageId];
    [self makeDeleteRequest:urlString withParams:parameters success:successBlock failure:[self constructFailureBlockWithBlock:completionBlock]];
}

- (void)sentEmail:(NSString *)senderEmail messageId:(NSString *)messageId messageIdentifier:(NSString *)messageIdentifier completionBlock:(CompletionBlock)completionBlock {
    
    NSDictionary *parameters = @{@"message_id" : messageId,
                                 @"message_identifier" : messageIdentifier,
                                 @"sender_email" : senderEmail};
    
    AFSuccessBlock successBlock = ^(AFHTTPRequestOperation *operation, id responseObject) {
        switch (operation.response.statusCode) {
            case 200: {
                if ([responseObject isKindOfClass:[NSDictionary class]]) {
                    //TODO:
                    if (completionBlock) {
                        completionBlock(responseObject, nil);
                    }
                } else {
                    ErrorDataModel *error = [[ErrorDataModel alloc] init];
                    error.statusCode = @400;
                    error.message = kErrorMessageNoServer;
                    completionBlock(nil, error);
                }
            }
                break;
                
            default: {
                ErrorDataModel *error = [[ErrorDataModel alloc] initWithDictionary:responseObject];
                completionBlock(nil, error);
            }
                break;
        }
    };
    
    DAOProfile *daoProfile = [[DAOProfile alloc] init];
    ProfileModel *model = [daoProfile getProfile];
    [manager.requestSerializer setValue:model.email forHTTPHeaderField:@"identified_email"];
    
    [self makePostRequest:kUrlMessageSent withParams:parameters success:successBlock failure:[self constructFailureBlockWithBlock:completionBlock]];
}

- (void)syncMessagesForEmail:(NSString *)recipientEmail position:(NSNumber *)position count:(NSNumber *)count completionBlock:(CompletionBlock)completionBlock {
    
    NSDictionary *parameters = @{@"recipient_email" : recipientEmail,
                                 @"position" : position,
                                 @"count" : count,
                                 @"bottom" : @(NO)};
    AFSuccessBlock successBlock = ^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"syncMessages JSON: %@", responseObject);
        switch (operation.response.statusCode) {
            case 200: {
                if ([responseObject isKindOfClass:[NSDictionary class]]) {
                    //TODO:
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (completionBlock) {
                            completionBlock(responseObject, nil);
                        }
                    });
                    
                } else {
                    ErrorDataModel *error = [[ErrorDataModel alloc] init];
                    error.statusCode = @400;
                    error.message = kErrorMessageNoServer;
                    completionBlock(nil, error);
                }
            }
                break;
                
            default: {
                ErrorDataModel *error = [[ErrorDataModel alloc] initWithDictionary:responseObject];
                completionBlock(nil, error);
            }
                break;
        }
    };
    
    DAOProfile *daoProfile = [[DAOProfile alloc] init];
    ProfileModel *model = [daoProfile getProfile];
    [manager.requestSerializer setValue:model.email forHTTPHeaderField:@"identified_email"];
    
    [self makePostRequest:kUrlSyncMessages withParams:parameters success:successBlock failure:[self constructFailureBlockWithBlock:completionBlock]];
}

- (void)revokeUserWithMessageId:(NSString *)messageId email:(NSString *)email completionBlock:(CompletionBlock)completionBlock {

    AFSuccessBlock successBlock = ^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"syncMessages JSON: %@", responseObject);
        switch (operation.response.statusCode) {
            case 200:
            case 201: {
                completionBlock(@(YES), nil);
            }
                break;
                
            default: {
                ErrorDataModel *error = [[ErrorDataModel alloc] initWithDictionary:responseObject];
                completionBlock(nil, error);
            }
                break;
        }
    };
    
    DAOProfile *daoProfile = [[DAOProfile alloc] init];
    ProfileModel *model = [daoProfile getProfile];
    [manager.requestSerializer setValue:model.email forHTTPHeaderField:@"identified_email"];
    
    NSString *urlString = [NSString stringWithFormat:kUrlRevokeUser, messageId, email];
    [self makeDeleteRequest:urlString withParams:nil success:successBlock failure:[self constructFailureBlockWithBlock:completionBlock]];
}

- (void)getTemplateWithCompletionBlock:(CompletionBlock)completionBlock {
    
    AFSuccessBlock successBlock = ^(AFHTTPRequestOperation *operation, id responseObject) {
        
        switch (operation.response.statusCode) {
            case 200: { 
                if ([responseObject isKindOfClass:[NSDictionary class]]) {
                    if (completionBlock) {
                        completionBlock(responseObject, nil);
                    }
                    else {
                        ErrorDataModel *error = [[ErrorDataModel alloc] initWithDictionary:responseObject];
                        completionBlock(nil, error);
                    }
                }
                else {
                    ErrorDataModel *error = [[ErrorDataModel alloc] init];
                    error.statusCode = @400;
                    error.message = kErrorMessageNoServer;
                    completionBlock(nil, error);
                }
            }
                break;
            default: {
                ErrorDataModel *error = [[ErrorDataModel alloc] initWithDictionary:responseObject];
                completionBlock(nil, error);
            }
                break;
        }
    };
    
    DAOProfile *daoProfile = [[DAOProfile alloc] init];
    ProfileModel *model = [daoProfile getProfile];
    [manager.requestSerializer setValue:model.email forHTTPHeaderField:@"identified_email"];
    
    [self makePostRequest:kUrlTemplate withParams:nil success:successBlock failure:[self constructFailureBlockWithBlock:completionBlock]];
}

@end
