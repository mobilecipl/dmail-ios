//
//  NetworkGmailMessage.m
//  Dmail
//
//  Created by Gevorg Ghukasyan on 7/7/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "NetworkGmailMessage.h"

#import "Configurations.h"

static NSString * const kUrlMessagesWithId = @"%@/messages/%@?key=%@";
static NSString * const kUrlMessagesWithQuery = @"%@/messages?q=%@&key=%@";
static NSString * const kUrlMessagesSend = @"%@/messages/send?key=%@";

@implementation NetworkGmailMessage

- (instancetype)init {
    
    self = [super initForGmailMessage];
    return self;
}

- (void)getMessageIdWithUniqueId:(NSString *)uniqueId
                          userId:(NSString *)userID
                 completionBlock:(CompletionBlock)completionBlock {
    
    AFSuccessBlock successBlock = ^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"getWithUniqueIdResponse JSON: %@", responseObject);
        switch (operation.response.statusCode) {
            case 201: { //Success Response
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
            default: {
                ErrorDataModel *error = [[ErrorDataModel alloc] initWithDictionary:responseObject];
                completionBlock(nil, error);
            }
                break;
        }
    };
    
    NSString *queryString = [NSString stringWithFormat:@"rfc822msgid:%@",uniqueId];
    queryString = [queryString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    queryString = [queryString stringByReplacingOccurrencesOfString:@"@" withString:@"%40"];
    queryString = [queryString stringByReplacingOccurrencesOfString:@":" withString:@"%3A"];
    queryString = [queryString stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    queryString = [queryString stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"];
    
    [self makeGetRequest:[NSString stringWithFormat:kUrlMessagesWithQuery, userID, queryString, kGoogleClientSecret]
              withParams:nil
                 success:successBlock
                 failure:[self constructFailureBlockWithBlock:completionBlock]];
    
}

- (void)getMessageWithMessageId:(NSString *)messageId
                         userId:(NSString *)userID
                completionBlock:(CompletionBlock)completionBlock {
    
    AFSuccessBlock successBlock = ^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"getWithIdResponse JSON: %@", responseObject);
        switch (operation.response.statusCode) {
            case 201: { //Success Response
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
            default: {
                ErrorDataModel *error = [[ErrorDataModel alloc] initWithDictionary:responseObject];
                completionBlock(nil, error);
            }
                break;
        }
    };
    
    [self makeGetRequest:[NSString stringWithFormat:kUrlMessagesWithId, userID, messageId, kGoogleClientSecret]
              withParams:nil
                 success:successBlock
                 failure:[self constructFailureBlockWithBlock:completionBlock]];
}

- (void)sendWithEncodedBody:(NSString *)encodedBody
                     userId:(NSString *)userID
            completionBlock:(CompletionBlock)completionBlock {

    AFSuccessBlock successBlock = ^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"sendResponse JSON: %@", responseObject);
        switch (operation.response.statusCode) {
            case 201: { //Success Response
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
            default: {
                ErrorDataModel *error = [[ErrorDataModel alloc] initWithDictionary:responseObject];
                completionBlock(nil, error);
            }
                break;
        }
    };
    
    NSDictionary *parameters = @{@"raw" : encodedBody};
    
    [self makePostRequest:[NSString stringWithFormat:kUrlMessagesSend, userID, kGoogleClientSecret]
               withParams:parameters
                  success:successBlock
                  failure:[self constructFailureBlockWithBlock:completionBlock]];

}

- (void)deleteWithGmailId:(NSString *)gmailId
                   userId:(NSString *)userID
          completionBlock:(CompletionBlock)completionBlock {
    
    AFSuccessBlock successBlock = ^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"deleteResponse JSON: %@", responseObject);
        switch (operation.response.statusCode) {
            case 204: { //If successful, this method returns an empty response body.
                if (completionBlock) {
                    completionBlock(responseObject, nil);
                }
                break;
            }
//            case 201: { //Success Response
//                if ([responseObject isKindOfClass:[NSDictionary class]]) {
//                    //TODO:
//                    if (!responseObject[@"errorCode"] || (responseObject[@"errorCode"] && [responseObject[@"errorCode"] integerValue] == 0)) {
//                        if (completionBlock) {
//                            completionBlock(responseObject, nil);
//                        }
//                    }
//                    else {
//                        ErrorDataModel *error = [[ErrorDataModel alloc] initWithDictionary:responseObject];
//                        completionBlock(nil, error);
//                    }
//                } else {
//                    ErrorDataModel *error = [[ErrorDataModel alloc] init];
//                    error.statusCode = @400;
//                    error.message = kErrorMessageNoServer;
//                    completionBlock(nil, error);
//                }
//            }
//                break;
//            default: {
//                ErrorDataModel *error = [[ErrorDataModel alloc] initWithDictionary:responseObject];
//                completionBlock(nil, error);
//            }
//                break;
        }
    };
    
    [self makeDeleteRequest:[NSString stringWithFormat:kUrlMessagesWithId, userID, gmailId, kGoogleClientSecret]
                 withParams:nil
                    success:successBlock
                    failure:[self constructFailureBlockWithBlock:completionBlock]];
    
    
}

@end