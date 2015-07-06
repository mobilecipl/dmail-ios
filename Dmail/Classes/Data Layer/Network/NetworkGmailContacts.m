//
//  NetworkGmailContacts.m
//  Dmail
//
//  Created by Gevorg Ghukasyan on 7/6/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "NetworkGmailContacts.h"
#import "XMLReader.h"

static NSString * const kUrlGetAll = @"%@/full";

@interface NetworkGmailContacts ()

@end

@implementation NetworkGmailContacts

- (instancetype)init
{
    self = [super initForGmailContacts];
//    if (self) {
//        
//    }
    return self;
}

- (void)getGoogleContactsForEmail:(NSString *)email completionBlock:(CompletionBlock)completionBlock {
    
//    NSDictionary *parameters = @{@"recipient_email" : recipientEmail,
//                                 @"position" : position,
//                                 @"count" : count};
    
    AFSuccessBlock successBlock = ^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"GetContacts JSON: %@", responseObject);
        switch (operation.response.statusCode) {
            case 200: { //Success Response
                
                NSDictionary *xmlData = [XMLReader dictionaryForXMLData:responseObject error:nil];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                        if (completionBlock) {
                            completionBlock(responseObject, nil);
                        }
                    });
            }
                break;
                
            default: {
                ErrorDataModel *error = [[ErrorDataModel alloc] init];
                error.statusCode = @(operation.response.statusCode);
                completionBlock(nil, error);
            }
                break;
        }
    };
    
    [self makeGetRequest:[NSString stringWithFormat:kUrlGetAll, email]
                  withParams:nil
                     success:successBlock
                     failure:[self constructFailureBlockWithBlock:completionBlock]];

    
    
//    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
//    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultConfigObject delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
//    
//    NSString *urlmulr = [NSString stringWithFormat:@"https://www.google.com/m8/feeds/contacts/%@/full", email];
//    
//    NSURL * url = [NSURL URLWithString:urlmulr];
//    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
//    
//    [urlRequest setHTTPMethod:@"GET"];
//    [urlRequest addValue:[NSString stringWithFormat:@"OAuth %@", [[[GIDSignIn sharedInstance].currentUser valueForKeyPath:@"authentication.accessToken"] description]] forHTTPHeaderField:@"Authorization"];
//    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    [urlRequest setValue:@"3.0" forHTTPHeaderField:@"GData-Version"];
//    
//    NSURLSessionDataTask * dataTask = [defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//        NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
//        NSDictionary *xmlData = [XMLReader dictionaryForXMLData:data error:nil];
//        NSLog(@"xmlData === %@",xmlData);
//        if (statusCode == 200) {
//            completionBlock(xmlData, nil);
//        }
//    }];
//    [dataTask resume];

}

@end
