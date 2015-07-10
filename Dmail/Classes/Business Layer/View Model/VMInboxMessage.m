//
//  VMInboxMessage.m
//  Dmail
//
//  Created by Armen Mkrtchian on 7/9/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "VMInboxMessage.h"

#import "ModelMessage.h"

#import "UIColor+AppColors.h"
#import <NSDate+DateTools.h>

@implementation VMInboxMessage

- (instancetype)initWithModel:(ModelMessage *)modelMessage {
    
    self = [super init];
    if (self) {
        
        self.internalDate = modelMessage.internalDate;
        
        NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:_internalDate/1000];
        self.messageDate = [NSDate shortTimeAgoSinceDate:date];
        self.senderName = modelMessage.fromName;
        self.messageSubject = modelMessage.subject;
        self.messageIdentifier = modelMessage.messageIdentifier;
        self.read = modelMessage.read;
        self.imageUrl = modelMessage.imageUrl;
    }
    
    return self;
}

@end
