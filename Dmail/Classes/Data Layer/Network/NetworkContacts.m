//
//  NetworkContacts.m
//  Dmail
//
//  Created by Karen Petrosyan on 7/3/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "NetworkContacts.h"
#import "ServiceProfile.h"
#import "XMLReader.h"

#import "ContactModel.h"

static NSString * const kUrlGetContacts = @"https://www.google.com/m8/feeds/contacts/";
static NSString * const kUrlGetAll = @"%@/full?alt=json";

static NSString * const kUrlGetWithPaging = @"%@/full?alt=json&start-index=%@&max-results=%@";//&key=%@";
static NSString * const kUrlUpdate = @"%@/full?updated-min=%@";

@implementation NetworkContacts

- (instancetype)init {
    
    self = [super initForGmailContacts];
    return self;
}

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

- (void)getContactsForEmail:(NSString *)email completionBlock:(CompletionBlock)completionBlock {
    
    AFSuccessBlock successBlock = ^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"GetContacts JSON: %@", responseObject);
        switch (operation.response.statusCode) {
            case 200: { //Success Response
                
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
}


- (void)getContactsWithPagingForEmail:(NSString *)email
                           startIndex:(NSString *)startIndex
                            maxResult:(NSString *)maxResult
                      completionBlock:(CompletionBlock)completionBlock {
    
    
       AFSuccessBlock successBlock = ^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"GetContacts JSON: %@", responseObject);
        switch (operation.response.statusCode) {
            case 200: { //Success Response
                
                NSArray *arr = [self parseContactsWithDictionary:responseObject];
                
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
    
    NSString *urlRequest = [NSString stringWithFormat:kUrlGetWithPaging, email, startIndex, maxResult];
    
    [self makeGetRequest:urlRequest
              withParams:nil
                 success:successBlock
                 failure:[self constructFailureBlockWithBlock:completionBlock]];
}

- (void)getUpdatedContactsForEmail:(NSString *)email completionBlock:(CompletionBlock)completionBlock {
    
    AFSuccessBlock successBlock = ^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"GetContacts JSON: %@", responseObject);
        switch (operation.response.statusCode) {
            case 200: { //Success Response
                
                NSArray *arr = [self parseContactsWithDictionary:responseObject];
                
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
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:0] forKey:@"generationDate"];
    
    [self makeGetRequest:[NSString stringWithFormat:kUrlUpdate, email, @"2"]
              withParams:nil
                 success:successBlock
                 failure:[self constructFailureBlockWithBlock:completionBlock]];
}

- (NSArray *)parseContactsWithDictionary:(NSDictionary *)dict {
    
    NSMutableArray *arrayModels = [[NSMutableArray alloc] init];
    NSDictionary *dictFeed = dict[@"feed"];
    NSArray *entryFeed = dictFeed[@"entry"];
    for (NSDictionary *dict in entryFeed) {
        NSString *email;
        NSString *fullName;
        NSString *contactId;
        if ([[dict allKeys] containsObject:@"gd:email"]) {
            NSDictionary *emailDict = dict[@"gd:email"];
            email = emailDict[@"address"];
            NSLog(@"email === %@", email);
        }
        if ([[dict allKeys] containsObject:@"gd:name"]) {
            NSDictionary *emailDict = dict[@"gd:name"];
            NSDictionary *fullNameDict = emailDict[@"gd:fullName"];
            fullName = fullNameDict[@"text"];
            NSLog(@"fullName === %@", fullName);
        }
        if ([[dict allKeys] containsObject:@"id"]) {
            NSDictionary *idDict = dict[@"id"];
            contactId = idDict[@"text"];
            NSArray *array = [contactId componentsSeparatedByString:@"/"];
            contactId = [array lastObject];
            NSLog(@"contactId === %@", contactId);
        }
        ContactModel *model = [[ContactModel alloc] initWithEmail:email fullName:fullName contactId:contactId];
        [arrayModels addObject:model];
        NSLog(@"============================================\n");
    }
    
    return [NSArray arrayWithArray:arrayModels];
}

@end
