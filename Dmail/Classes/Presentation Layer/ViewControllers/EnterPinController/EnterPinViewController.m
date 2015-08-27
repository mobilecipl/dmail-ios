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
@property (nonatomic, weak) IBOutlet UIView *viewPin1;
@property (nonatomic, weak) IBOutlet UIView *viewPin2;
@property (nonatomic, weak) IBOutlet UIView *viewPin3;
@property (nonatomic, weak) IBOutlet UIView *viewPin4;
@property (nonatomic, weak) IBOutlet UILabel *labelPin1;
@property (nonatomic, weak) IBOutlet UILabel *labelPin2;
@property (nonatomic, weak) IBOutlet UILabel *labelPin3;
@property (nonatomic, weak) IBOutlet UILabel *labelPin4;

@property (nonatomic, assign) NSInteger lastPin;

@end

@implementation EnterPinViewController

#pragma mark - Class Methods
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setupController];
}


#pragma mark - Private Methods
- (void)setupController {
    
    [self.textField becomeFirstResponder];
    
    self.viewPin1.layer.masksToBounds = YES;
    self.viewPin1.layer.cornerRadius = 5;
    
    self.viewPin2.layer.masksToBounds = YES;
    self.viewPin2.layer.cornerRadius = 5;
    
    self.viewPin3.layer.masksToBounds = YES;
    self.viewPin3.layer.cornerRadius = 5;
    
    self.viewPin4.layer.masksToBounds = YES;
    self.viewPin4.layer.cornerRadius = 5;
    
    self.lastPin = 0;
}

- (void)rotatePinCircleTo:(NSInteger)pin {
    
    NSInteger dif = pin - self.lastPin;
    if (dif != 0) {
        
    }
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

#pragma mark - UITextFieldDelegate Methods 
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    BOOL success = YES;
    if (textField.text.length <= 4) {
        if ([string isEqualToString:@""]) {
            switch (textField.text.length) {
                case 4:
                    success = YES;
                    self.labelPin4.text = @"";
                    break;
                case 3:
                    success = YES;
                    self.labelPin3.text = @"";
                    break;
                case 2:
                    success = YES;
                    self.labelPin2.text = @"";
                    break;
                case 1:
                    success = YES;
                    self.labelPin1.text = @"";
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
                    break;
                case 1:
                    success = YES;
                    self.labelPin2.text = string;
                    [self rotatePinCircleTo:[string integerValue]];
                    break;
                case 2:
                    success = YES;
                    self.labelPin3.text = string;
                    [self rotatePinCircleTo:[string integerValue]];
                    break;
                case 3:
                    success = YES;
                    self.labelPin4.text = string;
                    [self rotatePinCircleTo:[string integerValue]];
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
