//
//  ComposeModelItem.m
//  Dmail
//
//  Created by Karen Petrosyan on 6/22/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "ComposeModelItem.h"

@implementation ComposeModelItem

- (instancetype)initWithReceiverEmails:(NSArray *)arrayEmails subject:(NSString *)subject body:(NSString *)body {
    
    self = [super init];
    if (self != nil) {
        self.arrayReceiversEmail = [NSArray arrayWithArray:arrayEmails];
        self.subject = subject;
        self.body = body;
    }
    
    return  self;
}

@end
