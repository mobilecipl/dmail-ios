//
//  NetworkProfileAuth.m
//  Dmail
//
//  Created by Karen Petrosyan on 9/22/15.
//  Copyright © 2015 Karen Petrosyan. All rights reserved.
//

#import "NetworkProfileAuth.h"


@interface NetworkProfileAuth ()

@property (nonatomic, strong) NSURLSession *defaultSession;

@end

@implementation NetworkProfileAuth


//- (instancetype)init {
//    
//    self = [super initWithUrl:@"https://accounts.google.com/o/oauth2/token"];
//    if (self) {
//        
//    }
//    return self;
//}


//- (void)refreshTokenWith:(NSString *)refreshToken completionBlock:(CompletionBlock)completionBlock {
//    
//    AFSuccessBlock successBlock = ^(AFHTTPRequestOperation *operation, id responseObject) {
//        switch (operation.response.statusCode) {
//            case 200: {
//                if ([responseObject isKindOfClass:[NSDictionary class]]) {
//                    //TODO:
//                    if (completionBlock) {
//                        completionBlock(responseObject, nil);
//                    }
//                } else {
//                    ErrorDataModel *error = [[ErrorDataModel alloc] init];
//                    error.statusCode = @400;
//                    error.message = kErrorMessageNoServer;
//                    completionBlock(nil, error);
//                }
//            }
//                break;
//                
//            default: {
//                ErrorDataModel *error = [[ErrorDataModel alloc] initWithDictionary:responseObject];
//                completionBlock(nil, error);
//            }
//                break;
//        }
//    };
//    
//    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
//    NSDictionary *parameters = @{@"client_id" : kGoogleClientID,
//                                 @"client_secret" : kGoogleClientSecret,
//                                 @"refresh_token" : refreshToken,
//                                 @"grant_type" : @"refresh_token"};
////    NSString *string = [NSString stringWithFormat:@"client_id=%@&client_secret=%@&refresh_token=%@&grant_type=refresh_token",kGoogleClientID,kGoogleClientSecret,refreshToken];
//
//    [self makePostRequest:@"https://accounts.google.com/o/oauth2/token" withParams:parameters success:successBlock failure:[self constructFailureBlockWithBlock:completionBlock]];
//}

- (void)refreshTokenWith:(NSString *)refreshToken completionBlock:(CompletionBlock)completionBlock {
    
        NSString *urlString = @"https://accounts.google.com/o/oauth2/token";
        NSMutableURLRequest *request = [self constructRequestWithUrl:urlString];
        
        NSError *error;
    NSDictionary *parameters = @{@"client_id" : kGoogleClientID,
                                 @"client_secret" : kGoogleClientSecret,
                                 @"refresh_token" : refreshToken,
                                 @"grant_type" : @"refresh_token"};

        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:&error];
        [request setHTTPBody:jsonData];
        
        NSURLSessionDataTask *dataTask = [self.defaultSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSInteger errorStatus = 0;
            NSDictionary *parsedData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
//                completion(errorStatus, parsedData);
            });
        }];
}

- (NSMutableURLRequest *)constructRequestWithUrl:(NSString *)urlString {
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    return request;
}

@end
