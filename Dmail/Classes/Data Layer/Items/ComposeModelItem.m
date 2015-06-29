//
//  ComposeModelItem.m
//  Dmail
//
//  Created by Karen Petrosyan on 6/22/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "ComposeModelItem.h"

@implementation ComposeModelItem

- (instancetype)initWithSubject:(NSString *)subject body:(NSString *)body arrayTo:(NSArray *)to arrayCC:(NSArray *)CC arrayBCC:(NSArray *)BCC {
    
    self = [super init];
    if (self != nil) {
        self.subject = subject;
        self.body = body;
        self.arrayTo = [NSArray arrayWithArray:to];
        self.arrayCc = [NSArray arrayWithArray:CC];
        self.arrayBcc = [NSArray arrayWithArray:BCC];
    }
    
    return  self;
}

@end
