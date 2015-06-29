//
//  BaseNavigationController.m
//  pium
//
//  Created by Armen Mkrtchian on 10/15/14.
//  Copyright (c) 2014 Armen Mkrtchian. All rights reserved.
//

#import "BaseNavigationController.h"

@interface BaseNavigationController ()

@end

@implementation BaseNavigationController

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    // Do any additional setup after loading the view.
    [self setUpAppearance];
}

#pragma mark - Private Methods -

/*!
 * setUpAppearance
 *
 * Discussion:
 * Set up appearance. Navigation bar background color, title color, sizes.
 * http://stackoverflow.com/questions/19029833/ios-7-navigation-bar-text-and-arrow-color
 */
- (void)setUpAppearance {
    self.navigationBar.translucent = YES;
    
    if (self.navigationBarHidden) {
        self.view.frame = kScreenBounds;
    } else {
        CGRect frame = kScreenBounds;
        frame.size.height -= self.navigationBar.frame.size.height;
        frame.size.height -= 20;
        self.view.frame = frame;
    }
    
    /* UINavigationBar appearance */
    [[UINavigationBar appearance] setBarTintColor:UIColorFromRGB(0xced6e0)];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],
                                                           NSFontAttributeName:[UIFont systemFontOfSize:20]}];
    
    [self setNeedsStatusBarAppearanceUpdate];
}

/*!
 * preferredStatusBarStyle
 *
 * Discussion:
 * These methods control the attributes of the status bar when this view controller is shown.
 * They can be overridden in view controller subclasses to return the desired status bar attributes.
 */
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
