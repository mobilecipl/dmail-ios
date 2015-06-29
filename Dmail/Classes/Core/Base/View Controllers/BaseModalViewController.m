//
//  BaseModalViewController.m
//  pium playground
//
//  Created by Armen Mkrtchian on 10/24/14.
//  Copyright (c) 2014 Armen Mkrtchian. All rights reserved.
//

#import "BaseModalViewController.h"

@interface BaseModalViewController () {
    BaseButton *closeButton;
}

@end

@implementation BaseModalViewController


- (instancetype)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
//    CGRect frame = self.view.frame;
//    frame.size.height -= 20; //status bar
//    self.view.frame = frame;
    
    closeButton = [BaseButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = CGRectMake(kScreenWidth - 44.f, 20.f, 44.f, 44.f);
    closeButton.backgroundColor = [UIColor clearColor];
    [closeButton setImage:[UIImage imageNamed:@"btn_close"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(dismissModalView) forControlEvents:UIControlEventTouchUpInside];
    // UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView: closeButton];
    // [[self navigationItem] setRightBarButtonItem:rightButton animated:YES];
    [self.view addSubview:closeButton];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setCloseButton:(NSString *)buttonString {
    [closeButton setImage:[UIImage imageNamed:buttonString] forState:UIControlStateNormal];
}

-(void)dismissModalView {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


@end
