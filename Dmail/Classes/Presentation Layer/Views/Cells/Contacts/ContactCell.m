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
    
    self.labelFullName.text = contactModel.fullName;
    self.labelEmail.text = contactModel.email;
    
//    NSString *boldFontName = [[UIFont boldSystemFontOfSize:12] fontName];
//    NSString *yourString = contactModel.fullName;
//    NSRange boldedRange = NSMakeRange(1, 2);
//    
//    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:yourString];
//    
//    [attrString beginEditing];
//    [attrString addAttribute:kCTFontAttributeName value:boldFontName range:boldedRange];
//    [attrString endEditing];
//    
//    NSString *myString = contactModel.fullName;
//    NSAttributedString *myBoldString = [[NSAttributedString alloc] initWithString:myString attributes:@{ NSFontAttributeName: [UIFont boldSystemFontOfSize:8.0] }];
//    self.labelFullName.attributedText = myBoldString;
    
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
