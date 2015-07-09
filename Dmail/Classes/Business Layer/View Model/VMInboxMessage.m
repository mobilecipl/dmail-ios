//
//  VMInboxMessage.m
//  Dmail
//
//  Created by Armen Mkrtchian on 7/9/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "VMInboxMessage.h"

#import "UIColor+AppColors.h"

#import <NSDate+DateTools.h>

@implementation VMInboxMessage

- (NSString *)messageDate {
    
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:[_messageDate doubleValue]];
    NSString *time = [NSDate shortTimeAgoSinceDate:date];
    
    return time;
}

- (NSString *)senderName {
    
    return _senderName;
}

- (NSAttributedString *)senderNameAttributed {
    
    NSString *nameWithTime = [NSString stringWithFormat:@"%@   %@", _senderName, self.messageDate];
    NSMutableAttributedString * attributedText = [[NSMutableAttributedString alloc] initWithString:nameWithTime];
    if (nameWithTime.length > 1) {
        NSRange range = [nameWithTime rangeOfString:@"   "];
        NSRange timeRange;
        timeRange.location = range.location + 3;
        timeRange.length = 2;
        if (range.location != NSNotFound) {
            
            [attributedText addAttribute: NSFontAttributeName value:[UIFont fontWithName:@"ProximaNova-Regular" size:12] range:timeRange];
            [attributedText addAttribute: NSForegroundColorAttributeName value:[UIColor cellTimeColor] range:timeRange]; // if needed
        }
    }
    
    return attributedText;
}

@end
