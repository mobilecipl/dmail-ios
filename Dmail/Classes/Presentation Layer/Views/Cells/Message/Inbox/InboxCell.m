//
//  InboxCell.m
//  Dmail
//
//  Created by Gevorg Ghukasyan on 6/15/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "InboxCell.h"
#import "Constants.h"
#import "MessageItem.h"
#import "Profile.h"
#import "CoreDataManager.h"
#import <NSDate+DateTools.h>
#import "UIColor+AppColors.h"
#import "UIImageView+WebCache.h"


NSString *const InboxCellIdentifier = @"InboxCellIdentifier";

@interface InboxCell ()

@property (weak, nonatomic) IBOutlet UIView *viewBorder;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewProfile;
@property (weak, nonatomic) IBOutlet UILabel *labelSenderName;
@property (weak, nonatomic) IBOutlet UILabel *labelMessageSubject;

@end

@implementation InboxCell


#pragma mark - Publioc Methods
- (void)configureCell:(MessageItem *)messageItem {
    
    self.labelMessageSubject.text = messageItem.subject;
    
    self.labelSenderName.translatesAutoresizingMaskIntoConstraints = NO;
    self.labelMessageSubject.translatesAutoresizingMaskIntoConstraints = NO;
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:[messageItem.internalDate doubleValue]/1000];
    NSString *time = [NSDate shortTimeAgoSinceDate:date];
    
    NSString * nameWithTime = [NSString stringWithFormat:@"%@   %@", messageItem.fromEmail, time];
    if (nameWithTime.length > 1) {
        NSRange range = [nameWithTime rangeOfString:@"   "];
        NSRange timeRange;
        timeRange.location = range.location + 3;
        timeRange.length = 2;
        if (range.location != NSNotFound) {
            NSMutableAttributedString * attributedText = [[NSMutableAttributedString alloc] initWithString:nameWithTime];
            [attributedText addAttribute: NSFontAttributeName value:[UIFont fontWithName:@"ProximaNova-Regular" size:12] range:timeRange];
            [attributedText addAttribute: NSForegroundColorAttributeName value:[UIColor cellTimeColor] range:timeRange]; // if needed
            [self.labelSenderName setAttributedText:attributedText];
        }
    }
    
    switch (messageItem.type) {
        case Unread:
            self.viewBorder.hidden = NO;
            [[CoreDataManager sharedCoreDataManager] changeMessageTypeWithMessageId:messageItem.dmailId messageType:Read];
            break;
        case Read:
            self.viewBorder.hidden = YES;
            break;
            
        default:
            break;
    }
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
