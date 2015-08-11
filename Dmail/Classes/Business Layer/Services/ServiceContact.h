//
//  ServiceContact.h
//  Dmail
//
//  Created by Karen Petrosyan on 7/3/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseService.h"


@interface ServiceContact : BaseService

- (NSMutableArray *)getContactsWithName:(NSString *)name;

- (void)getContactsWithPagingForEmail:(NSString *)email maxResult:(NSString *)maxResult completionBlock:(CompletionBlock)completionBlock;

- (void)cancelAllRequests;

@end
