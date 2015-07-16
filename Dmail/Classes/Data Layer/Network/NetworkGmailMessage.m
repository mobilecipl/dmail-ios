//
//  NetworkGmailMessage.m
//  Dmail
//
//  Created by Gevorg Ghukasyan on 7/7/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "NetworkGmailMessage.h"

#import <GoogleSignIn.h>

static NSString * const kUrlMessagesWithId = @"%@/messages/%@?fields=id,internalDate,snippet,labelIds,payload&key=%@";
static NSString * const kUrlMessagesWithQuery = @"%@/messages?q=%@&key=%@";
static NSString * const kUrlMessagesSend = @"%@/messages/send?key=%@";
static NSString * const kUrlMessagesDelete = @"%@/messages/%@?key=%@";

//https://www.googleapis.com/gmail/v1/users/%@/messages/%@?key=%@

@implementation NetworkGmailMessage

- (instancetype)init {
    
    self = [super initWithUrl:@"https://www.googleapis.com/gmail/v1/users"];
    if (self) {
        
    }
    return self;
}

- (void)getMessageIdWithUniqueId:(NSString *)uniqueId userId:(NSString *)userID completionBlock:(CompletionBlock)completionBlock {
    
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"OAuth %@", [[[GIDSignIn sharedInstance].currentUser valueForKeyPath:@"authentication.accessToken"] description]] forHTTPHeaderField:@"Authorization"];
    AFSuccessBlock successBlock = ^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"getWithUniqueIdResponse JSON: %@", responseObject);
        switch (operation.response.statusCode) {
            case 200: {
                
                //Success Response
                if ([responseObject isKindOfClass:[NSDictionary class]]) {

                    if (completionBlock) {
                        completionBlock(responseObject, nil);
                    }
                } else {
                    ErrorDataModel *error = [[ErrorDataModel alloc] init];
                    error.statusCode = @400;
                    error.message = kErrorMessageNoServer;
                    if (completionBlock) {
                        completionBlock(nil, error);
                    }
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
    
    NSString *requestUrl = [NSString stringWithFormat:kUrlMessagesWithQuery, userID, queryString, kGoogleClientSecret];
    
    [self makeGetRequest:requestUrl
              withParams:nil
                 success:successBlock
                 failure:[self constructFailureBlockWithBlock:completionBlock]];
    
}

- (void)getMessageWithMessageId:(NSString *)messageId userId:(NSString *)userID completionBlock:(CompletionBlock)completionBlock {
    
    AFSuccessBlock successBlock = ^(AFHTTPRequestOperation *operation, id responseObject) {
        switch (operation.response.statusCode) {
            case 200: { //Success Response
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
    
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"OAuth %@", [[[GIDSignIn sharedInstance].currentUser valueForKeyPath:@"authentication.accessToken"] description]] forHTTPHeaderField:@"Authorization"];
    [self makeGetRequest:[NSString stringWithFormat:kUrlMessagesWithId, userID, messageId, kGoogleClientSecret] withParams:nil success:successBlock failure:[self constructFailureBlockWithBlock:completionBlock]];
}

- (void)sendWithEncodedBody:(NSString *)encodedBody userId:(NSString *)userID completionBlock:(CompletionBlock)completionBlock {

    AFSuccessBlock successBlock = ^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"sendResponse JSON: %@", responseObject);
        switch (operation.response.statusCode) {
            case 200:
            case 201: { //Success Response
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
    
    NSDictionary *parameters = @{@"raw" : encodedBody};
    NSString *url = [NSString stringWithFormat:kUrlMessagesSend, userID, kGoogleClientSecret];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"OAuth %@", [[[GIDSignIn sharedInstance].currentUser valueForKeyPath:@"authentication.accessToken"] description]] forHTTPHeaderField:@"Authorization"];
    [self makePostRequest:url withParams:parameters success:successBlock failure:[self constructFailureBlockWithBlock:completionBlock]];

}

- (void)deleteWithGmailId:(NSString *)gmailId userId:(NSString *)userID completionBlock:(CompletionBlock)completionBlock {
    
    AFSuccessBlock successBlock = ^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"operation.response.statusCode: %ld", (long)operation.response.statusCode);
        switch (operation.response.statusCode) {
            case 200:
            case 204: { //Success Response
                completionBlock(@(YES), nil);
            }
                break;
            default: {
                completionBlock(@(NO), nil);
            }
                break;
        }
    };
    
    NSString *urlString = [NSString stringWithFormat:kUrlMessagesDelete, userID, gmailId, kGoogleClientSecret];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"OAuth %@", [[[GIDSignIn sharedInstance].currentUser valueForKeyPath:@"authentication.accessToken"] description]] forHTTPHeaderField:@"Authorization"];
    [self makeDeleteRequest:urlString withParams:nil success:successBlock failure:[self constructFailureBlockWithBlock:completionBlock]];
}

@end
