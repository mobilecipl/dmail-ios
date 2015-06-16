//
//  ComposeViewController.m
//  Dmail
//
//  Created by Karen Petrosyan on 6/16/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "ComposeViewController.h"

@interface ComposeViewController ()

@property (nonatomic, weak) IBOutlet UIButton *buttonSend;
@property (nonatomic, weak) IBOutlet UIView *viewMessage;
@property (nonatomic, weak) IBOutlet UITextField *textFieldTo;
@property (nonatomic, weak) IBOutlet UITextField *textFieldSubject;
@property (nonatomic, weak) IBOutlet UITextView *textViewMessageBody;

@end

@implementation ComposeViewController


#pragma mark - Class Methods
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.buttonSend.enabled = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(buttonHandlerMenu) name:kNotificationMenuButton object:nil];
}

#pragma mark - Action Methods
- (IBAction)sendClicked:(id)sender {
    
    
}


#pragma mark - Private Methods


@end
