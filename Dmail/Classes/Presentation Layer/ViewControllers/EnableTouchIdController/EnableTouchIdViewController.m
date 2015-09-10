//
//  EnableTouchIdViewController.m
//  Dmail
//
//  Created by Karen Petrosyan on 8/28/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "EnableTouchIdViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>


@interface EnableTouchIdViewController () <UIAlertViewDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *imageViewTouchId;
@property (nonatomic, weak) IBOutlet UIButton *buttonEnableTouchId;
@property (nonatomic, weak) IBOutlet UIButton *buttonMaybeLater;

@end

@implementation EnableTouchIdViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:TouchId]) {
        self.buttonEnableTouchId.hidden = YES;
        self.buttonMaybeLater.hidden = YES;
        [self enableTouchIdClicked:nil];
    }
}

- (IBAction)enableTouchIdClicked:(id)sender {
    
    LAContext *context = [[LAContext alloc] init];
    
    NSError *error = nil;
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"Are you the device owner?" reply:^(BOOL success, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                if (error) {
                    [self showErrorAlertWithTitle:@"Error" message:@"There was a problem verifying your identity."];
                    return;
                }
                if (success) {
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:TouchId];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [self.imageViewTouchId setImage:[UIImage imageNamed:@"imageFingerTouch"]];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                                    message:@"You are the device owner!"
                                                                   delegate:self
                                                          cancelButtonTitle:@"Ok"
                                                          otherButtonTitles:nil, nil];
                    alert.delegate = self;
                    [alert show];
                } else {
                    [self showErrorAlertWithTitle:@"Error" message:@"You are not the device owner."];
                }
            });
        }];
    } else {
        [self showErrorAlertWithTitle:@"Error" message:@"Your device cannot authenticate using TouchID."];
    }
}

- (IBAction)maybeLaterClicked:(id)sender {
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:TouchId];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if (self.fromSettings) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        [self performSegueWithIdentifier:@"fromTouchToLoading" sender:self];
    }
}


#pragma mark - UIAlertViewDelegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (self.fromSettings) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        [self performSegueWithIdentifier:@"fromTouchToLoading" sender:self];
    }
}

@end
