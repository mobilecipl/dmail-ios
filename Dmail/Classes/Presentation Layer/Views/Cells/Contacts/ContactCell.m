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
    
    self.labelEmail.text = contactModel.email;
    self.labelFullName.text = [NSString stringWithFormat:@"%@ %@", contactModel.firstName, contactModel.lastName];
    
//    [self.labelEmail setAttributedText: attributedEmail];
//    NSString * strEmail = contactModel.email;
//    strEmail = [strEmail lowercaseString];
//    if (strEmail.length > 1) {
//        NSRange range = [strEmail rangeOfString:searchtext];
//        if (range.location != NSNotFound) {
//            NSMutableAttributedString * attributedEmail = [[NSMutableAttributedString alloc] initWithString:contactModel.email];
//            [attributedEmail addAttribute: NSFontAttributeName value:[UIFont fontWithName:@"ProximaNova-Semibold" size:16] range:range];
//            [attributedEmail addAttribute: NSForegroundColorAttributeName value:[UIColor redColor] range:range];
//            [self.labelEmail setAttributedText: attributedEmail];
//        }
//    }
//    
//    NSString * strFirstName = contactModel.firstName;
//    strFirstName = [strFirstName lowercaseString];
//    if (strFirstName.length > 1) {
//        NSRange range = [strFirstName rangeOfString:searchtext];
//        if (range.location != NSNotFound) {
//            NSMutableAttributedString * attributedEmail = [[NSMutableAttributedString alloc] initWithString:contactModel.fullName];
//            [attributedEmail addAttribute: NSFontAttributeName value:[UIFont fontWithName:@"ProximaNova-Semibold" size:16] range:range];
//            [attributedEmail addAttribute: NSForegroundColorAttributeName value:[UIColor redColor] range:range];
//            [self.labelFullName setAttributedText: attributedEmail];
//        }
//    }
//    
//    NSString * strlastName = contactModel.lastName;
//    strlastName = [strlastName lowercaseString];
//    if (strlastName.length > 1) {
//        NSRange range = [strlastName rangeOfString:searchtext];
//        if (range.location != NSNotFound) {
//            NSMutableAttributedString * attributedEmail = [[NSMutableAttributedString alloc] initWithString:contactModel.fullName];
//            [attributedEmail addAttribute: NSFontAttributeName value:[UIFont fontWithName:@"ProximaNova-Semibold" size:16] range:range];
//            [attributedEmail addAttribute: NSForegroundColorAttributeName value:[UIColor redColor] range:range];
//            [self.labelFullName setAttributedText: attributedEmail];
//        }
//    }
}

@end
