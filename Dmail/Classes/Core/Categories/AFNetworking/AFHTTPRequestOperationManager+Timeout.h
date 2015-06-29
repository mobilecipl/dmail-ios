//
//  AFHTTPRequestOperationManager+Timeout.h
//  Core
//
//  Created by Armen on 4/3/14.
//  Copyright (c) 2014 Armen Mkrtchian All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"

@interface AFHTTPRequestOperationManager (Timeout)

///---------------------------
/// @name Making HTTP Requests
///---------------------------

/**
 Creates and runs an `AFHTTPRequestOperation` with a `GET` request.
 
 @param URLString The URL string used to create the request URL.
 @param parameters The parameters to be encoded according to the client request serializer.
 @param timeoutInterval Timeout interval for request
 @param success A block object to be executed when the request operation finishes successfully. 
    This block has no return value and takes two arguments: the request operation, and the response
    object created by the client response serializer.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, 
    or that finishes successfully, but encountered an error while parsing the response data. This
    block has no return value and takes a two arguments: the request operation and the error
    describing the network or parsing error that occurred.
 
 @see -HTTPRequestOperationWithRequest:success:failure:
 */
-(AFHTTPRequestOperation *)GET:(NSString *)URLString
                    parameters:(NSDictionary *)parameters
               timeoutInterval:(NSTimeInterval)timeoutInterval
                       success:(void(^)(AFHTTPRequestOperation *operation, id responseObject))success
                       failure:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failure;

/**
 Creates and runs an `AFHTTPRequestOperation` with a `HEAD` request.
 
 @param URLString The URL string used to create the request URL.
 @param parameters The parameters to be encoded according to the client request serializer.
 @param timeoutInterval Timeout interval for request
 @param success A block object to be executed when the request operation finishes successfully. 
    This block has no return value and takes a single arguments: the request operation.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, 
    or that finishes successfully, but encountered an error while parsing the response data. 
    This block has no return value and takes a two arguments: the request operation and the 
    error describing the network or parsing error that occurred.
 
 @see -HTTPRequestOperationWithRequest:success:failure:
 */
- (AFHTTPRequestOperation *)HEAD:(NSString *)URLString
                      parameters:(NSDictionary *)parameters
                 timeoutInterval:(NSTimeInterval)timeoutInterval
                         success:(void (^)(AFHTTPRequestOperation *operation))success
                         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

/**
 Creates and runs an `AFHTTPRequestOperation` with a `POST` request.
 
 @param URLString The URL string used to create the request URL.
 @param parameters The parameters to be encoded according to the client request serializer.
 @param timeoutInterval Timeout interval for request
 @param success A block object to be executed when the request operation finishes successfully. 
    This block has no return value and takes two arguments: the request operation, and the response 
    object created by the client response serializer.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, 
    or that finishes successfully, but encountered an error while parsing the response data. 
    This block has no return value and takes a two arguments: the request operation and the error 
    describing the network or parsing error that occurred.
 
 @see -HTTPRequestOperationWithRequest:success:failure:
 */
-(AFHTTPRequestOperation *)POST:(NSString *)URLString
                     parameters:(NSDictionary *)parameters
                timeoutInterval:(NSTimeInterval)timeoutInterval
                        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

/**
 Creates and runs an `AFHTTPRequestOperation` with a multipart `POST` request.
 
 @param URLString The URL string used to create the request URL.
 @param parameters The parameters to be encoded according to the client request serializer.
 @param timeoutInterval Timeout interval for request
 @param block A block that takes a single argument and appends data to the HTTP body. The block 
    argument is an object adopting the `AFMultipartFormData` protocol.
 @param success A block object to be executed when the request operation finishes successfully. 
    This block has no return value and takes two arguments: the request operation, and the response 
    object created by the client response serializer.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, 
    or that finishes successfully, but encountered an error while parsing the response data. This 
    block has no return value and takes a two arguments: the request operation and the error 
    describing the network or parsing error that occurred.
 
 @see -HTTPRequestOperationWithRequest:success:failure:
 */
- (AFHTTPRequestOperation *)POST:(NSString *)URLString
                      parameters:(NSDictionary *)parameters
                 timeoutInterval:(NSTimeInterval)timeoutInterval
       constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

/**
 Creates and runs an `AFHTTPRequestOperation` with a `PUT` request.
 
 @param URLString The URL string used to create the request URL.
 @param parameters The parameters to be encoded according to the client request serializer.
 @param timeoutInterval Timeout interval for request
 @param success A block object to be executed when the request operation finishes successfully. 
    This block has no return value and takes two arguments: the request operation, and the response 
    object created by the client response serializer.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, 
    or that finishes successfully, but encountered an error while parsing the response data. 
    This block has no return value and takes a two arguments: the request operation and the error 
    describing the network or parsing error that occurred.
 
 @see -HTTPRequestOperationWithRequest:success:failure:
 */
- (AFHTTPRequestOperation *)PUT:(NSString *)URLString
                     parameters:(NSDictionary *)parameters
                timeoutInterval:(NSTimeInterval)timeoutInterval
                        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

/**
 Creates and runs an `AFHTTPRequestOperation` with a `PATCH` request.
 
 @param URLString The URL string used to create the request URL.
 @param parameters The parameters to be encoded according to the client request serializer.
 @param timeoutInterval Timeout interval for request
 @param success A block object to be executed when the request operation finishes successfully. 
    This block has no return value and takes two arguments: the request operation, and the response 
    object created by the client response serializer.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, 
    or that finishes successfully, but encountered an error while parsing the response data. This 
    block has no return value and takes a two arguments: the request operation and the error 
    describing the network or parsing error that occurred.
 
 @see -HTTPRequestOperationWithRequest:success:failure:
 */
- (AFHTTPRequestOperation *)PATCH:(NSString *)URLString
                       parameters:(NSDictionary *)parameters
                  timeoutInterval:(NSTimeInterval)timeoutInterval
                          success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                          failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

/**
 Creates and runs an `AFHTTPRequestOperation` with a `DELETE` request.
 
 @param URLString The URL string used to create the request URL.
 @param parameters The parameters to be encoded according to the client request serializer.
 @param timeoutInterval Timeout interval for request
 @param success A block object to be executed when the request operation finishes successfully. 
    This block has no return value and takes two arguments: the request operation, and the response 
    object created by the client response serializer.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, 
    or that finishes successfully, but encountered an error while parsing the response data. 
    This block has no return value and takes a two arguments: the request operation and the error 
    describing the network or parsing error that occurred.
 
 @see -HTTPRequestOperationWithRequest:success:failure:
 */
- (AFHTTPRequestOperation *)DELETE:(NSString *)URLString
                        parameters:(NSDictionary *)parameters
                   timeoutInterval:(NSTimeInterval)timeoutInterval
                           success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;


@end
