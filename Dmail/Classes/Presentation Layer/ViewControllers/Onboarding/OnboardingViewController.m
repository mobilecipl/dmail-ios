//
//  OnboardingViewController.m
//  Dmail
//
//  Created by Karen Petrosyan on 7/29/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "OnboardingViewController.h"
#import "ServiceSync.h"

@interface OnboardingViewController ()

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIPageControl *pageControll;
@property (nonatomic, weak) IBOutlet UIButton *buttonLetsGo;

@property (nonatomic, strong) ServiceSync *serviceSync;

@end

@implementation OnboardingViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.serviceSync = [[ServiceSync alloc] init];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    self.scrollView.contentSize = CGSizeMake(3 * [UIScreen mainScreen].bounds.size.width, 0);
    self.buttonLetsGo.layer.cornerRadius = 3;
}


#pragma mark - UIScrollViewDelegate Methods
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    self.pageControll.currentPage = scrollView.contentOffset.x/self.scrollView.frame.size.width;
}


#pragma mark - Action Methods
- (IBAction)letsGoClicked:(id)sender {
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:SetupPin]) {
        [self performSegueWithIdentifier:@"fromOnboardingToSetPin" sender:self];
    }
    else {
        [self performSegueWithIdentifier:@"fromOnboardingToInbox" sender:self];
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:OnboardingWasShowed];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.serviceSync sync];
}

- (IBAction)pageControllClicked:(id)sender {
    
    UIPageControl *pageControl = (UIPageControl *)sender;
    [self.scrollView scrollRectToVisible:CGRectMake(pageControl.currentPage*[UIScreen mainScreen].bounds.size.width, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) animated:YES];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.scrollView.contentOffset = CGPointMake(pageControl.currentPage*[UIScreen mainScreen].bounds.size.width, 0);
        [self.view layoutIfNeeded];
    }];
}

@end
