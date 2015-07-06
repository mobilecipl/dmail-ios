//
//  BaseNetwork.h
//  Core
//
//  Created by Armen on 3/28/14.
//  Copyright (c) 2014 Armen Mkrtchian All rights reserved.
//

#import <Foundation/Foundation.h>

/*** AFNetworking Lib ***/
#import "AFNetworking.h"
#import "AFURLRequestSerialization.h"

//Timeout category
#import "AFHTTPRequestOperationManager+Timeout.h"

/*** Service Objects ***/
#import "ErrorDataModel.h"
#import "SuccessDataModel.h"

//#import "CredentialStore.h"

@protocol BaseNetworkDelegate <NSObject>
@optional
-(void)preparingForRequests;
-(void)errorResponse:(ErrorDataModel*) error;
-(void)successResponse:(NSString*) success;
@end

typedef void(^AFConstructingBlock)(id <AFMultipartFormData> formData);
typedef void(^AFSuccessBlock)(AFHTTPRequestOperation *operation, id responseObject);
typedef void(^AFFailureBlock)(AFHTTPRequestOperation *operation, NSError *error);
typedef void (^CompletionBlock)(id data, ErrorDataModel *error);

@interface BaseNetwork : NSObject {
    AFHTTPRequestOperationManager *manager;
//    CredentialStore *cStore;
}

@property(nonatomic,weak)id<BaseNetworkDelegate> delegate;

-(void)makePostRequest:(NSString *)url withParams:(NSDictionary*)params success:(AFSuccessBlock)successBlock failure:(AFFailureBlock)failureBlock;

-(void)makePostRequest:(NSString *)url withParams:(NSDictionary*)params constructingBodyWithBlock:(AFConstructingBlock)constructingBlock success:(AFSuccessBlock)successBlock failure:(AFFailureBlock)failureBlock;

-(void)makeDeleteRequest:(NSString *)url withParams:(NSDictionary*)params success:(AFSuccessBlock)successBlock failure:(AFFailureBlock)failureBlock;

-(void)makeGetRequest:(NSString *)url withParams:(NSDictionary*)params success:(AFSuccessBlock)successBlock failure:(AFFailureBlock)failureBlock;

-(void)makePutRequest:(NSString *)url withParams:(NSDictionary*)params success:(AFSuccessBlock)successBlock failure:(AFFailureBlock)failureBlock;

-(AFFailureBlock)constructFailureBlockWithBlock:(CompletionBlock)completionBlock;

-(void)cancellAllRequests;

@end
