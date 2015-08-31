//
//  GetStartedViewController.m
//  Dmail
//
//  Created by Karen Petrosyan on 8/27/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "GetStartedViewController.h"

@interface GetStartedViewController ()

@property (nonatomic, weak) IBOutlet UIButton *buttonGetStarted;

@end

@implementation GetStartedViewController

#pragma mark - Class methods
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.buttonGetStarted.layer.masksToBounds = YES;
    self.buttonGetStarted.layer.cornerRadius = 5;
}


#pragma mark - Action Methods
- (IBAction)getStartedClicked:(id)sender {
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:GetStarted];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self performSegueWithIdentifier:@"fromGetStartedToOnboarding" sender:self];
}

@end
