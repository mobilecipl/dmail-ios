//
//  UIColor+AppColors.m
//  Dmail
//
//  Created by Karen Petrosyan on 6/14/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "UIColor+AppColors.h"

@implementation UIColor (AppColors)

+ (UIColor *)borderColor {
    
    return [UIColor colorWithRed:197.0/255.0 green:215.0/255.0 blue:227.0/255.0 alpha:1];
}

+ (UIColor *)navigationShadowColor {
    
    return [UIColor colorWithRed:207.0/255.0 green:221/255.0 blue:231.0/255.0 alpha:1];
}

+ (UIColor *)cellSelected {
    
    return [UIColor colorWithRed:75.0/255.0 green:184.0/255.0 blue:178.0/255.0 alpha:1];
}

+ (UIColor *)participantsColor {
    
    return [UIColor colorWithRed:75.0/255.0 green:184.0/255.0 blue:178.0/255.0 alpha:1];
}

@end
