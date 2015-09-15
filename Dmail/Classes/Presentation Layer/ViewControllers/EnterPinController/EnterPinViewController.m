//
//  EnterPinViewController.m
//  Dmail
//
//  Created by Karen Petrosyan on 8/27/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "EnterPinViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>

@interface EnterPinViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *imageViewPinCircleNumbers;
@property (nonatomic, weak) IBOutlet UITextField *textField;
@property (nonatomic, weak) IBOutlet UIView *viewNavigation;
@property (nonatomic, weak) IBOutlet UIView *viewPins;
@property (nonatomic, weak) IBOutlet UIView *viewPinConfirmed;
@property (nonatomic, weak) IBOutlet UIView *viewPin1;
@property (nonatomic, weak) IBOutlet UIView *viewPin2;
@property (nonatomic, weak) IBOutlet UIView *viewPin3;
@property (nonatomic, weak) IBOutlet UIView *viewPin4;
@property (nonatomic, weak) IBOutlet UILabel *labelPin1;
@property (nonatomic, weak) IBOutlet UILabel *labelPin2;
@property (nonatomic, weak) IBOutlet UILabel *labelPin3;
@property (nonatomic, weak) IBOutlet UILabel *labelPin4;
@property (nonatomic, weak) IBOutlet UILabel *labelEnterPin;
@property (nonatomic, weak) IBOutlet UIImageView *imageViewStar1;
@property (nonatomic, weak) IBOutlet UIImageView *imageViewStar2;
@property (nonatomic, weak) IBOutlet UIImageView *imageViewStar3;
@property (nonatomic, weak) IBOutlet UIImageView *imageViewStar4;
@property (nonatomic, weak) IBOutlet UIImageView *imageViewBackground;

@property (nonatomic, weak) IBOutlet UIView *viewSwitchContainer;
@property (nonatomic, weak) IBOutlet UIView *viewSwitch;
@property (nonatomic, weak) IBOutlet UIButton *buttonSwitchOn;
@property (nonatomic, weak) IBOutlet UIButton *buttonSwitchOff;
@property (nonatomic, weak) IBOutlet UILabel *labelSwitch;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *constraintSwitchOn;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *constraintSwitchOff;

@property (nonatomic, strong) NSTimer *timer1;
@property (nonatomic, strong) NSTimer *timer2;
@property (nonatomic, strong) NSTimer *timer3;
@property (nonatomic, strong) NSTimer *timer4;
@property (nonatomic, strong) NSString *tempPin;

@property (nonatomic, assign) NSInteger lastPin;
@property (nonatomic, assign) BOOL switchOn;
@property (nonatomic, assign) BOOL pinDidChanged;
@property (nonatomic, assign) BOOL pinChanged;

@end

@implementation EnterPinViewController

#pragma mark - Class Methods
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setupController];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    if (!self.fromSettings) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }
    else {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
}

#pragma mark - Action Methods
- (IBAction)onButtonSwitchClicked:(id)sender {
    
    if (self.switchOn) {
        [UIView animateWithDuration:0.3 animations:^{
            self.buttonSwitchOn.alpha = 0;
            self.buttonSwitchOff.alpha = 1;
            self.viewSwitch.alpha = 0.2;
            self.constraintSwitchOn.constant = 35;
            self.constraintSwitchOff.constant = 35;
            self.labelSwitch.text = @"Touch ID disabled";
            [self.view layoutIfNeeded];
        }];
    }
    else {
        [UIView animateWithDuration:0.3 animations:^{
            self.buttonSwitchOn.alpha = 1;
            self.buttonSwitchOff.alpha = 0;
            self.viewSwitch.alpha = 0.7;
            self.constraintSwitchOn.constant = 0;
            self.constraintSwitchOff.constant = 0;
            self.labelSwitch.text = @"Touch ID enabled";
            [self.view layoutIfNeeded];
        }];
    }
    
    self.switchOn = !self.switchOn;
}

- (IBAction)onButtonBackClicked:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Private Methods
- (void)setupController {
    
    [self.textField becomeFirstResponder];
    
    if (self.fromSettings || ![self isTouchEnabledInDevice]) {
        if (self.fromSettings && [[NSUserDefaults standardUserDefaults] objectForKey:Pin]) {
            self.viewNavigation.hidden = NO;
            self.labelEnterPin.text = @"Type old 4 digit pin";
        }
        else {
            self.pinDidChanged = YES;
        }
        self.viewSwitchContainer.hidden = YES;
        self.labelSwitch.hidden = YES;
    }
    else {
        self.viewSwitch.layer.masksToBounds = YES;
        self.viewSwitch.layer.cornerRadius = self.viewSwitch.frame.size.height/2;
    }
    
    self.viewPin1.layer.masksToBounds = YES;
    self.viewPin1.layer.cornerRadius = 5;
    
    self.viewPin2.layer.masksToBounds = YES;
    self.viewPin2.layer.cornerRadius = 5;
    
    self.viewPin3.layer.masksToBounds = YES;
    self.viewPin3.layer.cornerRadius = 5;
    
    self.viewPin4.layer.masksToBounds = YES;
    self.viewPin4.layer.cornerRadius = 5;
    
    self.viewPinConfirmed.layer.masksToBounds = YES;
    self.viewPinConfirmed.layer.cornerRadius = self.viewPinConfirmed.frame.size.height/2;
    
    self.lastPin = 0;
    self.switchOn = YES;
}

- (BOOL)isTouchEnabledInDevice {
    
    LAContext *context = [[LAContext alloc] init];
    NSError *error = nil;
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        return YES;
    } else {
        return NO;
    }
}

- (void)rotatePinCircleTo:(NSInteger)pin {

    [UIView animateWithDuration:1
                     animations:^{
                         CATransform3D transformation = CATransform3DIdentity;
                         CATransform3D xRotation = CATransform3DMakeRotation(0, 1.0, 0, 0);
                         CATransform3D yRotation = CATransform3DMakeRotation(0, 0.0, 1.0, 0);
                         CATransform3D zRotation = CATransform3DMakeRotation(-pin*36 * M_PI/180, 0.0, 0, 1.0);
                         CATransform3D xYRotation = CATransform3DConcat(xRotation, yRotation);
                         CATransform3D xyZRotation = CATransform3DConcat(xYRotation, zRotation);
                         CATransform3D concatenatedTransformation = CATransform3DConcat(xyZRotation, transformation);
                         self.imageViewPinCircleNumbers.layer.transform = concatenatedTransformation;
                     }
                     completion:^(BOOL finished) {
                     }];
    self.lastPin = pin;
}

- (void)showStar:(NSTimer *)timer {
    
    NSString *str = (NSString *)[timer userInfo];
    switch ([str integerValue]) {
        case 0:
            self.labelPin1.hidden = YES;
            self.imageViewStar1.hidden = NO;
            if (self.timer1) {
                [self.timer1 invalidate];
                self.timer1 = nil;
            }
            break;
        case 1:
            self.labelPin2.hidden = YES;
            self.imageViewStar2.hidden = NO;
            if (self.timer2) {
                [self.timer2 invalidate];
                self.timer2 = nil;
            }
            break;
        case 2:
            self.labelPin3.hidden = YES;
            self.imageViewStar3.hidden = NO;
            if (self.timer3) {
                [self.timer3 invalidate];
                self.timer3 = nil;
            }
            break;
        case 3:
            self.labelPin4.hidden = YES;
            self.imageViewStar4.hidden = NO;
            if (self.timer4) {
                [self.timer4 invalidate];
                self.timer4 = nil;
            }
            break;
            
        default:
            break;
    }
}

- (void)hideStar:(NSInteger)index {
    
    switch (index) {
        case 0:
            self.labelPin1.hidden = NO;
            self.imageViewStar1.hidden = YES;
            if (self.timer1) {
                [self.timer1 invalidate];
                self.timer1 = nil;
            }
            break;
        case 1:
            self.labelPin2.hidden = NO;
            self.imageViewStar2.hidden = YES;
            if (self.timer2) {
                [self.timer2 invalidate];
                self.timer2 = nil;
            }
            break;
        case 2:
            self.labelPin3.hidden = NO;
            self.imageViewStar3.hidden = YES;
            if (self.timer3) {
                [self.timer3 invalidate];
                self.timer3 = nil;
            }
            break;
        case 3:
            self.labelPin4.hidden = NO;
            self.imageViewStar4.hidden = YES;
            if (self.timer4) {
                [self.timer4 invalidate];
                self.timer4 = nil;
            }
            break;
            
        default:
            break;
    }
}

- (void)savePinAndGoToNextScreen {
    
    NSString *pin = [NSString stringWithFormat:@"%@%@%@%@",self.labelPin1.text,self.labelPin2.text,self.labelPin3.text,self.labelPin4.text];
    NSString *savedPin = [[NSUserDefaults standardUserDefaults] objectForKey:Pin];
    if (self.tempPin || savedPin) {
        if ((self.tempPin && [pin isEqualToString:self.tempPin]) || [savedPin isEqualToString:pin]) {
            [UIView animateWithDuration:0.3
                             animations:^{
                                 self.imageViewBackground.alpha = 0;
                                 self.viewPins.alpha = 0;
                                 self.viewPinConfirmed.alpha = 1;
                                 [self.textField resignFirstResponder];
                             }
                             completion:^(BOOL finished) {
                                 sleep(1);
                                 if ([[NSUserDefaults standardUserDefaults] boolForKey:TouchId]) {
                                     [self performSegueWithIdentifier:@"fromPinToTouchId" sender:self];
                                 }
                                 else {
                                     [self performSegueWithIdentifier:@"fromPinToLoading" sender:self];
                                 }
                             }];
            [[NSUserDefaults standardUserDefaults] setObject:self.tempPin forKey:Pin];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:SetupPin];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else {
            [self showErrorAlertWithTitle:@"Error" message:@"You typed wrong pin"];
        }
    }
    else {
        [self.textField resignFirstResponder];
        self.tempPin = pin;
        [self clearAllFields];
        [self showLoadingView];
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(confirmation) userInfo:nil repeats:NO];
    }
}

- (void)changePin {
    
    NSString *oldPin = [NSString stringWithFormat:@"%@%@%@%@",self.labelPin1.text,self.labelPin2.text,self.labelPin3.text,self.labelPin4.text];
    if(!self.pinDidChanged && !self.pinChanged) {
        if ([oldPin isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:Pin]]) {
            [self.textField resignFirstResponder];
            [self showLoadingView];
            [self clearAllFields];
            self.pinDidChanged = YES;
            [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(setNewPin) userInfo:nil repeats:NO];
        }
        else {
            [self showErrorAlertWithTitle:@"Error" message:@"You typed wrong pin"];
        }
    }
    else if (self.pinDidChanged && !self.pinChanged){
        self.tempPin = oldPin;
        [self.textField resignFirstResponder];
        [self showLoadingView];
        [self clearAllFields];
        self.pinDidChanged = NO;
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(setNewPin) userInfo:nil repeats:NO];
        self.pinChanged = YES;
    }
    else if (self.pinChanged){
        if ([self.tempPin isEqualToString:oldPin]) {
            [UIView animateWithDuration:0.3
                             animations:^{
                                 self.imageViewBackground.alpha = 0;
                                 self.viewPins.alpha = 0;
                                 self.viewPinConfirmed.alpha = 1;
                                 [self.textField resignFirstResponder];
                             }
                             completion:^(BOOL finished) {
                                 sleep(1);
                                 [self.navigationController popViewControllerAnimated:YES];
                             }];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:SetupPin];
            [[NSUserDefaults standardUserDefaults] setObject:oldPin forKey:Pin];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else {
            [self showErrorAlertWithTitle:@"Error" message:@"You typed wrong pin"];
        }
    }
}

- (void)clearAllFields {
    
    self.textField.text = nil;
    self.labelPin1.text = @"";
    self.labelPin2.text = @"";
    self.labelPin3.text = @"";
    self.labelPin4.text = @"";
    for (NSInteger i = 1; i < 5; i++) {
        [self hideStar:i - 1];
    }
}

- (void)confirmation {
    
    self.labelEnterPin.text = @"Confirm your 4 digit pin";
    [self hideLoadingView];
    [self.textField becomeFirstResponder];
}

- (void)setNewPin {
    
    if (self.pinDidChanged) {
        self.labelEnterPin.text = @"Enter your new 4 digit pin";
    }
    else {
        self.labelEnterPin.text = @"Confirm your 4 digit pin";
    }
    [self hideLoadingView];
    [self.textField becomeFirstResponder];
}

#pragma mark - UITextFieldDelegate Methods 
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    BOOL success = YES;
    if (textField.text.length <= 4) {
        if ([string isEqualToString:@""]) {
            switch (textField.text.length) {
                case 4:
                    success = YES;
                    self.labelPin4.text = @"";
                    [self hideStar:textField.text.length - 1];
                    break;
                case 3:
                    success = YES;
                    self.labelPin3.text = @"";
                    [self hideStar:textField.text.length - 1];
                    break;
                case 2:
                    success = YES;
                    self.labelPin2.text = @"";
                    [self hideStar:textField.text.length - 1];
                    break;
                case 1:
                    success = YES;
                    self.labelPin1.text = @"";
                    [self hideStar:textField.text.length - 1];
                    break;
                    
                default:
                    success = NO;
                    break;
            }
        }
        else {
            switch (textField.text.length) {
                case 0:
                    success = YES;
                    self.labelPin1.text = string;
                    [self rotatePinCircleTo:[string integerValue]];
                    if (!self.timer1) {
                        self.timer1 = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(showStar:) userInfo:[NSString stringWithFormat:@"%lu",(unsigned long)textField.text.length] repeats:NO];
                    }
                    break;
                case 1:
                    success = YES;
                    self.labelPin2.text = string;
                    [self rotatePinCircleTo:[string integerValue]];
                    self.labelPin1.hidden = YES;
                    self.imageViewStar1.hidden = NO;
                    if (!self.timer2) {
                        self.timer2 = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(showStar:) userInfo:[NSString stringWithFormat:@"%lu",(unsigned long)textField.text.length] repeats:NO];
                    }
                    break;
                case 2:
                    success = YES;
                    self.labelPin3.text = string;
                    [self rotatePinCircleTo:[string integerValue]];
                    self.labelPin2.hidden = YES;
                    self.imageViewStar2.hidden = NO;
                    if (!self.timer3) {
                        self.timer3 = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(showStar:) userInfo:[NSString stringWithFormat:@"%lu",(unsigned long)textField.text.length] repeats:NO];
                    }
                    break;
                case 3:
                    success = YES;
                    self.labelPin4.text = string;
                    [self rotatePinCircleTo:[string integerValue]];
                    self.labelPin3.hidden = YES;
                    self.imageViewStar3.hidden = NO;
                    if (!self.timer4) {
                        self.timer4 = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(showStar:) userInfo:[NSString stringWithFormat:@"%lu",(unsigned long)textField.text.length] repeats:NO];
                    }
                    if(self.fromSettings) {
                        [self changePin];
                    }
                    else {
                        [self savePinAndGoToNextScreen];
                    }
                    break;
                    
                default:
                    success = NO;
                    break;
            }
        }
    }
    else {
        success = NO;
    }
    
    return success;
}

@end
