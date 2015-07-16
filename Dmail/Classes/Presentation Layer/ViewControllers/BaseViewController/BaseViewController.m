//
//  BaseViewController.m
//  Dmail
//
//  Created by Karen Petrosyan on 6/13/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

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
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dmail"
                                                    message:@"Destroy failed"
                                                   delegate:self
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil, nil];
    [alert show];
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
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dmail"
                                                    message:@"Revoke failed"
                                                   delegate:self
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil, nil];
    [alert show];
}

@end
