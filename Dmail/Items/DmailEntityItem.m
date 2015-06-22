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
        self.receiverEmail = nil;
        
        self.type = -1;
        self.position = -1;
        self.status = -1;
    }
    
    return  self;
}

@end
