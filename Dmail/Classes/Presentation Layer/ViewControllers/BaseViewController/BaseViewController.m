//
//  BaseViewController.m
//  Dmail
//
//  Created by Karen Petrosyan on 6/13/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "BaseViewController.h"
#import "CustomAlertView.h"

@interface BaseViewController () <CustomAlertViewDelegate>

@property (nonatomic, strong) UIView *viewLoading;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@end

@implementation BaseViewController


#pragma mark - Class Methods
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.navigationController.navigationBar.hidden = YES;
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Public Methods
- (void)showLoadingView {
    
    if (!self.viewLoading) {
        self.viewLoading = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.viewLoading.userInteractionEnabled = NO;
        self.viewLoading.backgroundColor = [UIColor blackColor];
        self.viewLoading.alpha = 0.4;
        [self.view addSubview:self.viewLoading];
        
        self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        self.indicatorView.center = CGPointMake(self.view.center.x, self.view.center.y);
        [self.viewLoading addSubview:self.indicatorView];
        [self.indicatorView startAnimating];
    }
}

- (void)hideLoadingView {
    
    if(self.viewLoading) {
        [self.indicatorView stopAnimating];
        [self.indicatorView removeFromSuperview];
        [self.viewLoading removeFromSuperview];
    }
}

- (void)handleDestroyAccessSuccess {
    
    [self hideLoadingView];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dmail"
                                                    message:@"Participants are successfully destroyed"
                                                   delegate:self
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil, nil];
    [alert show];
}

- (void)handleDestroyAccessFailed {
    
    [self hideLoadingView];
    CustomAlertView *alertView = [[CustomAlertView alloc] initWithTitle:@"Revoke access?"
                                                               withFont:@"ProximaNova-Semibold"
                                                               withSize:20
                                                            withMessage:@"Are you sure you want to revoke acces to benoit@science-inc.com"
                                                        withMessageFont:@"ProximaNova-Regular"
                                                    withMessageFontSize:15
                                                         withDeactivate:NO];
    [alertView show];
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dmail"
//                                                    message:@"Destroy failed"
//                                                   delegate:self
//                                          cancelButtonTitle:@"Ok"
//                                          otherButtonTitles:nil, nil];
//    [alert show];
}

- (void)handleRevokeAccessSuccess {
    
    [self hideLoadingView];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dmail"
                                                    message:@"Participant is successfully revoked"
                                                   delegate:self
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil, nil];
    [alert show];
}

- (void)handleRevokeAccessFailed {
    
    [self hideLoadingView];
    CustomAlertView *alertView = [[CustomAlertView alloc] initWithTitle:@"Revoke access?"
                                                               withFont:@"ProximaNova-Semibold"
                                                               withSize:20
                                                            withMessage:@"Are you sure you want to revoke acces to benoit@science-inc.com"
                                                        withMessageFont:@"ProximaNova-Regular"
                                                    withMessageFontSize:15
                                                         withDeactivate:NO];
    NSDictionary *dictionaryButton1 = @{@"title" : @"Cancel",
                                       @"titleColor" : [UIColor whiteColor],
                                       @"backgroundColor" : [UIColor colorWithRed:120.0/255.0 green:132.0/255.0 blue:140.0/255.0 alpha:1],
                                       @"font" : @"ProximaNova-Regular",
                                       @"fontSize" : @"15"};
    NSDictionary *dictionaryButton2 = @{@"title" : @"Revoke",
                                        @"titleColor" : [UIColor whiteColor],
                                        @"backgroundColor" : [UIColor colorWithRed:215.0/255.0 green:34.0/255.0 blue:106.0/255.0 alpha:1],
                                        @"font" : @"ProximaNova-Regular",
                                        @"fontSize" : @"15"};
    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:dictionaryButton1,dictionaryButton2, nil]];
    [alertView setDelegate:self];
    [alertView setOnButtonTouchUpInside:^(CustomAlertView *alertView, int buttonIndex) {
        [alertView close];
    }];
    [alertView setUseMotionEffects:true];
    [alertView show];
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dmail"
//                                                    message:@"Revoke failed"
//                                                   delegate:self
//                                          cancelButtonTitle:@"Ok"
//                                          otherButtonTitles:nil, nil];
//    [alert show];
}

- (void)customIOS7dialogButtonTouchUpInside:(CustomAlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex {
    
    [alertView close];
}

@end
