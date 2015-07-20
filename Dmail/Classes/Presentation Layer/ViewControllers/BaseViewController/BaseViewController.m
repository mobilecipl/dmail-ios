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
    CustomAlertView *alertView = [[CustomAlertView alloc] initWithTitle:@"Dmail"
                                                               withFont:@"ProximaNova-Semibold"
                                                               withSize:20
                                                            withMessage:@"Participants are successfully destroyed"
                                                        withMessageFont:@"ProximaNova-Regular"
                                                    withMessageFontSize:15
                                                         withDeactivate:NO];
    NSDictionary *okButton = @{@"title" : @"Ok",
                               @"titleColor" : [UIColor whiteColor],
                               @"backgroundColor" : [UIColor colorWithRed:120.0/255.0 green:132.0/255.0 blue:140.0/255.0 alpha:1],
                               @"font" : @"ProximaNova-Regular",
                               @"fontSize" : @"15"};
    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:okButton, nil]];
    [alertView setDelegate:self];
    [alertView setOnButtonTouchUpInside:^(CustomAlertView *alertView, int buttonIndex) {
        [alertView close];
    }];
    [alertView setUseMotionEffects:true];
    [alertView show];
}

- (void)handleDestroyAccessFailed {
    
    [self hideLoadingView];
    CustomAlertView *alertView = [[CustomAlertView alloc] initWithTitle:@"Dmail"
                                                               withFont:@"ProximaNova-Semibold"
                                                               withSize:20
                                                            withMessage:@"Destroy failed"
                                                        withMessageFont:@"ProximaNova-Regular"
                                                    withMessageFontSize:15
                                                         withDeactivate:NO];
    NSDictionary *okButton = @{@"title" : @"Ok",
                               @"titleColor" : [UIColor whiteColor],
                               @"backgroundColor" : [UIColor colorWithRed:120.0/255.0 green:132.0/255.0 blue:140.0/255.0 alpha:1],
                               @"font" : @"ProximaNova-Regular",
                               @"fontSize" : @"15"};
    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:okButton, nil]];
    [alertView setDelegate:self];
    [alertView setOnButtonTouchUpInside:^(CustomAlertView *alertView, int buttonIndex) {
        [alertView close];
    }];
    [alertView setUseMotionEffects:true];
    [alertView show];
}

- (void)handleRevokeAccessSuccess {
    
    [self hideLoadingView];
    CustomAlertView *alertView = [[CustomAlertView alloc] initWithTitle:@"Dmail"
                                                               withFont:@"ProximaNova-Semibold"
                                                               withSize:20
                                                            withMessage:@"Participant is successfully revoked"
                                                        withMessageFont:@"ProximaNova-Regular"
                                                    withMessageFontSize:15
                                                         withDeactivate:NO];
    NSDictionary *okButton = @{@"title" : @"Ok",
                               @"titleColor" : [UIColor whiteColor],
                               @"backgroundColor" : [UIColor colorWithRed:120.0/255.0 green:132.0/255.0 blue:140.0/255.0 alpha:1],
                               @"font" : @"ProximaNova-Regular",
                               @"fontSize" : @"15"};
    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:okButton, nil]];
    [alertView setDelegate:self];
    [alertView setOnButtonTouchUpInside:^(CustomAlertView *alertView, int buttonIndex) {
        [alertView close];
    }];
    [alertView setUseMotionEffects:true];
    [alertView show];
}

- (void)handleRevokeAccessFailed {
    
    [self hideLoadingView];
    CustomAlertView *alertView = [[CustomAlertView alloc] initWithTitle:@"Dmail"
                                                               withFont:@"ProximaNova-Semibold"
                                                               withSize:20
                                                            withMessage:@"Revoke failed"
                                                        withMessageFont:@"ProximaNova-Regular"
                                                    withMessageFontSize:15
                                                         withDeactivate:NO];
    NSDictionary *okButton = @{@"title" : @"Ok",
                                       @"titleColor" : [UIColor whiteColor],
                                       @"backgroundColor" : [UIColor colorWithRed:120.0/255.0 green:132.0/255.0 blue:140.0/255.0 alpha:1],
                                       @"font" : @"ProximaNova-Regular",
                                       @"fontSize" : @"15"};
    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:okButton, nil]];
    [alertView setDelegate:self];
    [alertView setOnButtonTouchUpInside:^(CustomAlertView *alertView, int buttonIndex) {
        [alertView close];
    }];
    [alertView setUseMotionEffects:true];
    [alertView show];
}

- (void)customIOS7dialogButtonTouchUpInside:(CustomAlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex {
    
    [alertView close];
}

@end
