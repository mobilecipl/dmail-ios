//
//  InboxCell.m
//  Dmail
//
//  Created by Gevorg Ghukasyan on 6/15/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "InboxCell.h"

#import "UIImageView+WebCache.h"

#import "VMInboxMessageItem.h"

#import "UIImageView+WebCache.h"

#import "ServiceProfile.h"

NSString *const InboxCellIdentifier = @"InboxCellIdentifier";

@interface InboxCell ()

@property (weak, nonatomic) IBOutlet UIView *viewBorder;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewProfile;
@property (weak, nonatomic) IBOutlet UILabel *labelSenderName;
@property (weak, nonatomic) IBOutlet UILabel *labelDate;
@property (weak, nonatomic) IBOutlet UILabel *labelMessageSubject;

@end

@implementation InboxCell


#pragma mark - Publioc Methods
- (void)configureCell:(VMInboxMessageItem *)messageItem {
    
    self.imageViewProfile.layer.masksToBounds = YES;
    self.imageViewProfile.layer.cornerRadius = self.imageViewProfile.frame.size.width/2;
    self.labelSenderName.translatesAutoresizingMaskIntoConstraints = NO;
    self.labelMessageSubject.translatesAutoresizingMaskIntoConstraints = NO;

    self.labelSenderName.text = messageItem.senderName;
    self.labelDate.text = messageItem.messageDate;
    self.labelMessageSubject.text = messageItem.messageSubject;
    if (messageItem.read) {
        self.viewBorder.hidden = YES;
    } else {
        
        self.viewBorder.hidden = NO;
    }
    [SDWebImageManager.sharedManager downloadImageWithURL:[NSURL URLWithString:messageItem.imageUrl] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        if (image) {
            [self.imageViewProfile setImage:image];
        }
    }];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
