//
//  VMInboxMessageItem.m
//  Dmail
//
//  Created by Armen Mkrtchian on 7/9/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "VMInboxMessageItem.h"

#import "ModelInboxMessage.h"

#import "UIColor+AppColors.h"
#import <NSDate+DateTools.h>

@implementation VMInboxMessageItem

- (instancetype)initWithModel:(ModelInboxMessage *)modelMessage {
    
    self = [super init];
    if (self) {
        NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:modelMessage.internalDate/1000];
        self.messageDate = [NSDate shortTimeAgoSinceDate:date];
        self.body = modelMessage.body;
        self.senderName = modelMessage.fromName;
        self.senderEmail = modelMessage.fromEmail;
        self.messageSubject = modelMessage.subject;
        self.imageUrl = modelMessage.imageUrl;
        self.messageId = modelMessage.messageId;
        self.read = modelMessage.read;
    }
    
    return self;
}

@end
