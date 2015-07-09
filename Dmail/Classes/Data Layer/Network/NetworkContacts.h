//
//  NetworkContacts.h
//  Dmail
//
//  Created by Karen Petrosyan on 7/3/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseNetwork.h"

@interface NetworkContacts : BaseNetwork

- (void)getGoogleContactsForEmail:(NSString *)email lastUpdateDate:(long long)lastUpdateDate completionBlock:(CompletionBlock)completionBlock;

- (void)getContactsForEmail:(NSString *)email completionBlock:(CompletionBlock)completionBlock;

- (void)getContactsWithPagingForEmail:(NSString *)email
                           startIndex:(NSString *)startIndex
                            maxResult:(NSString *)maxResult
                      completionBlock:(CompletionBlock)completionBlock;

@end
