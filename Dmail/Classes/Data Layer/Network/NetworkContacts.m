//
//  NetworkContacts.m
//  Dmail
//
//  Created by Karen Petrosyan on 7/3/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "NetworkContacts.h"
#import "ServiceProfile.h"

#import "ContactModel.h"

static NSString * const kUrlGetContacts = @"https://www.google.com/m8/feeds/contacts/";
static NSString * const kUrlGetWithPaging = @"%@/full?alt=json&start-index=%@&max-results=%@&updated-min=%@";

@implementation NetworkContacts

- (instancetype)init {
    
    self = [super initWithUrl:kUrlGetContacts];
    
    [manager.requestSerializer setValue:@"3.0" forHTTPHeaderField:@"GData-Version"];
    return self;
}

- (void)getContactsForEmail:(NSString *)email
                 startIndex:(NSString *)startIndex
                  maxResult:(NSString *)maxResult
                 updatedMin:(NSString *)updatedMin
            completionBlock:(CompletionBlock)completionBlock {
    
    
    AFSuccessBlock successBlock = ^(AFHTTPRequestOperation *operation, id responseObject) {
        switch (operation.response.statusCode) {
            case 200: {
                if (completionBlock) {
                    completionBlock(responseObject, nil);
                }
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
    
    NSString *urlRequest = [NSString stringWithFormat:kUrlGetWithPaging, email, startIndex, maxResult, updatedMin];
//    [manager.requestSerializer setValue:[NSString stringWithFormat:@"OAuth %@", [[[GIDSignIn sharedInstance].currentUser valueForKeyPath:@"authentication.accessToken"] description]] forHTTPHeaderField:@"Authorization"];
    [self makeGetRequest:urlRequest withParams:nil success:successBlock failure:[self constructFailureBlockWithBlock:completionBlock]];
}

@end
