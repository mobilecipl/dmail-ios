//
//  CALayer+UIColorToCGColor.m
//  tabloid
//
//  Created by Gevorg Ghukasyan on 4/23/15.
//  Copyright (c) 2015 Science Inc. All rights reserved.
//

#import "CALayer+UIColorToCGColor.h"

@implementation CALayer (UIColorToCGColor)

-(UIColor *)borderColorFromUIColor {
    return [UIColor colorWithCGColor:self.borderColor];
}

-(void)setBorderColorFromUIColor:(UIColor *)borderColorFromUIColor {
    
    self.borderColor = borderColorFromUIColor.CGColor;
}

@end
