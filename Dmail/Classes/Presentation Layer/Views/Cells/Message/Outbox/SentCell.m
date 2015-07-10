//
//  SentCell.m
//  Dmail
//
//  Created by Armen Mkrtchian on 7/7/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "SentCell.h"

#import "UIImageView+WebCache.h"

#import "VMSentMessage.h"

NSString *const SentCellIdentifier = @"SentCellIdentifier";

@interface SentCell ()

@property (weak, nonatomic) IBOutlet UIView *viewBorder;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewProfile;
@property (weak, nonatomic) IBOutlet UILabel *labelSenderName;
@property (weak, nonatomic) IBOutlet UILabel *labelMessageSubject;

@end

@implementation SentCell


#pragma mark - Public Methods
- (void)configureCell:(VMSentMessage *)messageItem {
    
    self.labelSenderName.translatesAutoresizingMaskIntoConstraints = NO;
    self.labelMessageSubject.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.labelMessageSubject.text = messageItem.messageSubject;
    [self.labelSenderName setAttributedText:messageItem.senderName];
    if (messageItem.read) {
        
        self.viewBorder.hidden = YES;
    } else {
        
        self.viewBorder.hidden = NO;
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
