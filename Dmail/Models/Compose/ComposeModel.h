//
//  ComposeModel.h
//  Dmail
//
//  Created by Karen Petrosyan on 6/22/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ComposeModelItem;


@interface ComposeModel : NSObject

- (void)sendMessageWithItem:(ComposeModelItem *)composeModelItem completionBlock:(void (^)(BOOL success))completion;

@end
