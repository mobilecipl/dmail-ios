//
//  BaseLabel.m
//  pium
//
//  Created by Armen Mkrtchian on 10/15/14.
//  Copyright (c) 2014 Armen Mkrtchian. All rights reserved.
//

#import "BaseLabel.h"

@implementation BaseLabel

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
