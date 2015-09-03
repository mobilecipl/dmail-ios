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

@end

@implementation EnableTouchIdViewController

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
    
    [self performSegueWithIdentifier:@"fromTouchToLoading" sender:self];
}


#pragma mark - UIAlertViewDelegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    [self performSegueWithIdentifier:@"fromTouchToLoading" sender:self];
}

@end
