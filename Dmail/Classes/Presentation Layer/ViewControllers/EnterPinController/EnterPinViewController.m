//
//  EnterPinViewController.m
//  Dmail
//
//  Created by Karen Petrosyan on 8/27/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "EnterPinViewController.h"

@interface EnterPinViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *imageViewPinCircleNumbers;
@property (nonatomic, weak) IBOutlet UITextField *textField;
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
@property (nonatomic, weak) IBOutlet UIImageView *imageViewStar1;
@property (nonatomic, weak) IBOutlet UIImageView *imageViewStar2;
@property (nonatomic, weak) IBOutlet UIImageView *imageViewStar3;
@property (nonatomic, weak) IBOutlet UIImageView *imageViewStar4;

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

@property (nonatomic, assign) NSInteger lastPin;
@property (nonatomic, assign) BOOL switchOn;

@end

@implementation EnterPinViewController

#pragma mark - Class Methods
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setupController];
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


#pragma mark - Private Methods
- (void)setupController {
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"pin"]) {
        self.viewSwitchContainer.hidden = YES;
    }
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self.textField becomeFirstResponder];
    
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
    
    self.viewSwitch.layer.masksToBounds = YES;
    self.viewSwitch.layer.cornerRadius = self.viewSwitch.frame.size.height/2;
    
    self.lastPin = 0;
    self.switchOn = YES;
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
    NSString *savedPin = [[NSUserDefaults standardUserDefaults] objectForKey:@"pin"];
    if (savedPin) {
        if ([savedPin isEqualToString:pin]) {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"touchId"]) {
                [self performSegueWithIdentifier:@"fromPinToTouchId" sender:self];
            }
            else {
                [self performSegueWithIdentifier:@"fromPinToLoading" sender:self];
            }
            [UIView animateWithDuration:1
                             animations:^{
                                 self.viewPins.alpha = 0;
                                 self.viewPinConfirmed.alpha = 1;
                             }
                             completion:^(BOOL finished) {
                             }];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                            message:@"You typed wrong pin"
                                                           delegate:self
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    else {
        [UIView animateWithDuration:1
                         animations:^{
                             self.viewPins.alpha = 0;
                             self.viewPinConfirmed.alpha = 1;
                         }
                         completion:^(BOOL finished) {
                         }];
        [[NSUserDefaults standardUserDefaults] setObject:pin forKey:@"pin"];
        if (self.switchOn) {
            [self performSegueWithIdentifier:@"fromPinToTouchId" sender:self];
        }
        else {
            [self performSegueWithIdentifier:@"fromPinToLoading" sender:self];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"setupPin"];
    [[NSUserDefaults standardUserDefaults] synchronize];
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
                    [self savePinAndGoToNextScreen];
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
