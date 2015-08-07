//
//  BaseViewController.h
//  Dmail
//
//  Created by Karen Petrosyan on 6/13/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseNavigationController.h"

@interface BaseViewController : UIViewController

- (void)showLoadingView;
- (void)hideLoadingView;
- (void)showMessageSentSuccess;
- (void)showMessageDestroyedSuccess:(BOOL)revoke;

@end
