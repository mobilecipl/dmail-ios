//
//  MessageComposeCell.m
//  Dmail
//
//  Created by Karen Petrosyan on 6/27/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "MessageComposeCell.h"

@interface MessageComposeCell ()

@property (nonatomic, weak) IBOutlet UIView *viewContainer;
@property (nonatomic, weak) IBOutlet UIView *viewContainer_;
@property (nonatomic, weak) IBOutlet UITextField *textFieldSubject;
@property (nonatomic, weak) IBOutlet UITextView *textViewBody;
@property (nonatomic, weak) IBOutlet UILabel *labelTime;
@property (nonatomic, weak) IBOutlet UILabel *labelMessage;
@property (nonatomic, assign) CGFloat heightTextViewBody;

@end

@implementation MessageComposeCell

- (void)awakeFromNib {

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
}


#pragma mark - Public Methods
- (void)configureCell {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnLabelMessage)];
    [self.labelMessage addGestureRecognizer:tapGesture];
    self.labelMessage.userInteractionEnabled = YES;
    self.labelTime.hidden = YES;
    self.viewContainer.layer.cornerRadius = 5;
    self.heightTextViewBody = self.textViewBody.frame.size.height;
}

- (void)configureCellWithBody:(NSString *)body subject:(NSString *)subject {
    
    self.labelMessage.hidden = YES;
    self.textViewBody.editable = NO;
    self.viewContainer_.layer.cornerRadius = 5;
    self.labelTime.hidden = NO;
    self.textViewBody.text = body;
    self.textFieldSubject.text = subject;
}


#pragma mark - Private Methods 
- (void)tapOnLabelMessage {
    
    self.labelMessage.hidden = YES;
    [self.textViewBody becomeFirstResponder];
}

#pragma mark - UITextFieldDelegate Methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    if (textField == self.textFieldSubject) {
        if ([self.delegate respondsToSelector:@selector(messageSubject:)]) {
            [self.delegate messageSubject:self.textFieldSubject.text];
        }
    }
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    
    if (textField == self.textFieldSubject) {
        if ([self.delegate respondsToSelector:@selector(messageSubject:)]) {
            [self.delegate messageSubject:self.textFieldSubject.text];
        }
    }
    
    return YES;
}


#pragma mark - UITextViewDelegate Methods
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    
    self.labelMessage.hidden = YES;
    
    self.textViewBody.translatesAutoresizingMaskIntoConstraints = YES;
    self.textViewBody.frame = CGRectMake(self.textViewBody.frame.origin.x, self.textViewBody.frame.origin.y, self.textViewBody.frame.size.width, 210);
    
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if ([self.delegate respondsToSelector:@selector(messageSubject:)]) {
        [self.delegate messageBody:text];
    }
    
    return YES;
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    self.textViewBody.translatesAutoresizingMaskIntoConstraints = YES;
    self.textViewBody.frame = CGRectMake(self.textViewBody.frame.origin.x, self.textViewBody.frame.origin.y, self.textViewBody.frame.size.width, self.heightTextViewBody);
}

@end
