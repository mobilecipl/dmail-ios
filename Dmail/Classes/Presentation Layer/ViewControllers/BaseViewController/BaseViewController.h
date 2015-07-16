//
//  BaseViewController.h
//  Dmail
//
//  Created by Karen Petrosyan on 6/13/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController

- (void)showLoadingView;
- (void)hideLoadingView;
- (void)handleDestroyAccessSuccess;
- (void)handleDestroyAccessFailed;
- (void)handleRevokeAccessSuccess;
- (void)handleRevokeAccessFailed;

@end
