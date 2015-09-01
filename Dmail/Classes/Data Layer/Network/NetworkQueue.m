//
//  NetworkQueue.m
//  Dmail
//
//  Created by Karen Petrosyan on 8/31/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "NetworkQueue.h"

@implementation NetworkQueue

static NSString * const kUrlGetQueu = @"mobile/checkQueue";
static NSString * const kUrlSendToken = @"mobile/updateToken";

- (void)getQueueWithUserId:(NSString *)deviceId completionBlock:(CompletionBlock)completionBlock {
    
    NSDictionary *parameters = @{@"device_id" : deviceId};
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
    
    NSString *urlString = [NSString stringWithFormat:kUrlGetQueu];
    [self makeDeleteRequest:urlString withParams:parameters success:successBlock failure:[self constructFailureBlockWithBlock:completionBlock]];
}

- (void)sendTokenWithDeviceId:(NSString *)deviceId token:(NSString *)token completionBlock:(CompletionBlock)completionBlock {
    
    NSDictionary *parameters = @{@"device_id" : deviceId,
                                 @"device_token" : token};
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
    
    NSString *urlString = [NSString stringWithFormat:kUrlSendToken];
    [self makeDeleteRequest:urlString withParams:parameters success:successBlock failure:[self constructFailureBlockWithBlock:completionBlock]];
}

@end
