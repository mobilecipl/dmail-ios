//
//  BaseViewController.m
//  Dmail
//
//  Created by Karen Petrosyan on 6/13/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "BaseViewController.h"
#import "CustomAlertView.h"
#import "UIColor+AppColors.h"

@interface BaseViewController () <CustomAlertViewDelegate>

@property (nonatomic, strong) UIView *viewLoading;
@property (nonatomic, strong) UIView *viewMessageSent;
@property (nonatomic, strong) UIView *viewMessageDestroyed;
@property (nonatomic, assign) BOOL viewMessageSentVisible;
@property (nonatomic, assign) BOOL viewMessageDestroyedVisible;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@end

@implementation BaseViewController


#pragma mark - Class Methods
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.navigationController.navigationBar.hidden = YES;
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Public Methods
- (void)showErrorAlertWithTitle:(NSString *)title message:(NSString *)message {
    
    CustomAlertView *alertView = [[CustomAlertView alloc] initWithTitle:title
                                                               withFont:@"ProximaNova-Semibold"
                                                               withSize:20
                                                            withMessage:message
                                                        withMessageFont:@"ProximaNova-Regular"
                                                    withMessageFontSize:15
                                                         withDeactivate:NO];
    NSDictionary *cancelButton = @{@"title" : @"Ok",
                                   @"titleColor" : [UIColor whiteColor],
                                   @"backgroundColor" : [UIColor colorWithRed:120.0/255.0 green:132.0/255.0 blue:140.0/255.0 alpha:1],
                                   @"font" : @"ProximaNova-Regular",
                                   @"fontSize" : @"15"};
    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:cancelButton, nil]];
    [alertView setDelegate:self];
    [alertView setOnButtonTouchUpInside:^(CustomAlertView *alertView, int buttonIndex) {
        [alertView close];
    }];
    [alertView setUseMotionEffects:true];
    [alertView show];
}

- (void)showMessageSentSuccess {
    
    if (!self.viewMessageSentVisible) {
        if (!self.viewMessageSent) {
            self.viewMessageSent = [[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 42)];
            self.viewMessageSent.userInteractionEnabled = YES;
            self.viewMessageSent.backgroundColor = [UIColor cellSelected];
            [self.view addSubview:self.viewMessageSent];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.viewMessageSent.frame.size.width, self.viewMessageSent.frame.size.height)];
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor whiteColor];
            label.textAlignment = NSTextAlignmentCenter;
            label.text = @"success! your secure message has been sent";
            label.font = [UIFont fontWithName:@"ProximaNova-Light" size:15];
            [self.viewMessageSent addSubview:label];
        }
        self.viewMessageSentVisible = YES;
        [UIView animateWithDuration:0.5 animations:^{
            CGRect frame = self.viewMessageSent.frame;
            self.viewMessageSent.frame = CGRectMake(frame.origin.x, frame.origin.y - frame.size.height, frame.size.width, frame.size.height);
            [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(hideMessageSentSuccess) userInfo:nil repeats:NO];
        }];
    }
}

- (void)hideMessageSentSuccess {
    
    self.viewMessageSentVisible = NO;
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frame = self.viewMessageSent.frame;
        self.viewMessageSent.frame = CGRectMake(frame.origin.x, frame.origin.y + frame.size.height, frame.size.width, frame.size.height);
    }];
}

- (void)showPanelMessageDestroyedSuccess {
    
    if (!self.viewMessageDestroyedVisible) {
        if (!self.viewMessageDestroyed) {
            self.viewMessageDestroyed = [[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 42)];
            self.viewMessageDestroyed.userInteractionEnabled = YES;
            self.viewMessageDestroyed.backgroundColor = [UIColor cellDeleteButtonColor];
            [self.view addSubview:self.viewMessageDestroyed];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.viewMessageDestroyed.frame.size.width, self.viewMessageDestroyed.frame.size.height)];
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor whiteColor];
            label.textAlignment = NSTextAlignmentCenter;
            label.text = @"Message destroyed";
            label.font = [UIFont fontWithName:@"ProximaNova-Light" size:15];
            [self.viewMessageDestroyed addSubview:label];
        }
        self.viewMessageDestroyedVisible = YES;
        [UIView animateWithDuration:0.5 animations:^{
            CGRect frame = self.viewMessageDestroyed.frame;
            self.viewMessageDestroyed.frame = CGRectMake(frame.origin.x, frame.origin.y - frame.size.height, frame.size.width, frame.size.height);
            [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(hideMessageDestroyedSuccess) userInfo:nil repeats:NO];
        }];
    }
}

- (void)hideMessageDestroyedSuccess {
    
    self.viewMessageDestroyedVisible = NO;
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frame = self.viewMessageDestroyed.frame;
        self.viewMessageDestroyed.frame = CGRectMake(frame.origin.x, frame.origin.y + frame.size.height, frame.size.width, frame.size.height);
    }];
}

- (void)showLoadingView {
    
    if (!self.viewLoading) {
        self.viewLoading = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.viewLoading.userInteractionEnabled = YES;
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


#pragma mark - CustomAlertViewDelegate methods
- (void)customIOS7dialogButtonTouchUpInside:(CustomAlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex {
    
    [alertView close];
}

@end
