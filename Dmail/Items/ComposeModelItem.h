//
//  ComposeModelItem.h
//  Dmail
//
//  Created by Karen Petrosyan on 6/22/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ComposeModelItem : NSObject

@property (nonatomic, strong) NSArray *arrayReceiversEmail;
@property (nonatomic, strong) NSString *subject;
@property (nonatomic, strong) NSString *body;

- (instancetype)initWithReceiverEmails:(NSArray *)arrayEmails subject:(NSString *)subject body:(NSString *)body;

@end
