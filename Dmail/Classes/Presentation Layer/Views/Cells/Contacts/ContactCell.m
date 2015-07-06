//
//  ContactCell.m
//  Dmail
//
//  Created by Karen Petrosyan on 7/6/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "ContactCell.h"
#import "ContactModel.h"

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

- (void)configureCellWithContactModel:(ContactModel *)contactModel {
    
    self.labelFullName.text = contactModel.fullName;
    self.labelEmail.text = contactModel.email;
}

@end
