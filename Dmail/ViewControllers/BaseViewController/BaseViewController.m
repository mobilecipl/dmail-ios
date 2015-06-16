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

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}


#pragma mark - Public Methods
- (void)showLoadingView {
    
    if (!self.viewLoading) {
        self.viewLoading = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
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

@end
