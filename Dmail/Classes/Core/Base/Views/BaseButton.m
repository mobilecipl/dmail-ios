//
//  BaseButton.m
//  pium
//
//  Created by Armen Mkrtchian on 10/15/14.
//  Copyright (c) 2014 Armen Mkrtchian. All rights reserved.
//

#import "BaseButton.h"

//#import <Analytics.h>

#import <objc/objc.h>
#import <objc/runtime.h>

@implementation BaseButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    [self trackCurrentAction];
    [super touchesEnded:touches withEvent:event];
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state {
    [super setTitle:title forState:state];
    if (!self.accessibilityLabel && state == UIControlStateNormal) {
        self.accessibilityLabel = title;
    }
}

- (void)trackCurrentAction {
    NSString *currentActionName = self.accessibilityLabel;
    if ([currentActionName isKindOfClass:[NSString class]]) {
        currentActionName = [@"Pressed " stringByAppendingString:currentActionName];
//        [[SEGAnalytics sharedAnalytics] track:currentActionName
//                                   properties:nil];
    }
}

@end
