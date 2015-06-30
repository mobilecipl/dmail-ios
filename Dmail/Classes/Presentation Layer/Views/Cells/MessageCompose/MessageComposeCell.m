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

@end

@implementation MessageComposeCell

- (void)awakeFromNib {

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
}

- (void)configureCell {
    
    self.labelTime.hidden = YES;
    self.viewContainer.layer.cornerRadius = 5;
}

- (void)configureCellWithBody:(NSString *)body subject:(NSString *)subject {
    
    self.viewContainer_.layer.cornerRadius = 5;
    self.labelTime.hidden = NO;
    self.textViewBody.text = body;
    self.textFieldSubject.text = subject;
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
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if ([self.delegate respondsToSelector:@selector(messageSubject:)]) {
        [self.delegate messageBody:text];
    }
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    
    
}


@end
