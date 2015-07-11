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

- (void)getContactsForEmail:(NSString *)email
                 startIndex:(NSString *)startIndex
                  maxResult:(NSString *)maxResult
                 updatedMin:(NSString *)updatedMin
            completionBlock:(CompletionBlock)completionBlock;

@end
