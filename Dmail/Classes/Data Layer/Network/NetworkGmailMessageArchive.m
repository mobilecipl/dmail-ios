//
//  NetworkGmailMessageArchive.m
//  Dmail
//
//  Created by Karen Petrosyan on 7/28/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "NetworkGmailMessageArchive.h"

#import <GoogleSignIn.h>

@implementation NetworkGmailMessageArchive

static NSString * const kUrlMessagesArchive = @"%@/filter";
//static NSString * const kUrlMessagesArchive = @"venu/forwarding";


- (instancetype)init {
    
    self = [super initWithUrl:@"https://apps-apis.google.com/a/feeds/emailsettings/2.0/science-inc.com"];
    if (self) {
        
    }
    return self;
}

- (void)archiveMessageWithFrom:(NSString *)from to:(NSString *)to subject:(NSString *)subject userID:(NSString *)userID CompletionBlock:(CompletionBlock)completionBlock {
    
//    AFSuccessBlock successBlock = ^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"operation.response.statusCode: %ld", (long)operation.response.statusCode);
//        switch (operation.response.statusCode) {
//            case 200:
//            case 204: { //Success Response
//                completionBlock(@(YES), nil);
//            }
//                break;
//            default: {
//                completionBlock(@(NO), nil);
//            }
//                break;
//        }
//    };
//    
//    NSString *urlString = [NSString stringWithFormat:kUrlMessagesArchive, @"Karen"];//@"Karen%20Petrosyan"
////    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
////    [manager.requestSerializer setValue:[NSString stringWithFormat:@"OAuth %@", [[[GIDSignIn sharedInstance].currentUser valueForKeyPath:@"authentication.accessToken"] description]] forHTTPHeaderField:@"Authorization"];
    NSDictionary *params = @{@"from" : from,
                           @"hasTheWord" : subject,
                           @"shouldArchive" : @"true"};

    NSArray *arrayParams = @[@{@"name" : @"from", @"value" : from},
                             @{@"name" : @"hasTheWord", @"value" : subject},
                             @{@"name" : @"shouldArchive", @"value" : @"true"}];
    
//    [self makePostRequest:urlString withParams:params success:successBlock failure:[self constructFailureBlockWithBlock:completionBlock]];
    
//    NSString *str = @"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<atom:entry xmlns:atom=\"http://www.w3.org/2005/Atom\" xmlns:apps=\"http://schemas.google.com/apps/2006\">\n <apps:property name=\"from\" value=\"kpetrosyan@science-inc.com\" />    <apps:property name=\"hasTheWord\" value=\"jert\" /><apps:property name=\"shouldArchive\" value=\"true\" /> </atom:entry>";
//    NSLog(@"str === %@", str);
    
//    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"params === %@", params);
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultConfigObject delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    NSString *urlmulr = [NSString stringWithFormat:@"https://apps-apis.google.com/a/feeds/emailsettings/2.0/mail.google.com/%@/filter",@"Karen"];
    NSURL * url = [NSURL URLWithString:urlmulr];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    
    NSLog(@"Ace === %@", [NSString stringWithFormat:@"OAuth %@", [[[GIDSignIn sharedInstance].currentUser valueForKeyPath:@"authentication.accessToken"] description]]);
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest addValue:[NSString stringWithFormat:@"OAuth %@", [[[GIDSignIn sharedInstance].currentUser valueForKeyPath:@"authentication.accessToken"] description]] forHTTPHeaderField:@"Authorization"];
    [urlRequest addValue:@"application/atom+xml" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:@"application/atom+xml" forHTTPHeaderField:@"Accept"];
//    [urlRequest setValue:@"1.0" forHTTPHeaderField:@"version"];
    NSData *dataRaw = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
    [urlRequest setHTTPBody:dataRaw];
    
    NSURLSessionDataTask * dataTask = [defaultSession dataTaskWithRequest:urlRequest
                                                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                            NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
                                                            NSDictionary *JSONData = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:NULL];
                                                        }];
    [dataTask resume];
}


@end