//
//  DmailEntityItem.m
//  Dmail
//
//  Created by Karen Petrosyan on 6/22/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "DmailEntityItem.h"

@implementation DmailEntityItem

- (instancetype)initWithClearObjects {
    
    self = [super init];
    if (self != nil) {
        self.dmailId = nil;
        self.identifier = nil;
        self.subject = nil;
        self.senderName = nil;
        self.access = nil;
        self.senderEmail = nil;
        self.body = nil;
        self.publicKey = nil;
        self.receiverEmail = nil;
        
        self.type = 0;
        self.label = 0;
        self.position = -1;
        self.status = 0;
        
        self.arrayTo = nil;
        self.arrayCc = nil;
        self.arrayBcc = nil;
    }
    
    return  self;
}

@end
