//
//  ComposeViewController.m
//  Dmail
//
//  Created by Karen Petrosyan on 6/16/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "ComposeViewController.h"
#import "MessageService.h"

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
    
//    self.buttonSend.enabled = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Action Methods
- (IBAction)sendClicked:(id)sender {
    
    [[MessageService sharedInstance] sendMessageToDmailWithEncriptedMessage:self.textViewMessageBody.text senderEmail:[[UserService sharedInstance] email] completionBlock:^(NSString *messageId, NSInteger statusCode) {
        if (messageId) {
            [[MessageService sharedInstance] sendMessageToGmailWithTo:self.textFieldTo.text messageSubject:self.textFieldSubject.text messageBody:self.textViewMessageBody.text withCompletionBlock:^(NSString *gmailMessageId, NSInteger statusCode) {
                if (gmailMessageId) {
                    [[MessageService sharedInstance] getMessageFromGmailWithMessageId:gmailMessageId withCompletionBlock:^(NSString *messageUniqueId, NSInteger statusCode) {
                        if (messageUniqueId) {
                            [[MessageService sharedInstance] sendMessageUniqueIdToDmailWithMessageDmailId:messageId gmailUniqueId:messageUniqueId senderEmail:[[UserService sharedInstance] email] withCompletionBlock:^(NSString *gmailMessageId, NSInteger statusCode) {
                                
                            }];
                        }
                    }];
                }
            }];
        }
    }];
}


#pragma mark - Private Methods


#pragma mark - UItextFieldDelegate Methods
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
//    if (textField.text.length > 0) {
//        self.buttonSend.enabled = YES;
//    }
//    else {
//        self.buttonSend.enabled = NO;
//    }
    
    return YES;
}

@end
