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
    if (messageItem.label == Sent) {
        self.labelMessageSubject.translatesAutoresizingMaskIntoConstraints = YES;
        self.labelMessageSubject.frame = CGRectMake(15, self.labelMessageSubject.frame.origin.y, self.labelMessageSubject.frame.size.width, self.labelMessageSubject.frame.size.height);
        self.labelSenderName.translatesAutoresizingMaskIntoConstraints = YES;
        self.labelSenderName.frame = CGRectMake(15, self.labelSenderName.frame.origin.y, self.labelSenderName.frame.size.width, self.labelSenderName.frame.size.height);
        self.imageViewProfile.hidden = YES;
        self.viewBorder.hidden = YES;
        Profile *profile = [[CoreDataManager sharedCoreDataManager] getProfileWithEmail:[messageItem.arrayTo firstObject]];
        if (profile.name.length > 0) {
            self.labelSenderName.text = profile.name;
        }
        else {
            self.labelSenderName.text = profile.email;
        }
    }
    else {
        self.imageViewProfile.hidden = NO;
        self.labelSenderName.translatesAutoresizingMaskIntoConstraints = NO;
        self.labelMessageSubject.translatesAutoresizingMaskIntoConstraints = NO;
        self.labelSenderName.text = messageItem.fromEmail;
        switch (messageItem.type) {
            case Unread:
                self.viewBorder.hidden = NO;
                break;
            case Read:
                self.viewBorder.hidden = YES;
                break;
                
            default:
                break;
        }
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
