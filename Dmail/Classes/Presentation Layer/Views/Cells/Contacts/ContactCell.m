//
//  ContactCell.m
//  Dmail
//
//  Created by Karen Petrosyan on 7/6/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "ContactCell.h"
#import "ContactModel.h"
#import <CoreText/CoreText.h>

@interface ContactCell ()

@property (weak, nonatomic) IBOutlet UILabel *labelFullName;
@property (weak, nonatomic) IBOutlet UILabel *labelEmail;

@end

@implementation ContactCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureCellWithContactModel:(ContactModel *)contactModel searchText:(NSString *)searchtext{
    
    NSString * strEmail = contactModel.email;
    strEmail = [strEmail lowercaseString];
    if (strEmail.length > 1) {
        NSRange range = [strEmail rangeOfString:searchtext];
        if (range.location != NSNotFound) {
            NSMutableAttributedString * attributedEmail = [[NSMutableAttributedString alloc] initWithString:contactModel.email];
            [attributedEmail addAttribute: NSFontAttributeName value:[UIFont fontWithName:@"ProximaNova-Semibold" size:16] range:range];
            [attributedEmail addAttribute: NSForegroundColorAttributeName value:[UIColor redColor] range:range]; // if needed
            [self.labelEmail setAttributedText: attributedEmail];
        }
    }
    
    NSString * strFullName = contactModel.fullName;
    strFullName = [strFullName lowercaseString];
    if (strFullName.length > 1) {
        NSRange range = [strFullName rangeOfString:searchtext];
        if (range.location != NSNotFound) {
            NSMutableAttributedString * attributedEmail = [[NSMutableAttributedString alloc] initWithString:contactModel.fullName];
            [attributedEmail addAttribute: NSFontAttributeName value:[UIFont fontWithName:@"ProximaNova-Semibold" size:16] range:range];
            [attributedEmail addAttribute: NSForegroundColorAttributeName value:[UIColor redColor] range:range]; // if needed
            [self.labelFullName setAttributedText: attributedEmail];
        }
    }
}

@end
