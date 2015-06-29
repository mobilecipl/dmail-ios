//
//  CALayer+UIColorToCGColor.m
//  Dmail
//
//  Created by Gevorg Ghukasyan on 6/12/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "CALayer+UIColorToCGColor.h"

@implementation CALayer (UIColorToCGColor)

// border
- (UIColor *)borderColorFromUIColor {
    return [UIColor colorWithCGColor:self.borderColor];
}

- (void)setBorderColorFromUIColor:(UIColor *)borderColorFromUIColor {
    
    self.borderColor = borderColorFromUIColor.CGColor;
}

// shadow
- (UIColor *)shadowColorFromUIColor {
    return [UIColor colorWithCGColor:self.borderColor];
}

- (void)setShadowColorFromUIColor:(UIColor *)borderColorFromUIColor {
    
    self.borderColor = borderColorFromUIColor.CGColor;
}

@end
