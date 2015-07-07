//
//  BaseService.m
//  Core
//
//  Created by Armen on 3/28/14.
//  Copyright (c) 2014 Armen Mkrtchian All rights reserved.
//

#import "BaseNetwork.h"
//#import "Configuration.h"
#import "Util.h"
#import "GoogleSignIn.h"

#define TimeOutInterval 15

#define kStatusCode @"statusCode"
#define kErrorMessage @"errorMessage"

@implementation BaseNetwork

-(instancetype)init {
    
    self = [super init];
	if (self != nil)
    {
        //Init
        manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kBaseServerURL]];
        NSOperationQueue *operationQueue = manager.operationQueue;
//        [manager.reachabilityManager startMonitoring];
        [manager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
//            UALog(@"AFNetworkReachabilityStatus: %li", status);
            
            switch (status) {
                case AFNetworkReachabilityStatusReachableViaWWAN:
                case AFNetworkReachabilityStatusReachableViaWiFi: {
                    [operationQueue setSuspended:NO];                    
                }                    
                    break;
                case AFNetworkReachabilityStatusNotReachable:
                default:
                    [operationQueue setSuspended:YES];
                    break;
            }
        }];
        AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
        
        [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [requestSerializer setHTTPShouldHandleCookies:NO];
        
        manager.requestSerializer = requestSerializer;
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
//        cStore = [CredentialStore sharedInstance];
	}
    
    return  self;
}

- (instancetype)initForGmailContacts {
    
    self = [super init];
    if (self != nil)
    {
        //Init
        manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"https://www.google.com/m8/feeds/contacts"]];
        NSOperationQueue *operationQueue = manager.operationQueue;
        [manager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            
            switch (status) {
                case AFNetworkReachabilityStatusReachableViaWWAN:
                case AFNetworkReachabilityStatusReachableViaWiFi: {
                    [operationQueue setSuspended:NO];
                }
                    break;
                case AFNetworkReachabilityStatusNotReachable:
                default:
                    [operationQueue setSuspended:YES];
                    break;
            }
        }];
        AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
        
        
        [requestSerializer setValue:[NSString stringWithFormat:@"OAuth %@", [[[GIDSignIn sharedInstance].currentUser valueForKeyPath:@"authentication.accessToken"] description]] forHTTPHeaderField:@"Authorization"];
        [requestSerializer setValue:@"application/atom+xml" forHTTPHeaderField:@"Content-Type"];
        [requestSerializer setValue:@"3.0" forHTTPHeaderField:@"GData-Version"];
        [requestSerializer setHTTPShouldHandleCookies:NO];
        
        manager.requestSerializer = requestSerializer;
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        //        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/atom+xml"];

    }
    
    return  self;
}

- (instancetype)initForGmailMessage {
    
    self = [super init];
    if (self != nil)
    {
        //Init
        manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"https://www.googleapis.com/gmail/v1/users"]];
        NSOperationQueue *operationQueue = manager.operationQueue;
        [manager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            
            switch (status) {
                case AFNetworkReachabilityStatusReachableViaWWAN:
                case AFNetworkReachabilityStatusReachableViaWiFi: {
                    [operationQueue setSuspended:NO];
                }
                    break;
                case AFNetworkReachabilityStatusNotReachable:
                default:
                    [operationQueue setSuspended:YES];
                    break;
            }
        }];
        AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
        
        [requestSerializer setValue:[NSString stringWithFormat:@"OAuth %@", [[[GIDSignIn sharedInstance].currentUser valueForKeyPath:@"authentication.accessToken"] description]] forHTTPHeaderField:@"Authorization"];
        
        [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

        [requestSerializer setHTTPShouldHandleCookies:NO];
        
        manager.requestSerializer = requestSerializer;
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    }
    
    return  self;
}


-(void)preparingForRequests {
    
    [self prepareRequest];
    
    __block __weak id blockDelegate = self.delegate;
    //Preparing For request
    if([blockDelegate respondsToSelector:@selector(preparingForRequests)])
    {
        [blockDelegate preparingForRequests];
    }
}

-(void)prepareRequest {
    
    NSString *appVersion = [NSString stringWithFormat:@"app_version=t.i.%@;", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
}

-(NSDictionary *)prepareParams:(NSDictionary *)params {
    NSMutableDictionary *newParams = [NSMutableDictionary dictionaryWithDictionary:params];
    //    NSString *authToken = [cStore authToken];
    //    [newParams setObject:kLocaleLanguage forKey:kLanguage];
    return newParams;
}

-(void)makePostRequest:(NSString *)url withParams:(NSDictionary*)params success:(AFSuccessBlock)successBlock failure:(AFFailureBlock)failureBlock {
    //Preparing For request
    [self preparingForRequests];
    NSDictionary *newParams = [self prepareParams:params];

    [manager POST:url parameters:newParams timeoutInterval:TimeOutInterval success:successBlock failure:failureBlock];
}

-(void)makePutRequest:(NSString *)url withParams:(NSDictionary*)params success:(AFSuccessBlock)successBlock failure:(AFFailureBlock)failureBlock {
    //Preparing For request
    [self preparingForRequests];
    NSDictionary *newParams = [self prepareParams:params];

    [manager PUT:url parameters:newParams timeoutInterval:TimeOutInterval success:successBlock failure:failureBlock];
}

-(void)makeDeleteRequest:(NSString *)url withParams:(NSDictionary*)params success:(AFSuccessBlock)successBlock failure:(AFFailureBlock)failureBlock {
    //Preparing For request
    [self preparingForRequests];
    NSDictionary *newParams = [self prepareParams:params];

    [manager DELETE:url parameters:newParams timeoutInterval:TimeOutInterval success:successBlock failure:failureBlock];
}

-(void)makeGetRequest:(NSString *)url withParams:(NSDictionary*)params success:(AFSuccessBlock)successBlock failure:(AFFailureBlock)failureBlock {
    //Preparing For request
    [self preparingForRequests];
    NSDictionary *newParams = [self prepareParams:params];

    [manager GET:url parameters:newParams timeoutInterval:TimeOutInterval success:successBlock failure:failureBlock];
}

-(void)makePostRequest:(NSString *)url withParams:(NSDictionary*)params constructingBodyWithBlock:(AFConstructingBlock)constructingBlock success:(AFSuccessBlock)successBlock failure:(AFFailureBlock)failureBlock {
    //Preparing For request
    [self preparingForRequests];
    NSDictionary *newParams = [self prepareParams:params];

    [manager POST:url parameters:newParams timeoutInterval:TimeOutInterval constructingBodyWithBlock:constructingBlock success:successBlock failure:failureBlock];
}


-(AFFailureBlock)constructFailureBlockWithBlock:(CompletionBlock)completionBlock {
    __block __weak id blockDelegate = self.delegate;
    
    AFFailureBlock failureBlock = ^(AFHTTPRequestOperation *operation, NSError *error) {
        //URL Loading System Error Codes
        //https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Miscellaneous/Foundation_Constants/Reference/reference.html
        NSLog(@"responseObject: %@", [operation responseObject]);
        id responseObject = [operation responseObject];
        if (responseObject) {
            switch (operation.response.statusCode) {
                case 400: //Error Response
                {
                    //Error Response
                    ErrorDataModel *errorObj;
                    
                    if ([responseObject isKindOfClass:[NSDictionary class]]) {
                        errorObj = [[ErrorDataModel alloc] initWithDictionary:responseObject];
                    }
                    
                    completionBlock(nil, errorObj);
                    if([blockDelegate respondsToSelector:@selector(errorResponse:)])
                    {
                        [blockDelegate errorResponse: errorObj];
                    }
                }
                    break;
                case 401: //Not valid user token
                {
                    //Error Response
                    ErrorDataModel *errorObj;
                    
                    if ([responseObject isKindOfClass:[NSDictionary class]]) {
                        errorObj = [[ErrorDataModel alloc] initWithDictionary:responseObject];
                    }
                    
                    completionBlock(nil, errorObj);
                    if([blockDelegate respondsToSelector:@selector(errorResponse:)])
                    {
                        [blockDelegate errorResponse: errorObj];
                    }
//                    [Util logout];
                }
                    break;
                case 500: //Internal Error Response
                {
                    //TODO handle internal errors
                    ErrorDataModel *errorObj;
                    
                    if ([responseObject isKindOfClass:[NSDictionary class]]) {
                        errorObj = [[ErrorDataModel alloc] initWithDictionary:responseObject];
                    } else {
                        NSDictionary *errorData = @{kStatusCode: @500, kErrorMessage : @"Network Error"};
                        errorObj = [[ErrorDataModel alloc] initWithDictionary:errorData];
                    }
                    
                    completionBlock(nil, errorObj);
                    if([blockDelegate respondsToSelector:@selector(errorResponse:)])
                    {
                        [blockDelegate errorResponse: errorObj];
                    }
                    
                }
                    break;
                default:
                {
                    
                }
                    break;
            }
        } else {
            NSLog(@"Error: %@", [error description]);
            if (error) {
                //general error
                switch (error.code) {
                        break;
                    case -999: //Request Canceled Error Response
                    {
                        //TODO handle Request Cancel Error
                        ErrorDataModel *errorObj;
                        NSDictionary *errorData = @{kStatusCode: @(-999), kErrorMessage : @"Request Cancelled"};
                        errorObj = [[ErrorDataModel alloc] initWithDictionary:errorData];
                        
                        completionBlock(nil, errorObj);
                        if([blockDelegate respondsToSelector:@selector(errorResponse:)])
                        {
                            [blockDelegate errorResponse: errorObj];
                        }
                    }
                        break;
                    case -1001: //Request Timeout Error
                    {
                        //TODO handle Timeout Error
                        ErrorDataModel *errorObj;
                        
                        if ([responseObject isKindOfClass:[NSDictionary class]]) {
                            errorObj = [[ErrorDataModel alloc] initWithDictionary:responseObject];
                        } else {
                            NSDictionary *errorData = @{kStatusCode: @(-1001), kErrorMessage : @"Network Timeout"};
                            errorObj = [[ErrorDataModel alloc] initWithDictionary:errorData];
                        }
                        
                        completionBlock(nil, errorObj);
                        if([blockDelegate respondsToSelector:@selector(errorResponse:)])
                        {
                            [blockDelegate errorResponse: errorObj];
                        }
                    }
                        break;
                    case -1009: //The Internet connection appears to be offline.
                    {
                        ErrorDataModel *errorObj;
                        
                        if ([responseObject isKindOfClass:[NSDictionary class]]) {
                            errorObj = [[ErrorDataModel alloc] initWithDictionary:responseObject];
                        } else {
                            NSDictionary *errorData = @{kStatusCode: @(-1009), kErrorMessage : @"The Internet connection appears to be offline."};
                            errorObj = [[ErrorDataModel alloc] initWithDictionary:errorData];
                        }
                        
                        completionBlock(nil, errorObj);
                        if([blockDelegate respondsToSelector:@selector(errorResponse:)])
                        {
                            [blockDelegate errorResponse: errorObj];
                        }
                    }
                        break;
                    default:
                    {
                        ErrorDataModel *errorObj;
                        NSDictionary *errorData = @{kStatusCode: @(error.code), kErrorMessage : error.localizedDescription};
                        errorObj = [[ErrorDataModel alloc] initWithDictionary:errorData];
                        
                        completionBlock(nil, errorObj);
                        if([blockDelegate respondsToSelector:@selector(errorResponse:)])
                        {
                            [blockDelegate errorResponse: errorObj];
                        }
                    }
                        break;
                }
            }
        }
    };
    return failureBlock;
}

-(void)cancellAllRequests {

    [manager.operationQueue cancelAllOperations];
}
@end
