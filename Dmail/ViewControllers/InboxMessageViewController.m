//
//  InboxMessageViewController.m
//  Dmail
//
//  Created by Karen Petrosyan on 6/14/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "InboxMessageViewController.h"
#import "UIColor+AppColors.h"


@interface InboxMessageViewController ()

@property (nonatomic, weak) IBOutlet UIView *viewNavigation;
@property (nonatomic, weak) IBOutlet UIView *viewContainer;
@property (nonatomic, weak) IBOutlet UIImageView *imageViewProfile;

@end

@implementation InboxMessageViewController


#pragma mark - Class Methods
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setupController];
}


#pragma mark - Action Methods
- (IBAction)backClicked:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Private Methods
- (void)setupController {
    
    self.viewNavigation.layer.shadowColor = [[UIColor navigationShadowColor] CGColor];
    self.viewNavigation.layer.shadowOpacity = 0.6;
    self.viewNavigation.layer.shadowRadius = 0.5;
    self.viewNavigation.layer.shadowOffset = CGSizeMake(0, 1);
    
    self.imageViewProfile.layer.cornerRadius = self.imageViewProfile.frame.size.width/2;
    self.imageViewProfile.image = [UIImage imageNamed:@"imageProfile1"];
    
    self.viewContainer.layer.cornerRadius = 5;
    self.viewContainer.layer.borderColor = [[UIColor borderColor] CGColor];
    self.viewContainer.layer.borderWidth = 1;
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

@end
