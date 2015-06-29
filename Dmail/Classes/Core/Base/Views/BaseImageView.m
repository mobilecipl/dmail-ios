//
//  BaseImageView.m
//  pium
//
//  Created by Armen Mkrtchian on 21/12/14.
//  Copyright (c) 2014 Armen Mkrtchian. All rights reserved.
//

#import "BaseImageView.h"

@implementation BaseImageView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentMode = UIViewContentModeScaleAspectFit;
    }
    return self;
}

@end
