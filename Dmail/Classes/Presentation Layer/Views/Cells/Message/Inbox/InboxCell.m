//
//  InboxCell.m
//  Dmail
//
//  Created by Gevorg Ghukasyan on 6/15/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "InboxCell.h"

#import "UIImageView+WebCache.h"

#import "VMInboxMessage.h"

#import "UIImageView+WebCache.h"

#import "ServiceProfile.h"

NSString *const InboxCellIdentifier = @"InboxCellIdentifier";

@interface InboxCell ()

@property (weak, nonatomic) IBOutlet UIView *viewBorder;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewProfile;
@property (weak, nonatomic) IBOutlet UILabel *labelSenderName;
@property (weak, nonatomic) IBOutlet UILabel *labelMessageSubject;

@end

@implementation InboxCell


#pragma mark - Publioc Methods
- (void)configureCell:(VMInboxMessage *)messageItem {
    
    self.imageViewProfile.layer.masksToBounds = YES;
    self.imageViewProfile.layer.cornerRadius = self.imageViewProfile.frame.size.width/2;
    self.labelSenderName.translatesAutoresizingMaskIntoConstraints = NO;
    self.labelMessageSubject.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.labelMessageSubject.text = messageItem.messageSubject;
    [self.labelSenderName setAttributedText:messageItem.senderName];
    if (messageItem.read) {
        self.viewBorder.hidden = YES;
    } else {
        
        self.viewBorder.hidden = NO;
    }
    
    NSString *imageUrl;
    if([messageItem.senderEmail isEqualToString:[[ServiceProfile sharedInstance] email]]) {
        imageUrl = [[ServiceProfile sharedInstance] imageUrl];
    }
    else {
        NSString *token = [[ServiceProfile sharedInstance] token];
        imageUrl = [NSString stringWithFormat:@"%@?access_token=%@",messageItem.imageUrl,token];
    }
    
    [SDWebImageManager.sharedManager downloadImageWithURL:[NSURL URLWithString:imageUrl] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
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
