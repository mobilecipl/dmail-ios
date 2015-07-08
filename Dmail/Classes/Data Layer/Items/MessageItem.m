//
//  MessageItem.m
//  Dmail
//
//  Created by Karen Petrosyan on 6/21/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "MessageItem.h"
#import "RMModelGmailMessage.h"

@implementation MessageItem

- (instancetype)initWithRealmModel:(RMModelGmailMessage *)rmModel {
    
    self = [super init];
    if (self) {
        self.dmailId = rmModel.dmailId;
        self.identifier = rmModel.identifier;
        self.subject = rmModel.subject;
    }
    
    return self;
}

@end
