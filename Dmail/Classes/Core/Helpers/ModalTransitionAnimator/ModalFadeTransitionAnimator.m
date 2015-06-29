//
//  ModalFadeTransitionAnimator.m
//  CustomModalTransition
//
//  Created by Armen on 20/12/14.
//  Copyright (c) 2014 Armen Mkrtchian. All rights reserved.
//

#import "ModalFadeTransitionAnimator.h"

@implementation ModalFadeTransitionAnimator

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController* destination = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    if([destination isBeingPresented]) {
        return 0.15;
    } else {
        return 0.1;
    }
    
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *toView = toVC.view;
    UIView *fromView = fromVC.view;
    
    if([toVC isBeingPresented]) {
        [self animateTransition:transitionContext fromVC:fromVC toVC:toVC fromView:fromView toView:toView];
    } else {
        [self animateDismissal:transitionContext fromVC:fromVC toVC:toVC fromView:fromView toView:toView];
    }
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext fromVC:(UIViewController *)fromVC toVC:(UIViewController *)toVC fromView:(UIView *)fromView toView:(UIView *)toView {
    
    // Add the toView to the container
    UIView* containerView = [transitionContext containerView];
    [containerView addSubview:toView];
    
    toView.alpha = 0;
    toView.layer.shouldRasterize = NO;
    
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    [UIView animateKeyframesWithDuration:duration
                                   delay:0.0
                                 options:UIViewKeyframeAnimationOptionCalculationModeCubicPaced
                              animations:^{
                                  [UIView addKeyframeWithRelativeStartTime:0.0f
                                                          relativeDuration:1.0
                                                                animations:^{
                                                                    toView.alpha = 1;
                                                                }];
                              } completion:^(BOOL finished) {
                                  // Important: remove source view
                                  // Otherwise it may show up on rotation..
                                  [fromView removeFromSuperview];
                                  
                                  // End appearance transition for source controller
                                  //                                  [toVC endAppearanceTransition];
                                  
                                  // Finish transition
                                  [transitionContext completeTransition:YES];
                              }];
}

- (void)animateDismissal:(id<UIViewControllerContextTransitioning>)transitionContext fromVC:(UIViewController *)fromVC toVC:(UIViewController *)toVC fromView:(UIView *)fromView toView:(UIView *)toView {
    // Add the toView to the container
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:toView];
    [containerView sendSubviewToBack:toView];
    
    fromView.layer.shouldRasterize = NO;
    
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        fromView.alpha = 0;
    } completion:^(BOOL finished2) {
        // Important: remove source view
        // Otherwise it may show up on rotation..
        [fromView removeFromSuperview];
        
        // Finish transition
        [transitionContext completeTransition:YES];
    }];
}

@end
