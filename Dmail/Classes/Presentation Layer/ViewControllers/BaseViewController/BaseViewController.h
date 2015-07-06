//
//  BaseViewController.h
//  Dmail
//
//  Created by Karen Petrosyan on 6/13/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileService.h"
#import "Constants.h"


@interface BaseViewController : UIViewController

- (void)showLoadingView;
- (void)hideLoadingView;

@end
