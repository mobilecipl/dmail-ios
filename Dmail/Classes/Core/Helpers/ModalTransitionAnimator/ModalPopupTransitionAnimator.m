//
//  ModalPopupTransitionAnimator.m
//  CustomModalTransition
//
//  Created by Armen on 20/12/14.
//  Copyright (c) 2014 Armen Mkrtchian. All rights reserved.
//

#import "ModalPopupTransitionAnimator.h"

CGFloat const kTransformPart1AnimationDuration = 0.2;
CGFloat const kTransformPart2AnimationDuration = 0.1;

static const CGFloat kAnimationFirstPartRatio = 0.6f;

@implementation ModalPopupTransitionAnimator

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController* destination = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    if([destination isBeingPresented]) {
        return 0.3;
    } else {
        return 0.3;
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
    toView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.4, 0.4);
    
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    [UIView animateKeyframesWithDuration:duration
                                   delay:0.0
                                 options:UIViewKeyframeAnimationOptionCalculationModeCubicPaced
                              animations:^{
                                  [UIView addKeyframeWithRelativeStartTime:0.0f
                                                          relativeDuration:kAnimationFirstPartRatio
                                                                animations:^{
                                                                    toView.alpha = 1;
                                                                    toView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
                                                                }];
                                  
                                  [UIView addKeyframeWithRelativeStartTime:kAnimationFirstPartRatio
                                                          relativeDuration:1.0f
                                                                animations:^{
                                                                    toView.alpha = 1;
                                                                    toView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
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
    
    [UIView animateWithDuration:kTransformPart2AnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        fromView.alpha = 1;
        fromView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
    } completion:^(BOOL finished2) {
        [UIView animateWithDuration:kTransformPart1AnimationDuration animations:^{
            fromView.alpha = 0;
            fromView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.4, 0.4);
        } completion:^(BOOL finished) {
            // Important: remove source view
            // Otherwise it may show up on rotation..
            [fromView removeFromSuperview];
            
            // Finish transition
            [transitionContext completeTransition:YES];
        }];
    }];
}

@end
