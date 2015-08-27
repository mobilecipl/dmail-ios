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

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.buttonGetStarted.layer.masksToBounds = YES;
    self.buttonGetStarted.layer.cornerRadius = 5;
}

@end
