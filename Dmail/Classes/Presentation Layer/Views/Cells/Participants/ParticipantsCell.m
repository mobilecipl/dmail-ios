//
//  ParticipantsCell.m
//  Dmail
//
//  Created by Karen Petrosyan on 6/27/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "ParticipantsCell.h"
#import "ParticipantView.h"

CGFloat kTextFieldMaxWidth = 70;
CGFloat kSpaceBetweenParticipants = 5;
CGFloat kWidthBetweenParticipants = 5;
CGFloat kHeightBetweenParticipants = 30;
CGFloat kSpaceBetweenParticipantViewAndCellBottom = 9;
CGFloat kfirstParticipantOriginX = 34;

@interface ParticipantsCell () <ParticipantViewDelegate>

@property (nonatomic, weak) IBOutlet UIView *viewContainer;
@property (nonatomic, weak) IBOutlet UILabel *labelTo;
@property (nonatomic, weak) IBOutlet UIButton *buttonCcBcc;
@property (nonatomic, weak) IBOutlet UIButton *buttonArrowUp;
@property (nonatomic, weak) IBOutlet UITextField *textFieldParticipant;

@property (nonatomic, strong) NSMutableArray *arrayParticipantView;
@property (nonatomic, assign) NSInteger row;
@property (nonatomic, assign) CGFloat textFieldOriginY;
@property (nonatomic, assign) CGFloat defaultTextFieldWidth;
@property (nonatomic, assign) BOOL sentScreen;


@end

@implementation ParticipantsCell

- (void)awakeFromNib {
    
    self.textFieldOriginY = self.labelTo.frame.origin.y;
    self.defaultTextFieldWidth = self.buttonCcBcc.frame.origin.x - (self.labelTo.frame.origin.x + self.labelTo.frame.size.width + 2*kWidthBetweenParticipants);
    self.arrayParticipantView = [[NSMutableArray alloc] init];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
//    [self.textFieldParticipant becomeFirstResponder];
}


#pragma mark - Action Methods
- (IBAction)CcBccClicked:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(onCCBCCClickedd)]) {
        [self.delegate onCCBCCClickedd];
    }
}

- (IBAction)arrowUpClicked:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(onArrowUpClicked)]) {
        [self.delegate onArrowUpClicked];
    }
}


#pragma mark - Private Methods
- (void)determineTextFieldsFrame {
    
    self.textFieldParticipant.translatesAutoresizingMaskIntoConstraints = YES;
    ParticipantView *participantView = [self.arrayParticipantView lastObject];
    CGFloat lastParticipantWidth = self.buttonCcBcc.frame.origin.x - (participantView.frame.origin.x + participantView.frame.size.width + kSpaceBetweenParticipants);
    if (lastParticipantWidth <= kTextFieldMaxWidth) {
        self.textFieldOriginY += kHeightBetweenParticipants;
        self.textFieldParticipant.frame = CGRectMake(self.labelTo.frame.origin.x, self.textFieldOriginY, self.defaultTextFieldWidth, self.textFieldParticipant.frame.size.height);
    }
    else {
        if (participantView) {
            self.textFieldParticipant.frame = CGRectMake(participantView.frame.origin.x + participantView.frame.size.width + kSpaceBetweenParticipants,
                                                         self.textFieldOriginY,
                                                         self.buttonCcBcc.frame.origin.x - (participantView.frame.origin.x + participantView.frame.size.width + 5),
                                                         self.textFieldParticipant.frame.size.height);
        }
        else {
            self.textFieldOriginY = self.labelTo.frame.origin.y;
            self.textFieldParticipant.frame = CGRectMake(kfirstParticipantOriginX,
                                                         self.textFieldOriginY,
                                                         self.buttonCcBcc.frame.origin.x - (participantView.frame.origin.x + participantView.frame.size.width + 5),
                                                         self.textFieldParticipant.frame.size.height);
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(changeCellHeightWith:cellRow:)]) {
        [self.delegate changeCellHeightWith:self.textFieldOriginY + self.textFieldParticipant.frame.size.height + kSpaceBetweenParticipantViewAndCellBottom cellRow:self.row];
    }
    
    self.textFieldParticipant.text = @"";
    [self.textFieldParticipant becomeFirstResponder];
}

- (void)arrangeParticipantViews {
    
    self.textFieldOriginY = self.labelTo.frame.origin.y;
    NSMutableArray *arrayAddedViews = [[NSMutableArray alloc] init];
    for (ParticipantView *view in self.arrayParticipantView) {
        ParticipantView *lastView = [arrayAddedViews lastObject];
        if (lastView) {
            CGFloat lastParticipantWidth = self.buttonCcBcc.frame.origin.x - (lastView.frame.origin.x + lastView.frame.size.width + kSpaceBetweenParticipants);
            if (lastParticipantWidth <= kTextFieldMaxWidth) {
                self.textFieldOriginY += kHeightBetweenParticipants;
                view.frame = CGRectMake(self.labelTo.frame.origin.x, self.textFieldOriginY, view.frame.size.width, view.frame.size.height);
            }
            else {
                view.frame = CGRectMake(lastView.frame.origin.x + lastView.frame.size.width + kSpaceBetweenParticipants,
                                        self.textFieldOriginY,
                                        view.frame.size.width,
                                        view.frame.size.height);
            }
        }
        else {
            view.frame = CGRectMake(kfirstParticipantOriginX, self.textFieldOriginY, view.frame.size.width, view.frame.size.height);
        }
        [arrayAddedViews addObject:view];
    }
}

- (void)createParticipantWithEmail:(NSString *)email {
    
    ParticipantView *participantView = [[ParticipantView alloc] initWithEmail:email];
    [participantView create];
    if (!self.sentScreen) {
        participantView.frame = CGRectMake(self.textFieldParticipant.frame.origin.x, self.textFieldOriginY, participantView.frame.size.width, participantView.frame.size.height);
    }
    [self.viewContainer addSubview:participantView];
    participantView.delegate = self;
    [self.arrayParticipantView addObject:participantView];
}

#pragma mark - Public Methods
- (void)configureCell:(NSInteger)row hideCcBcc:(BOOL)hideCcBcc {
    
    self.row = row;
    switch (row) {
        case 0:
            self.labelTo.text = @"To:";
            self.buttonCcBcc.hidden = hideCcBcc;
            self.buttonArrowUp.hidden = !hideCcBcc;
            break;
        case 1:
            self.labelTo.text = @"Cc:";
            self.buttonCcBcc.hidden = YES;
            self.buttonArrowUp.hidden = YES;
            break;
        case 2:
            self.labelTo.text = @"Bcc:";
            self.buttonCcBcc.hidden = YES;
            self.buttonArrowUp.hidden = YES;
            break;
            
        default:
            break;
    }
}

- (void)configureCellForSentWithRow:(NSInteger)row withParticipants:(NSArray *)arrayParticipants {
    
    self.sentScreen = YES;
    self.buttonCcBcc.hidden = YES;
    self.buttonArrowUp.hidden = YES;
    self.textFieldParticipant.hidden = YES;
    self.row = row;
    switch (row) {
        case 0:
            self.labelTo.text = @"To:";
            break;
        case 1:
            self.labelTo.text = @"Cc:";
            break;
        case 2:
            self.labelTo.text = @"Bcc:";
            break;
            
        default:
            break;
    }
    
    for (NSString *email in arrayParticipants) {
        [self createParticipantWithEmail:email];
    }
    [self arrangeParticipantViews];
}


#pragma mark - UITextFieldDelegate Methods
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    if ([self.delegate respondsToSelector:@selector(participantEmail:)]) {
        [self.delegate participantEmail:textField.text];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {

    [textField resignFirstResponder];
    if (textField.text.length > 0) {
        NSString *email = textField.text;
        [self createParticipantWithEmail:textField.text];
        [self determineTextFieldsFrame];
        
        if ([self.delegate respondsToSelector:@selector(addParticipantsEmail:row:)]) {
            [self.delegate addParticipantsEmail:email row:self.row];
        }
    }
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    
    if (textField.text.length > 0) {
        NSString *email = textField.text;
        [self createParticipantWithEmail:textField.text];
        [self determineTextFieldsFrame];
        
        if ([self.delegate respondsToSelector:@selector(addParticipantsEmail:row:)]) {
            [self.delegate addParticipantsEmail:email row:self.row];
        }
    }
    return YES;
}


#pragma mark - ParticipantViewDelegate Methods
- (void)onCloseClicked:(id)participantView {
    
    ParticipantView *removdParticipant = (ParticipantView *)participantView;
    [self.arrayParticipantView removeObject:removdParticipant];
    [removdParticipant removeFromSuperview];
    
    [self arrangeParticipantViews];
    [self determineTextFieldsFrame];
}

@end
