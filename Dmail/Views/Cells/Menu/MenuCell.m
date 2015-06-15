//
//  MenuCell.m
//  Dmail
//
//  Created by Gevorg Ghukasyan on 6/15/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "MenuCell.h"

@interface MenuCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageViewType;
@property (weak, nonatomic) IBOutlet UILabel *labelText;

@end

@implementation MenuCell

- (void)configureCell:(NSDictionary *)viewModel {
    self.imageViewType.image = [[UIImage imageNamed:[viewModel objectForKey:@"image"]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    
    [self.imageViewType setTintColor:[viewModel objectForKey:@"color"]];
    
    self.labelText.text = [viewModel objectForKey:@"text"];
    self.labelText.textColor = [viewModel objectForKey:@"color"];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
