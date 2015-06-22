//
//  NetworkManager.m
//  Dmail
//
//  Created by Karen Petrosyan on 6/17/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "NetworkManager.h"

static NSString * const getMessagesList = @"mobileClient/syncRecipients";
static NSString * const sendMessage = @"api/message";
static NSString * const sendRecipient = @"api/message";
static NSString * const getMessage = @"api/message";
static NSString * const messageSent = @"mobileClient/messageSent";

@interface NetworkManager ()

@property (nonatomic, strong) NSMutableDictionary *dictionaryTasks;
@property (nonatomic, strong) NSURLSession *defaultSession;

@end

@implementation NetworkManager

- (id)init {
    
    self = [super init];
    if (self != nil) {
        _dictionaryTasks = [[NSMutableDictionary alloc] init];
        _defaultSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    }
    
    return  self;
}

+ (instancetype)sharedManager {
    
    static NetworkManager *sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[NetworkManager alloc] init];
    });
    
    return sharedInstance;
}


#pragma mark - Private Methods
- (NSMutableURLRequest *)constructRequestWithUrl:(NSString *)urlString {
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    return request;
}

- (NSMutableURLRequest *)constructGetRequestWithUrl:(NSString *)urlString {
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    return request;
}


#pragma mark - Public Methods
- (void)getMessageListFromDmailWithPosition:(NSDictionary *)parameters withCompletionBlock:(mainCompletionBlock)completion {
    
    NSURLSessionDataTask *dataTask = self.dictionaryTasks[getMessagesList];
    if (!dataTask) {
        NSString *urlString = [NSString stringWithFormat:@"%@%@",baseURL,getMessagesList];
        NSMutableURLRequest *request = [self constructRequestWithUrl:urlString];
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:&error];
        [request setHTTPBody:jsonData];
        
        dataTask = [self.defaultSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
            NSDictionary *JSONData = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:NULL];
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(JSONData, statusCode);
            });
        }];
        self.dictionaryTasks[getMessagesList] = dataTask;
        [dataTask resume];
    }
}

- (void)getMessageUniqueIDsFromDmailWithUserId:(NSString *)userID withCompletionBlock:(void (^)(NSArray *arrayIDs, NSInteger statusCode))completion {
    
    
}

- (void)getGmailMessageIdFromGmailWithMessageUniqueId:(NSString *)gmailUniqueId withCompletionBlock:(mainCompletionBlock)completion {
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultConfigObject
                                                                 delegate:nil
                                                            delegateQueue:[NSOperationQueue mainQueue]];
    
    NSString * userID = [[[GIDSignIn sharedInstance].currentUser valueForKeyPath:@"userID"] description];
//    NSString *urlmulr = [NSString stringWithFormat:@"https://www.googleapis.com/gmail/v1/users/%@/messages/",userID];
//    gmailUniqueId = [gmailUniqueId stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *queryString = [NSString stringWithFormat:@"rfc822msgid:%@",gmailUniqueId];
    queryString = [queryString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    queryString = [queryString stringByReplacingOccurrencesOfString:@"@" withString:@"%40"];
    queryString = [queryString stringByReplacingOccurrencesOfString:@":" withString:@"%3A"];
    queryString = [queryString stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];

    NSString *urlmulr = [NSString stringWithFormat:@"https://www.googleapis.com/gmail/v1/users/%@/messages?q=%@&key=%@",userID, queryString, kGoogleClientSecret];
    NSURL * url = [NSURL URLWithString:urlmulr];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest addValue:[NSString stringWithFormat:@"OAuth %@", [[[GIDSignIn sharedInstance].currentUser valueForKeyPath:@"authentication.accessToken"] description]] forHTTPHeaderField:@"Authorization"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSURLSessionDataTask * dataTask = [defaultSession dataTaskWithRequest:urlRequest
                                                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                            NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
                                                            NSDictionary *JSONData = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:NULL];
                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                completion(JSONData, statusCode);
                                                            });
                                                        }];
    [dataTask resume];
    
}

- (void)getMessageFromGmailWithMessageId:(NSString *)messageId withCompletionBlock:(mainCompletionBlock)completion {
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultConfigObject delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    NSString * userID = [[[GIDSignIn sharedInstance].currentUser valueForKeyPath:@"userID"] description];
    NSString *urlmulr = [NSString stringWithFormat:@"https://www.googleapis.com/gmail/v1/users/%@/messages/%@?key=%@",userID, messageId, kGoogleClientSecret];
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
                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                completion(JSONData, statusCode);
                                                            });
                                                        }];
    [dataTask resume];
}

- (void)getMessageFromDmailWithGmailUniqueId:(NSString *)dmailUniqueId withCompletionBlock:(mainCompletionBlock)completion {
    
    NSURLSessionDataTask *dataTask = self.dictionaryTasks[getMessage];
    if (!dataTask) {
        NSString *urlString = [NSString stringWithFormat:@"%@%@/%@/recipient/%@",baseURL, getMessage, dmailUniqueId,[[[GIDSignIn sharedInstance].currentUser profile] email]];
        NSMutableURLRequest *request = [self constructGetRequestWithUrl:urlString];
        
        dataTask = [self.defaultSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
            NSDictionary *JSONData = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:NULL];
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(JSONData, statusCode);
            });
            [self.dictionaryTasks removeObjectForKey:getMessage];
        }];
        self.dictionaryTasks[getMessage] = dataTask;
        [dataTask resume];
    }

}


- (void)sendRecipientsWithParameters:(NSDictionary *)parameters messageId:(NSString *)messageId completionBlock:(mainCompletionBlock)completion {
    
    NSURLSessionDataTask *dataTask = self.dictionaryTasks[sendRecipient];
    if (!dataTask) {
        NSString *urlString = [NSString stringWithFormat:@"%@%@/%@/recipient/",baseURL, sendRecipient, messageId];
        NSMutableURLRequest *request = [self constructRequestWithUrl:urlString];
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:&error];
        [request setHTTPBody:jsonData];
        
        dataTask = [self.defaultSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
            NSDictionary *JSONData = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:NULL];
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(JSONData, statusCode);
            });
            [self.dictionaryTasks removeObjectForKey:sendRecipient];
        }];
        self.dictionaryTasks[sendRecipient] = dataTask;
        [dataTask resume];
    }
}

- (void)sendMessageToDmailWithEncriptedMessage:(NSString *)encriptedMessage senderEmail:(NSString *)senderEmail completionBlock:(mainCompletionBlock)completion {
    
    NSDictionary *parameters = @{@"sender_email" : senderEmail,
                                 @"encrypted_message" : encriptedMessage,};
    
    NSURLSessionDataTask *dataTask = self.dictionaryTasks[sendMessage];
    if (!dataTask) {
        NSString *urlString = [NSString stringWithFormat:@"%@%@",baseURL,sendMessage];
        NSMutableURLRequest *request = [self constructRequestWithUrl:urlString];
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:&error];
        [request setHTTPBody:jsonData];
        
        dataTask = [self.defaultSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
            NSDictionary *JSONData = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:NULL];
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(JSONData, statusCode);
            });
            [self.dictionaryTasks removeObjectForKey:sendMessage];
        }];
        self.dictionaryTasks[sendMessage] = dataTask;
        [dataTask resume];
    }
}

- (void)sendMessageToGmailWithEncodedBody:(NSString *)encodedBody withCompletionBlock:(void (^)(NSDictionary *requestData, NSInteger statusCode))completion {
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultConfigObject delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    NSString * userID = [[[GIDSignIn sharedInstance].currentUser valueForKeyPath:@"userID"] description];
    NSString *urlmulr = [NSString stringWithFormat:@"https://www.googleapis.com/gmail/v1/users/%@/messages/send?key=%@",userID, kGoogleClientSecret];
    NSURL * url = [NSURL URLWithString:urlmulr];
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest addValue:[NSString stringWithFormat:@"OAuth %@", [[[GIDSignIn sharedInstance].currentUser valueForKeyPath:@"authentication.accessToken"] description]] forHTTPHeaderField:@"Authorization"];
    
    NSDictionary *rawDict = @{@"raw" : encodedBody};
    NSData *dataRaw = [NSJSONSerialization dataWithJSONObject:rawDict options:NSJSONWritingPrettyPrinted error:nil];
    [urlRequest setHTTPBody:dataRaw];
    [urlRequest setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    
    NSURLSessionDataTask * dataTask = [defaultSession dataTaskWithRequest:urlRequest
                                                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                            NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
                                                            NSDictionary *JSONData = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:NULL];
                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                completion(JSONData, statusCode);
                                                            });
                                                        }];
    [dataTask resume];
}

- (void)sendMessageUniqueIdToDmailWithMessageDmailId:(NSString*)dmailId gmailUniqueId:(NSString *)gmailUniqueId senderEmail:(NSString *)senderEmail withCompletionBlock:(mainCompletionBlock)completion {
    
    NSDictionary *parameters = @{@"message_id" : dmailId,
                                 @"message_identifier" : gmailUniqueId,
                                 @"sender_email" : senderEmail};
    
    NSURLSessionDataTask *dataTask = self.dictionaryTasks[messageSent];
    if (!dataTask) {
        NSString *urlString = [NSString stringWithFormat:@"%@%@",baseURL,messageSent];
        NSMutableURLRequest *request = [self constructRequestWithUrl:urlString];
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:&error];
        [request setHTTPBody:jsonData];
        
        dataTask = [self.defaultSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
            NSDictionary *JSONData = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:NULL];
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(JSONData, statusCode);
            });
            [self.dictionaryTasks removeObjectForKey:messageSent];
        }];
        self.dictionaryTasks[messageSent] = dataTask;
        [dataTask resume];
    }
}

@end
