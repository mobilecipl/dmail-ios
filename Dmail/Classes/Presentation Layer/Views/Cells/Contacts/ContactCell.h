//
//  ContactCell.h
//  Dmail
//
//  Created by Karen Petrosyan on 7/6/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ContactModel;

@interface ContactCell : UITableViewCell

- (void)configureCellWithContactModel:(ContactModel *)contactModel;

@end
