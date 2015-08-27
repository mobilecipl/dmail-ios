//
//  QueuViewController.m
//  Dmail
//
//  Created by Karen Petrosyan on 8/27/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "QueuViewController.h"


@interface QueuViewController ()

@property (nonatomic, weak) IBOutlet UIButton *buttonSetupPin;
@property (nonatomic, weak) IBOutlet UIButton *buttonGetNotified;
@property (nonatomic, weak) IBOutlet UIButton *buttonShare;

@end

@implementation QueuViewController


#pragma mark - Class Methods
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setupController];
}


#pragma mark - Private Methods
- (void)setupController {
    
    self.buttonShare.layer.masksToBounds = YES;
    self.buttonShare.layer.cornerRadius = 5;
}


#pragma mark - Action Methods
- (IBAction)setupSecurityPinClicked:(id)sender {
    
    BOOL setupPin = [[NSUserDefaults standardUserDefaults] boolForKey:@"setupPin"];
    if (setupPin) {
        [self.buttonSetupPin setImage:[UIImage imageNamed:@"iconSetupSecurityPin"] forState:UIControlStateNormal];
    }
    else {
        [self.buttonSetupPin setImage:[UIImage imageNamed:@"iconCheckMark"] forState:UIControlStateNormal];
    }
    setupPin = !setupPin;
    [[NSUserDefaults standardUserDefaults] setBool:setupPin forKey:@"setupPin"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)getNotifiedClicked:(id)sender {
    
    BOOL getNotified = [[NSUserDefaults standardUserDefaults] boolForKey:@"getNotified"];
    if (getNotified) {
        [self.buttonGetNotified setImage:[UIImage imageNamed:@"iconGetNotified"] forState:UIControlStateNormal];
    }
    else {
        [self.buttonGetNotified setImage:[UIImage imageNamed:@"iconCheckMark"] forState:UIControlStateNormal];
    }
    
    getNotified = !getNotified;
    [[NSUserDefaults standardUserDefaults] setBool:getNotified forKey:@"getNotified"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)shareClicked:(id)sender {
    
    NSString *textToShare = @"your text";
//    UIImage *imageToShare = [UIImage imageNamed:@"yourImage.png"];
    NSArray *itemsToShare = @[textToShare];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
    activityVC.excludedActivityTypes = @[UIActivityTypePostToFacebook, UIActivityTypePostToTwitter, UIActivityTypePostToWeibo, UIActivityTypeMessage, UIActivityTypeMail, UIActivityTypePostToFlickr, UIActivityTypePostToVimeo]; //or whichever you don't need
    [self presentViewController:activityVC animated:YES completion:nil];

}

@end
