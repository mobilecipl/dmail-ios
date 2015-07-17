//
//  BaseNavigationController.m
//  Dmail
//
//  Created by Karen Petrosyan on 7/17/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "BaseNavigationController.h"

@implementation BaseNavigationController

- (void)drawRect:(CGRect)rect {

    self.layer.masksToBounds = NO;
    self.layer.shadowOffset = CGSizeMake(0, 2);
    self.layer.shadowColor = [UIColor colorWithRed:197.0/255.0 green:215.0/255.0 blue:227.0/255.0 alpha:1].CGColor;
    self.layer.shadowRadius = 5;
    self.layer.shadowOpacity = 0.8;
}

@end
