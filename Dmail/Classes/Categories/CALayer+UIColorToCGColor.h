//
//  CALayer+UIColorToCGColor.h
//  Dmail
//
//  Created by Gevorg Ghukasyan on 6/12/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface CALayer (UIColorToCGColor)

@property (nonatomic, strong) UIColor *borderColorFromUIColor;
@property (nonatomic, strong) UIColor *shadowColorFromUIColor;

@end
