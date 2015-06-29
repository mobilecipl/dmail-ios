//
//  BaseViewController.m
//  pium
//
//  Created by Armen Mkrtchian on 10/15/14.
//  Copyright (c) 2014 Armen Mkrtchian. All rights reserved.
//

#import "BaseViewController.h"

#import "ErrorDataModel.h"

#import <TBAlertController.h>

#import "ReachabilityManager.h"
#import "TabloidDelegate.h"

#import "NoConnectionView.h"

@interface BaseViewController () <NoConnectionViewDelegate>

@property (nonatomic) TBAlertController *alertController;

@property (nonatomic, strong) NoConnectionView *noConnectionView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@property BOOL isPresentingNoConnectionView;

@end

@implementation BaseViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)loadView {
    [super loadView];
//    self.view.frame = kScreenBounds;
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.isPresentingNoConnectionView = YES;
//    [self trackCurrentScreen];
    
    [self setReachable:[[[UIApplication tabloidDelegate] reachability] isReachable]];
    [self setNeedsStatusBarAppearanceUpdate];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [self hideActivityIndicator];
    [super viewWillDisappear:animated];
}

- (void)presentActivityViewController:(NSArray *)objectsToShare {
    
    UIActivityViewController *activityVC = [TDUtility shareActivityVCForObjects:objectsToShare];
    [self presentViewController:activityVC animated:YES completion:nil];
}

- (void)reachabilityChanged:(NSNotification *)sender {
    
    if ([[sender object] isReachable]) {
        [self gotReachable];
    }
    else {
        [self gotUnreachable];
    }
}
- (void)gotReachable {
    
    [self setReachable:YES];
}
- (void)gotUnreachable {
    
    [self setReachable:NO];
}

- (void)handleConnectionError:(ErrorDataModel *)error {
    
    NSInteger code = [error.statusCode integerValue];
    NSString *message = @"";
    switch (code) {
        case -1005:
        case -1009:
        {
            message = kErrorMessageNoConnection;
        }
            break;
        case 500:
        {
            message = kErrorMessageNoServer;
        }
            break;
            
        default:
        {
            message = error.message;
        }
            break;
    }
    
    [self showAlertWithTitle:@""
                     message:message
           cancelButtonTitle:@"Ok"
                otherButtons:nil];

}

- (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
         cancelButtonTitle:(NSString *)cancelButtonTitle
              otherButtons:(NSArray *)otherButtons {
    
    self.alertController = [[TBAlertController alloc] initWithStyle:TBAlertControllerStyleAlert];
    self.alertController.title = title;
    self.alertController.message = message;
    
    if ([cancelButtonTitle isKindOfClass:[NSString class]]) {
        [self.alertController setCancelButtonWithTitle:cancelButtonTitle];
    }
    
    for (NSDictionary *otherButton in otherButtons) {
        [self.alertController addOtherButtonWithTitle:otherButton[@"buttonTitle"] buttonAction:otherButton[@"actionBlock"]];
    }
    
    [self.alertController showFromViewController:self animated:YES completion:^{
        
    }];
}

- (void)showActionSheetWithTitle:(NSString *)title
                         message:(NSString *)message
               cancelButtonTitle:(NSString *)cancelButtonTitle
                    otherButtons:(NSArray *)otherButtons {
    
    self.alertController = [[TBAlertController alloc] initWithStyle:TBAlertControllerStyleActionSheet];
    self.alertController.title = title;
    self.alertController.message = message;
    
    if ([cancelButtonTitle isKindOfClass:[NSString class]]) {
        [self.alertController setCancelButtonWithTitle:cancelButtonTitle];
    }
    
    for (NSDictionary *otherButton in otherButtons) {
        [self.alertController addOtherButtonWithTitle:otherButton[@"buttonTitle"] buttonAction:otherButton[@"actionBlock"]];
    }
    
    [self.alertController showFromViewController:self animated:YES completion:^{
        
    }];
}


- (void)trackCurrentScreen {
    NSString *currentVCName = NSStringFromClass([self class]);
    if ([currentVCName isKindOfClass:[NSString class]]) {
        currentVCName = [currentVCName stringByReplacingOccurrencesOfString:@"ViewController" withString:@""];
//        [[SEGAnalytics sharedAnalytics] screen:currentVCName];
    }
}

#pragma mark - NoConnectionView -
- (NoConnectionView *)noConnectionView {
    
    if (!_noConnectionView) {
        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"NoConnectionView" owner:self options:nil];
        _noConnectionView = [nibs firstObject];
        [_noConnectionView setFrame:self.view.bounds];
        [_noConnectionView setDelegate:self];
        [_noConnectionView setAlpha:0.0];
        [self.view addSubview:_noConnectionView];
    }
    return _noConnectionView;
}

- (void)dismissNoConnectionView:(NoConnectionView *)view {
    
    [self setStatusBarHidden:NO];
    [UIView animateWithDuration:0.2 animations:^{
        [view setAlpha:0.0];
        [self setNeedsStatusBarAppearanceUpdate];
    } completion:^(BOOL finished) {
        self.isPresentingNoConnectionView = YES;
    }];
}

- (void)presentNoConnectionView {
    
    if (self.isPresentingNoConnectionView) {
        self.isPresentingNoConnectionView = NO;
        
        [self setStatusBarHidden:YES];
        
        NoConnectionView *view = self.noConnectionView;
        
        [UIView animateWithDuration:0.3 animations:^{
            [self setNeedsStatusBarAppearanceUpdate];
            [view setAlpha:1.0];
        } completion:^(BOOL finished) {

        }];
    }
}

#pragma mark - Activity Indicator -
- (UIActivityIndicatorView *)activityIndicator {
    
    if (!_activityIndicator) {
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [_activityIndicator hidesWhenStopped];
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        [self.activityIndicator setCenter:CGPointMake(screenBounds.size.width/2, screenBounds.size.height/2 + 30)];
        [self.view addSubview:self.activityIndicator];
    }
    return _activityIndicator;
}
- (void)showActivityIndicator {
    
    [self.activityIndicator startAnimating];
}

- (void)hideActivityIndicator {
    
    [self.activityIndicator stopAnimating];
}


- (void)trackScreenWithName:(NSString *)screenName {
    
    // May return nil if a tracker has not already been initialized with a
    // property ID.
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    // This screen name value will remain set on the tracker and sent with
    // hits until it is set to a new value or to nil.
    [tracker set:kGAIScreenName
           value:screenName];
    // New SDK versions
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

#pragma mark - Status Bar -
- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleLightContent;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    
    return UIStatusBarAnimationFade;
}

- (BOOL)prefersStatusBarHidden {
    
    return self.statusBarHidden;
}

- (NSUInteger)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    
    return UIInterfaceOrientationPortrait;
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
