//
//  MessageComposeCell.m
//  Dmail
//
//  Created by Karen Petrosyan on 6/27/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "MessageComposeCell.h"
#import <NSDate+DateTools.h>

@interface MessageComposeCell ()

@property (nonatomic, weak) IBOutlet UIView *viewContainer;
@property (nonatomic, weak) IBOutlet UITextField *textFieldSubject;
@property (nonatomic, weak) IBOutlet UITextView *textViewBody;
@property (nonatomic, weak) IBOutlet UILabel *labelTime;
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
    self.layer.cornerRadius = 5;
    self.backgroundColor = [UIColor whiteColor];
    self.labelTime.hidden = YES;
    self.viewContainer.layer.cornerRadius = 5;
    self.heightTextViewBody = self.textViewBody.frame.size.height;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 10;
    NSString *string = self.textViewBody.text;
    NSDictionary *ats = @{
                          NSFontAttributeName : [UIFont fontWithName:@"ProximaNova-Light" size:14.0f],
                          NSParagraphStyleAttributeName : paragraphStyle,
                          };
    
    self.textViewBody.attributedText = [[NSAttributedString alloc] initWithString:string attributes:ats];
}

- (void)configureCellWithBody:(NSString *)body subject:(NSString *)subject internalDate:(double)internalDate {
    
    self.textViewBody.editable = NO;
    self.layer.cornerRadius = 5;
    self.backgroundColor = [UIColor whiteColor];
    self.labelTime.hidden = NO;
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:internalDate/1000];
    self.labelTime.text = [NSDate shortTimeAgoSinceDate:date];
    self.textViewBody.text = body;
    self.textFieldSubject.text = subject;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 10;
    NSString *string = self.textViewBody.text;
    NSDictionary *ats = @{
                          NSFontAttributeName : [UIFont fontWithName:@"ProximaNova-Light" size:14.0f],
                          NSParagraphStyleAttributeName : paragraphStyle,
                          };
    
    self.textViewBody.attributedText = [[NSAttributedString alloc] initWithString:string attributes:ats];
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
    
    self.textViewBody.translatesAutoresizingMaskIntoConstraints = YES;
    self.textViewBody.frame = CGRectMake(self.textViewBody.frame.origin.x, self.textViewBody.frame.origin.y, self.textViewBody.frame.size.width, 210);
    
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if ([self.delegate respondsToSelector:@selector(messageBody:)]) {
        [self.delegate messageBody:text];
    }
    
    return YES;
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    self.textViewBody.translatesAutoresizingMaskIntoConstraints = YES;
    self.textViewBody.frame = CGRectMake(self.textViewBody.frame.origin.x, self.textViewBody.frame.origin.y, self.textViewBody.frame.size.width, self.heightTextViewBody);
}

@end
