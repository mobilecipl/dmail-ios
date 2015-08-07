//
//  CustomAlertView.m
//  tapchat
//
//  Created by Karen Petrosyan on 8/20/14.
//  Copyright (c) 2014 Karen Petrosyan. All rights reserved.
//

#import "CustomAlertView.h"
#import <QuartzCore/QuartzCore.h>

const static CGFloat kCustomAlertViewOriginX                    = 23;
const static CGFloat kCustomAlertViewTitleOriginY               = 19;
const static CGFloat kCustomAlertViewMessageOriginX             = 19;
const static CGFloat kSpaceBetweenTitleAndMessage               = 10;
const static CGFloat kSpaceBetweenMessageAndButton              = 20;
const static CGFloat kSpaceBetweenButtonsAndView                = 10;
const static CGFloat kButtonOriginX                             = 15;
const static CGFloat kButtonWidth                               = 145;
const static CGFloat kButtonHeight                              = 35;

const static CGFloat kCustomAlertViewDefaultButtonHeight        = 45;
const static CGFloat kCustomAlertViewDefaultButtonSpacerHeight  = 1;
const static CGFloat kCustomMotionEffectExtent                  = 10.0;

@interface CustomAlertView ()

@property (nonatomic, strong) UILabel *labelTitle;
@property (nonatomic, strong) UILabel *labelMessage;
@property (nonatomic, strong) UIView  *demoView;
@property (nonatomic, assign) CGFloat oryginY;

@end


@implementation CustomAlertView

CGFloat buttonHeight = 0;
CGFloat buttonSpacerHeight = 0;

@synthesize parentView, containerView, dialogView, onButtonTouchUpInside;
@synthesize delegate;
@synthesize buttonTitles;
@synthesize useMotionEffects;


- (id)initWithTitle:(NSString *)title
           withFont:(NSString *)fontName
           withSize:(CGFloat)fontSize
        withMessage:(NSString *)message
    withMessageFont:(NSString *)messageFontName
withMessageFontSize:(CGFloat)messageFontSize
     withDeactivate:(BOOL)deactivate {
    
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);

        delegate = self;
        useMotionEffects = false;
        buttonTitles = @[@"Close"];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
        self.containerView = [self createDemoViewWithTitle:title
                                                  withFont:fontName
                                                  withSize:fontSize
                                               withMessage:message
                                           withMessageFont:messageFontName
                                       withMessageFontSize:messageFontSize
                                            withDeactivate:deactivate];
        self.containerView.layer.cornerRadius = 5;
    }
    return self;
}

- (UIView *)createDemoViewWithTitle:(NSString *)title
                           withFont:(NSString *)titleFontName
                           withSize:(CGFloat)titleFontSize
                        withMessage:(NSString *)message
                    withMessageFont:(NSString *)messageFontName
                    withMessageFontSize:(CGFloat)messageFontSize
                     withDeactivate:(BOOL)deactivate{
    
    self.demoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 2*kCustomAlertViewOriginX, 237)];
    self.oryginY = kCustomAlertViewTitleOriginY;
    if (title) {
        CGFloat titleHeight = [self messageHeightWithText:title width:self.demoView.frame.size.width fontSize:titleFontSize fontName:titleFontName];
        self.labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 19, self.demoView.frame.size.width, titleHeight)];
        self.labelTitle.font = [UIFont fontWithName:titleFontName size:titleFontSize];
        self.labelTitle.backgroundColor = [UIColor clearColor];
        self.labelTitle.textAlignment = NSTextAlignmentCenter;
        self.labelTitle.lineBreakMode = NSLineBreakByWordWrapping;
        self.labelTitle.numberOfLines = 0;
        self.labelTitle.textColor = [UIColor blackColor];
        self.labelTitle.text = title;
        self.oryginY += titleHeight;
        self.oryginY += kSpaceBetweenTitleAndMessage;
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.labelTitle.text];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:24];
        [paragraphStyle setAlignment:NSTextAlignmentCenter];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [self.labelTitle.text length])];
        self.labelTitle.attributedText = attributedString;
        [self.demoView addSubview:self.labelTitle];
    }
    
    if (message) {
        CGFloat messageHeight = [self messageHeightWithText:message width:self.demoView.frame.size.width - 2*kCustomAlertViewMessageOriginX fontSize:messageFontSize fontName:messageFontName];
        self.labelMessage = [[UILabel alloc] initWithFrame:CGRectMake(kCustomAlertViewMessageOriginX, self.oryginY, self.demoView.frame.size.width - 2*kCustomAlertViewMessageOriginX, messageHeight)];
        self.labelMessage.font = [UIFont fontWithName:messageFontName size:messageFontSize];
        self.labelMessage.backgroundColor = [UIColor clearColor];
        self.labelMessage.textAlignment = NSTextAlignmentCenter;
        self.labelMessage.lineBreakMode = NSLineBreakByWordWrapping;
        self.labelMessage.numberOfLines = 0;
        self.labelMessage.textColor = [UIColor colorWithRed:120.0/255.0 green:132.0/255.0 blue:140.0/255.0 alpha:1];
        self.labelMessage.text = message;
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.labelMessage.text];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:4];
        [paragraphStyle setAlignment:NSTextAlignmentCenter];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [self.labelMessage.text length])];
        self.labelMessage.attributedText = attributedString;
        [self.demoView addSubview:self.labelMessage];
        self.oryginY += messageHeight;
        self.oryginY += kSpaceBetweenMessageAndButton;
    }
    self.demoView.backgroundColor = [UIColor whiteColor];
    
    return self.demoView;
}

- (CGFloat)messageHeightWithText:(NSString *)text width:(CGFloat)width fontSize:(CGFloat)fontSize fontName:(NSString *)fontName{
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:24];
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    
    NSDictionary *headerAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [UIFont fontWithName:fontName size:fontSize], NSFontAttributeName,
                                      paragraphStyle, NSParagraphStyleAttributeName, nil];
    
    CGRect textSize = [text boundingRectWithSize:CGSizeMake(width,CGFLOAT_MAX)
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:headerAttributes
                                         context:nil];
    return textSize.size.height;
}

// Create the dialog view, and animate opening the dialog
- (void)show {
    
    dialogView = [self createContainerView];
    dialogView.layer.shouldRasterize = YES;
    dialogView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];

#if (defined(__IPHONE_7_0))
    if (useMotionEffects) {
        [self applyMotionEffects];
    }
#endif

    dialogView.layer.opacity = 0.7f;
    dialogView.layer.transform = CATransform3DMakeScale(1.3f, 1.3f, 1.0);

    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];

    [self addSubview:dialogView];

    // Can be attached to a view or to the top most window
    // Attached to a view:
    if (parentView != NULL) {
        [parentView addSubview:self];

    // Attached to the top most window (make sure we are using the right orientation):
    } else {
        UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        switch (interfaceOrientation) {
            case UIInterfaceOrientationLandscapeLeft:
                self.transform = CGAffineTransformMakeRotation(M_PI * 270.0 / 180.0);
                break;
                
            case UIInterfaceOrientationLandscapeRight:
                self.transform = CGAffineTransformMakeRotation(M_PI * 90.0 / 180.0);
                break;

            case UIInterfaceOrientationPortraitUpsideDown:
                self.transform = CGAffineTransformMakeRotation(M_PI * 180.0 / 180.0);
                break;

            default:
                break;
        }

        [self setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [[[[UIApplication sharedApplication] windows] firstObject] addSubview:self];
        
        UIWindow *window = [UIApplication sharedApplication].windows.lastObject;
        [window addSubview:self];
        [window bringSubviewToFront:self];
    }

    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
					 animations:^{
						 self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4f];
                         dialogView.layer.opacity = 1.0f;
                         dialogView.layer.transform = CATransform3DMakeScale(1, 1, 1);
					 }
					 completion:NULL
     ];
}

// Button has been touched
- (IBAction)customIOS7dialogButtonTouchUpInside:(id)sender {
    
    if (delegate != NULL) {
        [delegate customIOS7dialogButtonTouchUpInside:self clickedButtonAtIndex:[sender tag]];
    }
    if (onButtonTouchUpInside != NULL) {
        onButtonTouchUpInside(self, (int)[sender tag]);
    }
}

// Default button behaviour
- (void)customIOS7dialogButtonTouchUpInside: (CustomAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    [self close];
}

// Dialog close animation then cleaning and removing the view from the parent
- (void)close {
    
    CATransform3D currentTransform = dialogView.layer.transform;
    CGFloat startRotation = [[dialogView valueForKeyPath:@"layer.transform.rotation.z"] floatValue];
    CATransform3D rotation = CATransform3DMakeRotation(-startRotation + M_PI * 270.0 / 180.0, 0.0f, 0.0f, 0.0f);

    dialogView.layer.transform = CATransform3DConcat(rotation, CATransform3DMakeScale(1, 1, 1));
    dialogView.layer.opacity = 1.0f;

    [UIView animateWithDuration:0.3f delay:0.0 options:UIViewAnimationOptionTransitionNone
					 animations:^{
						 self.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f];
                         dialogView.layer.transform = CATransform3DConcat(currentTransform, CATransform3DMakeScale(0.6f, 0.6f, 1.0));
                         dialogView.layer.opacity = 0.0f;
					 }
					 completion:^(BOOL finished) {
                         for (UIView *v in [self subviews]) {
                             [v removeFromSuperview];
                         }
                         [self removeFromSuperview];
					 }
	 ];
}

- (void)setSubView: (UIView *)subView {
    
    containerView = subView;
}

// Creates the container view here: create the dialog, then add the custom content and buttons
- (UIView *)createContainerView {
    
    if (containerView == NULL) {
        containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 150)];
    }

    CGSize screenSize = [self countScreenSize];
    CGSize dialogSize = [self countDialogSize];
    [self setFrame:CGRectMake(0, 0, screenSize.width, screenSize.height)];
    UIView *dialogContainer = [[UIView alloc] initWithFrame:CGRectMake((screenSize.width - dialogSize.width) / 2, (screenSize.height - dialogSize.height) / 2, dialogSize.width, dialogSize.height)];
    [dialogContainer addSubview:containerView];
    [self addButtonsToView:dialogContainer];

    return dialogContainer;
}

// Helper function: add buttons to container
- (void)addButtonsToView: (UIView *)container {
    
    if (buttonTitles == NULL) {
        return;
    }

    if ([buttonTitles count] == 2) {
        CGFloat buttonOryginX = kButtonOriginX;
        for (NSInteger i = 0; i < [buttonTitles count]; ++i) {
            NSDictionary *dictionary = [buttonTitles objectAtIndex:i];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            CGFloat buttonWidth = (self.demoView.frame.size.width - 3*kButtonOriginX)/2;
            [button setFrame:CGRectMake(buttonOryginX, self.oryginY, buttonWidth, kButtonHeight)];
            [button addTarget:self action:@selector(customIOS7dialogButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
            [button setTag:i];
            [button setTitle:[dictionary objectForKey:@"title"] forState:UIControlStateNormal];
            [button setTitleColor:[dictionary objectForKey:@"titleColor"] forState:UIControlStateNormal];
            [button setBackgroundColor:[dictionary objectForKey:@"backgroundColor"]];
            [button.titleLabel setFont:[UIFont fontWithName:[dictionary objectForKey:@"font"] size:[[dictionary objectForKey:@"fontSize"] floatValue]]];
            button.layer.cornerRadius = 3;
            [container addSubview:button];
            buttonOryginX += self.demoView.frame.size.width - 2*kButtonOriginX - buttonWidth;
        }
    }
    else if ([buttonTitles count] == 1) {
        NSDictionary *dictionary = [buttonTitles firstObject];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake((self.demoView.frame.size.width - kButtonWidth)/2, self.oryginY, kButtonWidth, kButtonHeight)];
        [button addTarget:self action:@selector(customIOS7dialogButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [button setTag:0];
        [button setTitle:[dictionary objectForKey:@"title"] forState:UIControlStateNormal];
        [button setTitleColor:[dictionary objectForKey:@"titleColor"] forState:UIControlStateNormal];
        [button setBackgroundColor:[dictionary objectForKey:@"backgroundColor"]];
        [button.titleLabel setFont:[UIFont fontWithName:[dictionary objectForKey:@"font"] size:[[dictionary objectForKey:@"fontSize"] floatValue]]];
        button.layer.cornerRadius = 3;
        [container addSubview:button];
    }
    self.oryginY += kButtonHeight;
    self.oryginY += kSpaceBetweenButtonsAndView;
    
    CGRect frame = self.demoView.frame;
    self.demoView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, self.oryginY);
}

// Helper function: count and return the dialog's size
- (CGSize)countDialogSize {
    
    CGFloat dialogWidth = containerView.frame.size.width;
    CGFloat dialogHeight = containerView.frame.size.height + buttonHeight + buttonSpacerHeight;

    return CGSizeMake(dialogWidth, dialogHeight);
}

// Helper function: count and return the screen's size
- (CGSize)countScreenSize {
    
    if (buttonTitles!=NULL && [buttonTitles count] > 0) {
        buttonHeight       = kCustomAlertViewDefaultButtonHeight;
        buttonSpacerHeight = kCustomAlertViewDefaultButtonSpacerHeight;
    } else {
        buttonHeight = 0;
        buttonSpacerHeight = 0;
    }

    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;

    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        CGFloat tmp = screenWidth;
        screenWidth = screenHeight;
        screenHeight = tmp;
    }

    return CGSizeMake(screenWidth, screenHeight);
}

#if (defined(__IPHONE_7_0))
// Add motion effects
- (void)applyMotionEffects {

    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        return;
    }

    UIInterpolatingMotionEffect *horizontalEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x"
                                                                                                    type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalEffect.minimumRelativeValue = @(-kCustomMotionEffectExtent);
    horizontalEffect.maximumRelativeValue = @( kCustomMotionEffectExtent);

    UIInterpolatingMotionEffect *verticalEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y"
                                                                                                  type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    verticalEffect.minimumRelativeValue = @(-kCustomMotionEffectExtent);
    verticalEffect.maximumRelativeValue = @( kCustomMotionEffectExtent);

    UIMotionEffectGroup *motionEffectGroup = [[UIMotionEffectGroup alloc] init];
    motionEffectGroup.motionEffects = @[horizontalEffect, verticalEffect];

    [dialogView addMotionEffect:motionEffectGroup];
}
#endif

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

// Handle device orientation changes
- (void)deviceOrientationDidChange: (NSNotification *)notification {
    
    if (parentView != NULL) {
        return;
    }

    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGFloat startRotation = [[self valueForKeyPath:@"layer.transform.rotation.z"] floatValue];
    CGAffineTransform rotation;
    switch (interfaceOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
            rotation = CGAffineTransformMakeRotation(-startRotation + M_PI * 270.0 / 180.0);
            break;
        case UIInterfaceOrientationLandscapeRight:
            rotation = CGAffineTransformMakeRotation(-startRotation + M_PI * 90.0 / 180.0);
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            rotation = CGAffineTransformMakeRotation(-startRotation + M_PI * 180.0 / 180.0);
            break;
        default:
            rotation = CGAffineTransformMakeRotation(-startRotation + 0.0);
            break;
    }

    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         dialogView.transform = rotation;
                     }
                     completion:^(BOOL finished){
                         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                             UIInterfaceOrientation endInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
                             if (interfaceOrientation != endInterfaceOrientation) {
                                 
                             }
                         });
                     }];
}

// Handle keyboard show/hide changes
- (void)keyboardWillShow: (NSNotification *)notification {
    
    CGSize screenSize = [self countScreenSize];
    CGSize dialogSize = [self countDialogSize];
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        CGFloat tmp = keyboardSize.height;
        keyboardSize.height = keyboardSize.width;
        keyboardSize.width = tmp;
    }

    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone
					 animations:^{
                         dialogView.frame = CGRectMake((screenSize.width - dialogSize.width) / 2, (screenSize.height - keyboardSize.height - dialogSize.height) / 2, dialogSize.width, dialogSize.height);
					 }
					 completion:nil
	 ];
}

- (void)keyboardWillHide: (NSNotification *)notification {
    
    CGSize screenSize = [self countScreenSize];
    CGSize dialogSize = [self countDialogSize];
    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone
					 animations:^{
                         dialogView.frame = CGRectMake((screenSize.width - dialogSize.width) / 2, (screenSize.height - dialogSize.height) / 2, dialogSize.width, dialogSize.height);
					 }
					 completion:nil
	 ];
}

@end
