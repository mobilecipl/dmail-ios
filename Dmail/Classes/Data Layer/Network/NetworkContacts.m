//
//  NetworkContacts.m
//  Dmail
//
//  Created by Karen Petrosyan on 7/3/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "NetworkContacts.h"
#import "ProfileService.h"
#import "XMLReader.h"


static NSString * const kUrlGetContacts = @"https://www.google.com/m8/feeds/contacts/";

@implementation NetworkContacts

- (void)getGoogleContactsForEmail:(NSString *)email completionBlock:(CompletionBlock)completionBlock {
    
//    AFSuccessBlock successBlock = ^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"getEncryptedMessage JSON: %@", responseObject);
//        switch (operation.response.statusCode) {
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
//        }
//    };
//
//    NSString *url = [NSString stringWithFormat:@"%@%@/full", kUrlGetContacts, [[UserService sharedInstance] email]];
//    [manager.requestSerializer setValue:[NSString stringWithFormat:@"OAuth %@", [[[GIDSignIn sharedInstance].currentUser valueForKeyPath:@"authentication.accessToken"] description]] forHTTPHeaderField:@"Authorization"];
//    [manager.requestSerializer setValue:@"3.0" forHTTPHeaderField:@"GData-Version"];
//    [self makeGetRequest:url withParams:nil success:successBlock failure:[self constructFailureBlockWithBlock:completionBlock]];
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultConfigObject delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    NSString *urlmulr = [NSString stringWithFormat:@"https://www.google.com/m8/feeds/contacts/%@/full?alt=json", email];
    
    NSURL * url = [NSURL URLWithString:urlmulr];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest addValue:[NSString stringWithFormat:@"OAuth %@", [[[GIDSignIn sharedInstance].currentUser valueForKeyPath:@"authentication.accessToken"] description]] forHTTPHeaderField:@"Authorization"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:@"3.0" forHTTPHeaderField:@"GData-Version"];
    
    NSURLSessionDataTask * dataTask = [defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
        NSDictionary *xmlData = [XMLReader dictionaryForXMLData:data error:nil];
        NSLog(@"xmlData === %@",xmlData);
        if (statusCode == 200) {
            completionBlock(xmlData, nil);
        }
    }];
    [dataTask resume];
}

@end
