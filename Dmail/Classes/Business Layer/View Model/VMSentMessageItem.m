//
//  VMSentMessageItem.m
//  Dmail
//
//  Created by Armen Mkrtchian on 7/10/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "VMSentMessageItem.h"

#import "ModelMessage.h"
#import "ModelSentMessage.h"

#import "UIColor+AppColors.h"
#import <NSDate+DateTools.h>


@implementation VMSentMessageItem

- (instancetype)initWithModel:(ModelSentMessage *)modelMessage {
    
    self = [super init];
    if (self) {
        self.internalDate = modelMessage.internalDate;
        NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:self.internalDate/1000];
        NSInteger days = [[NSDate date] daysFrom:date];
        if (days > 30) {
            self.messageDate = [NSString stringWithFormat:@"%ldw",(long)days/7];
        }
        else {
            self.messageDate = [NSDate shortTimeAgoSinceDate:date];
        }
        self.recipientName = modelMessage.recipientName;
        self.messageSubject = modelMessage.subject;
        self.messageId = modelMessage.messageId;
    }
    
    return self;
}

@end
