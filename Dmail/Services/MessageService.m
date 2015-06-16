//
//  MessageService.m
//  Dmail
//
//  Created by Karen Petrosyan on 6/12/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "MessageService.h"
#import <GoogleSignIn/GoogleSignIn.h>
#import "Configurations.h"
#import "MessageParseService.h"

@implementation MessageService

+ (MessageService *)sharedInstance {
    static MessageService *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[MessageService alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark - Public Methods
- (void)getMessageUniqueIDsFromDmailWithUserId:(NSString *)userID withCompletionBlock:(void (^)(NSArray *arrayIDs, NSError *error))completion {
    
    
}

- (void)getMessageFromGmailWithGmailUniqueId:(NSString *)gmailUniqueId withCompletionBlock:(void (^)(NSString *messageId, NSError *error))completion {
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultConfigObject
                                                                 delegate:nil
                                                            delegateQueue:[NSOperationQueue mainQueue]];
    
    NSLog(@"token %@" , [[[GIDSignIn sharedInstance].currentUser valueForKeyPath:@"authentication.accessToken"] description]);
    NSString * userID = [[[GIDSignIn sharedInstance].currentUser valueForKeyPath:@"userID"] description];
    //    NSString *urlmulr = [NSString stringWithFormat:@"https://www.googleapis.com/gmail/v1/users/%@/messages/",userID];
    NSString *queryString = [NSString stringWithFormat:@"rfc822msgid:%@",gmailUniqueId];
    NSString *urlmulr = [NSString stringWithFormat:@"https://www.googleapis.com/gmail/v1/users/%@/messages?q=%@&key=%@",userID, queryString, kClientSecret];
    NSURL * url = [NSURL URLWithString:urlmulr];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest addValue:[NSString stringWithFormat:@"OAuth %@", [[[GIDSignIn sharedInstance].currentUser valueForKeyPath:@"authentication.accessToken"] description]] forHTTPHeaderField:@"Authorization"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSLog(@"%s URL %@ \n SENDING PARAMS",__PRETTY_FUNCTION__,urlmulr);
    
    NSURLSessionDataTask * dataTask = [defaultSession dataTaskWithRequest:urlRequest
                                                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                            NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
                                                            NSDictionary *JSONData = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:NULL];
                                                            
                                                            NSLog(@"requestReply :: %@ \n requestStatusCode :: %ld", [JSONData description],(long)statusCode);
                                                            NSString *messageId;
                                                            switch (statusCode) {
                                                                case 200: {
                                                                    messageId = [[MessageParseService sharedInstance] gmailMessageId:JSONData];
//                                                                    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//                                                                    NSDictionary *object = nil;
                                                                }
                                                                    break;
                                                                case 0: {
                                                                    
                                                                }
                                                                    break;
                                                                    
                                                                default: {
                                                                    
                                                                }
                                                                    break;
                                                            }
                                                            completion(messageId, error);
                                                        }];
    [dataTask resume];

}

- (void)getMessageFromDmailWithGmailUniqueId:(NSString *)gmailUniqueId withCompletionBlock:(void (^)(BOOL success, NSError *error))completion {
    
    
}

@end
