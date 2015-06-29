//
//  BaseViewController.h
//  pium
//
//  Created by Armen Mkrtchian on 10/15/14.
//  Copyright (c) 2014 Armen Mkrtchian. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ErrorDataModel;

@interface BaseViewController : UIViewController

@property (nonatomic, getter = isReachable) BOOL reachable;
@property (nonatomic) BOOL statusBarHidden;

- (void)handleConnectionError:(ErrorDataModel *)error;

- (void)presentNoConnectionView;

- (void)showActivityIndicator;
- (void)hideActivityIndicator;

- (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
         cancelButtonTitle:(NSString *)cancelButtonTitle
              otherButtons:(NSArray *)otherButtons;

- (void)showActionSheetWithTitle:(NSString *)title
                         message:(NSString *)message
               cancelButtonTitle:(NSString *)cancelButtonTitle
                    otherButtons:(NSArray *)otherButtons;

- (void)trackScreenWithName:(NSString *)screenName;

- (void)presentActivityViewController:(NSArray *)objectsToShare;
@end
