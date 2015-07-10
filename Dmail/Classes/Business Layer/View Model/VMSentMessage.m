//
//  VMSentMessage.m
//  Dmail
//
//  Created by Armen Mkrtchian on 7/10/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "VMSentMessage.h"

#import "ModelMessage.h"

#import "UIColor+AppColors.h"
#import <NSDate+DateTools.h>


@implementation VMSentMessage

- (instancetype)initWithModel:(ModelMessage *)modelMessage {
    
    self = [super init];
    if (self) {
        
        self.internalDate = modelMessage.internalDate;
        
        NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:_internalDate];
        self.messageDate = [NSDate shortTimeAgoSinceDate:date];
        
        self.senderName = [self senderNameAttributedWithName:modelMessage.from withDate:self.messageDate];
        
        self.messageSubject = modelMessage.subject;
        self.messageIdentifier = modelMessage.messageIdentifier;
        self.read = modelMessage.read;
    }
    
    return self;
}

- (NSAttributedString *)senderNameAttributedWithName:(NSString *)name withDate:(NSString *)date{
    
    NSString *nameWithTime = [NSString stringWithFormat:@"%@   %@", name, date];
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

//self.labelMessageSubject.translatesAutoresizingMaskIntoConstraints = YES;
//self.labelMessageSubject.frame = CGRectMake(15, self.labelMessageSubject.frame.origin.y, self.labelMessageSubject.frame.size.width, self.labelMessageSubject.frame.size.height);
//self.labelSenderName.translatesAutoresizingMaskIntoConstraints = YES;
//self.labelSenderName.frame = CGRectMake(15, self.labelSenderName.frame.origin.y, self.labelSenderName.frame.size.width, self.labelSenderName.frame.size.height);
//self.imageViewProfile.hidden = YES;
//self.viewBorder.hidden = YES;
//
////TODO:
//
//self.labelSenderName.text = messageItem.recipients;
//NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:[messageItem.internalDate doubleValue]/1000];
//NSString *time = [NSDate shortTimeAgoSinceDate:date];
//NSString * nameWithTime = [NSString stringWithFormat:@"%@   %@", self.labelSenderName.text, time];
//if (nameWithTime.length > 1) {
//    NSRange range = [nameWithTime rangeOfString:@"   "];
//    NSRange timeRange;
//    timeRange.location = range.location + 3;
//    timeRange.length = 2;
//    if (range.location != NSNotFound) {
//        NSMutableAttributedString * attributedText = [[NSMutableAttributedString alloc] initWithString:nameWithTime];
//        [attributedText addAttribute: NSFontAttributeName value:[UIFont fontWithName:@"ProximaNova-Regular" size:12] range:timeRange];
//        [attributedText addAttribute: NSForegroundColorAttributeName value:[UIColor cellTimeColor] range:timeRange]; // if needed
//        [self.labelSenderName setAttributedText:attributedText];
//    }
//}


@end
