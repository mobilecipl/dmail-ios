//
//  SentCell.m
//  Dmail
//
//  Created by Armen Mkrtchian on 7/7/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "SentCell.h"

#import "UIImageView+WebCache.h"

#import "VMSentMessageItem.h"

NSString *const SentCellIdentifier = @"SentCellIdentifier";

@interface SentCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageViewProfile;
@property (weak, nonatomic) IBOutlet UILabel *labelSenderName;
@property (weak, nonatomic) IBOutlet UILabel *labelDate;
@property (weak, nonatomic) IBOutlet UILabel *labelMessageSubject;

@end

@implementation SentCell


#pragma mark - Public Methods
- (void)configureCell:(VMSentMessageItem *)messageItem {
    
    self.labelSenderName.translatesAutoresizingMaskIntoConstraints = NO;
    self.labelMessageSubject.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.labelMessageSubject.text = messageItem.messageSubject;
    self.labelSenderName.text = messageItem.senderName;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
