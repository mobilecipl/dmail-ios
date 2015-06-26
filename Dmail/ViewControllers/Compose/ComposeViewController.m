//
//  ComposeViewController.m
//  Dmail
//
//  Created by Karen Petrosyan on 6/16/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "ComposeViewController.h"
#import "MessageService.h"
#import "CoreDataManager.h"
#import "DmailMessage.h"
#import "ComposeModel.h"
#import "ComposeModelItem.h"

@interface ComposeViewController ()

@property (nonatomic, weak) IBOutlet UIButton *buttonSend;
@property (nonatomic, weak) IBOutlet UIView *viewMessage;
@property (nonatomic, weak) IBOutlet UITextField *textFieldTo;
@property (nonatomic, weak) IBOutlet UITextField *textFieldSubject;
@property (nonatomic, weak) IBOutlet UITextView *textViewMessageBody;
@property (nonatomic, weak) IBOutlet UILabel *labelNavigationName;

@property (nonatomic, strong) ComposeModel *composeModel;

@end

@implementation ComposeViewController


#pragma mark - Class Methods
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.buttonSend.enabled = NO;
    self.composeModel = [[ComposeModel alloc] init];
    self.labelNavigationName.text = [[UserService sharedInstance] name];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)resignFields {
    
    [self.textFieldSubject resignFirstResponder];
    [self.textFieldTo resignFirstResponder];
    [self.textViewMessageBody resignFirstResponder];
}

#pragma mark - Action Methods
- (IBAction)sendClicked:(id)sender {
    
    [self showLoadingView];
    [self resignFields];
    ComposeModelItem *composeModelItem = [[ComposeModelItem alloc] initWithSubject:self.textFieldSubject.text
                                                                              body:self.textViewMessageBody.text
                                                                           arrayTo:@[self.textFieldTo.text]
                                                                           arrayCC:nil
                                                                          arrayBCC:nil];
    [self.composeModel sendMessageWithItem:composeModelItem];
}

- (IBAction)backClicked:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Private Methods


#pragma mark - UItextFieldDelegate Methods
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField.text.length > 0) {
        self.buttonSend.enabled = YES;
    }
    else {
        self.buttonSend.enabled = NO;
    }
    
    return YES;
}

@end
