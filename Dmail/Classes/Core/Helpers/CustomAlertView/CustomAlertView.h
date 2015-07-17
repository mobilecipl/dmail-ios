//
//  CustomAlertView.h
//  tapchat
//
//  Created by Karen Petrosyan on 8/20/14.
//  Copyright (c) 2014 Karen Petrosyan. All rights reserved.
//


@protocol CustomAlertViewDelegate

- (void)customIOS7dialogButtonTouchUpInside:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end


@interface CustomAlertView : UIView <CustomAlertViewDelegate>

@property (nonatomic, retain) UIView *parentView;
@property (nonatomic, retain) UIView *dialogView;
@property (nonatomic, retain) UIView *containerView;

@property (nonatomic, assign) id<CustomAlertViewDelegate> delegate;
@property (nonatomic, retain) NSArray *buttonTitles;
@property (nonatomic, assign) BOOL useMotionEffects;

@property (copy) void (^onButtonTouchUpInside)(CustomAlertView *alertView, int buttonIndex) ;

- (id)initWithTitle:(NSString *)title
           withFont:(NSString *)fontName
           withSize:(CGFloat)fontSize
        withMessage:(NSString *)message
    withMessageFont:(NSString *)messageFontName
withMessageFontSize:(CGFloat)messageFontSize
     withDeactivate:(BOOL)deactivate;
- (void)show;
- (void)close;
- (void)setOnButtonTouchUpInside:(void (^)(CustomAlertView *alertView, int buttonIndex))onButtonTouchUpInside;
- (void)deviceOrientationDidChange: (NSNotification *)notification;
- (void)dealloc;
- (IBAction)customIOS7dialogButtonTouchUpInside:(id)sender;

@end
