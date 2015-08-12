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
static NSString * const kUrlMessagesLabelsWithId = @"%@/messages/%@?fields=labelIds&key=%@";
static NSString * const kUrlMessagesWithQuery = @"%@/messages?q=%@&key=%@";
static NSString * const kUrlMessagesSend = @"%@/messages/send?key=%@";
static NSString * const kUrlMessagesDelete = @"%@/messages/%@?key=%@";
static NSString * const kUrlMessagesArchive = @"%@/messages/%@?key=%@";
static NSString * const kURLMessageDeleteLabels = @"%@/messages/%@/modify";

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

- (void)getMessageLabelsWithMessageId:(NSString *)messageID userId:(NSString *)userID completionBlock:(CompletionBlock)completionBlock {
    
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
    
    [self makeGetRequest:[NSString stringWithFormat:kUrlMessagesLabelsWithId, userID, messageID, kGoogleClientSecret]
              withParams:nil
                 success:successBlock
                 failure:[self constructFailureBlockWithBlock:completionBlock]];
    
    
}

- (void)deleteMessageLabels:(NSArray *)labels messageId:(NSString *)messageID userId:(NSString *)userID completionBlock:(CompletionBlock)completionBlock {
    
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
    
    NSDictionary *params = @{@"removeLabelIds" : labels};
    
    [self makePostRequest:[NSString stringWithFormat:kURLMessageDeleteLabels, userID, messageID]
               withParams:params
                  success:successBlock
                  failure:[self constructFailureBlockWithBlock:completionBlock]];
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
    //    [manager.requestSerializer setValue:@"text/html; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [self makePostRequest:url withParams:parameters success:successBlock failure:[self constructFailureBlockWithBlock:completionBlock]];
    
    
    //    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    //    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultConfigObject delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    //
    ////    NSString * userID = [[[GIDSignIn sharedInstance].currentUser valueForKeyPath:@"userID"] description];
    //    NSString *urlmulr = [NSString stringWithFormat:@"https://www.googleapis.com/gmail/v1/users/%@/messages/send?key=%@&uploadType=multipart",userID, kGoogleClientSecret];
    //    NSURL * url = [NSURL URLWithString:urlmulr];
    //    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
    //    [request setHTTPMethod:@"POST"];
    //    [request addValue:[NSString stringWithFormat:@"OAuth %@", [[[GIDSignIn sharedInstance].currentUser valueForKeyPath:@"authentication.accessToken"] description]] forHTTPHeaderField:@"Authorization"];
    //
    //    NSDictionary *rawDict = @{@"raw" : encodedBody};
    //    NSData *dataRaw = [NSJSONSerialization dataWithJSONObject:rawDict options:NSJSONWritingPrettyPrinted error:nil];
    //    [request setHTTPBody:dataRaw];
    //    [request setValue:@"multipart/related; boundary=foo_bar_baz" forHTTPHeaderField:@"Content-Type"];
    ////    [urlRequest setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    //
    //    NSURLSessionDataTask * dataTask = [defaultSession dataTaskWithRequest:request
    //                                                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    //                                                            NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
    //                                                            NSDictionary *JSONData = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:NULL];
    //                                                            dispatch_async(dispatch_get_main_queue(), ^{
    //                                                                completionBlock(JSONData, nil);
    //                                                            });
    //                                                        }];
    //    [dataTask resume];
    
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
