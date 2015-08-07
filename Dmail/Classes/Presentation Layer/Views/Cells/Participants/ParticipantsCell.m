//
//  ParticipantsCell.m
//  Dmail
//
//  Created by Karen Petrosyan on 6/27/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "ParticipantsCell.h"
#import "ParticipantView.h"
#import "ContactModel.h"
#import "VENTokenField.h"

#import <Realm/Realm.h>
#import "RMModelRecipient.h"


CGFloat kTextFieldMaxWidth = 70;
CGFloat kSpaceBetweenParticipants = 5;
CGFloat kWidthBetweenParticipants = 5;
CGFloat kHeightBetweenParticipants = 30;
CGFloat kSpaceBetweenParticipantViewAndCellBottom = 9;
CGFloat kfirstParticipantOriginX = 34;

@interface ParticipantsCell () <ParticipantViewDelegate, VENTokenFieldDelegate, VENTokenFieldDataSource>

@property (weak, nonatomic) IBOutlet VENTokenField *tokenField;
@property (nonatomic, weak) IBOutlet UIView *viewContainer;
@property (nonatomic, weak) IBOutlet UILabel *labelTo;
@property (nonatomic, weak) IBOutlet UIButton *buttonCcBcc;
@property (nonatomic, weak) IBOutlet UIButton *buttonArrowUp;
@property (nonatomic, weak) IBOutlet UITextField *textFieldParticipant;

@property (strong, nonatomic) NSMutableArray *names;

@property (nonatomic, strong) NSString *messageId;
@property (nonatomic, strong) NSMutableArray *arrayParticipantView;
@property (nonatomic, assign) NSInteger row;
@property (nonatomic, assign) CGFloat textFieldOriginY;
@property (nonatomic, assign) CGFloat defaultTextFieldWidth;
@property (nonatomic, assign) BOOL sentScreen;


@end

@implementation ParticipantsCell

- (void)awakeFromNib {
    
    self.textFieldOriginY = 14;
    self.defaultTextFieldWidth = self.buttonCcBcc.frame.origin.x - (self.labelTo.frame.origin.x + self.labelTo.frame.size.width + 2*kWidthBetweenParticipants);
    self.arrayParticipantView = [[NSMutableArray alloc] init];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
//    [self.textFieldParticipant becomeFirstResponder];
}

- (void)prepareForReuse {
    
    self.textFieldParticipant.text = nil;
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
        CGFloat cellHeight = self.textFieldOriginY + self.textFieldParticipant.frame.size.height + kSpaceBetweenParticipantViewAndCellBottom;
        cellHeight = [self defineCellHeightWith:cellHeight];
        [self.delegate changeCellHeightWith:cellHeight cellRow:self.row];
    }
    
    [self.textFieldParticipant becomeFirstResponder];
    self.textFieldParticipant.text = @"";
}

- (CGFloat)defineCellHeightWith:(CGFloat)cellHeight {
    
    CGFloat height = 57;
    if (cellHeight > height) {
        height = (cellHeight/57 + 1)*height;
    }
    
    return height;
}

- (void)arrangeParticipantViews {
    
    self.textFieldOriginY = 14;
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

- (void)createParticipantWithEmail:(NSString *)email withName:(NSString *)name {
    
    ParticipantView *participantView = [[ParticipantView alloc] initWithEmail:email withName:name];
    if (self.sentScreen) {
        RLMRealm *realm = [RLMRealm defaultRealm];
        RLMResults *recipients = [[RMModelRecipient objectsInRealm:realm where:@"(type = %@ || type = %@ || type = %@) AND messageId = %@ AND recipient = %@", @"TO", @"CC", @"BCC", self.messageId, email] sortedResultsUsingProperty:@"position" ascending:NO];
        RMModelRecipient *recipient = [recipients firstObject];
        [participantView createForSent:self.sentScreen withAccess:recipient.access];
    }
    else {
        [participantView createForSent:self.sentScreen withAccess:@"GRANTED"];
    }
    
    if (!self.sentScreen) {
        participantView.frame = CGRectMake(self.textFieldParticipant.frame.origin.x, self.textFieldOriginY, participantView.frame.size.width, participantView.frame.size.height);
    }
    [self.viewContainer addSubview:participantView];
    participantView.delegate = self;
    [self.arrayParticipantView addObject:participantView];
}


#pragma mark - Public Methods
- (void)configureCell:(NSInteger)row hideCcBcc:(BOOL)hideCcBcc {
    
    self.names = [NSMutableArray array];
    self.tokenField.delegate = self;
    self.tokenField.dataSource = self;
    switch (row) {
        case 0:
            self.tokenField.toLabelText = @"To:";
            self.buttonCcBcc.hidden = hideCcBcc;
            self.buttonArrowUp.hidden = !hideCcBcc;
            break;
        case 1:
            self.tokenField.toLabelText = @"Cc:";
            self.buttonCcBcc.hidden = YES;
            self.buttonArrowUp.hidden = YES;
            break;
        case 2:
            self.tokenField.toLabelText = @"Bcc:";
            self.buttonCcBcc.hidden = YES;
            self.buttonArrowUp.hidden = YES;
            break;
        default:
            break;
    }
    [self.tokenField setColorScheme:[UIColor colorWithRed:61/255.0f green:149/255.0f blue:206/255.0f alpha:1.0f]];
    self.tokenField.delimiters = @[@",", @";", @"--"];
    [self.tokenField becomeFirstResponder];
    
//    self.textFieldParticipant.tag = 1;
//    self.row = row;
}

- (void)configureCellForSentWithRow:(NSInteger)row withParticipants:(NSArray *)arrayParticipants participantsType:(NSString *)participantsType messageId:(NSString *)messageId {
    
    self.labelTo.text = participantsType;
    self.labelTo.text = [self.labelTo.text stringByAppendingString:@":"];
    self.messageId = messageId;
    self.sentScreen = YES;
    self.buttonCcBcc.hidden = YES;
    self.buttonArrowUp.hidden = YES;
    self.textFieldParticipant.hidden = YES;
    self.row = row;
    for (NSString *email in arrayParticipants) {
        [self createParticipantWithEmail:email withName:nil];
    }
    [self arrangeParticipantViews];
}

- (void)addParticipantWithContactModel:(ContactModel *)contactModel {
    
    self.participantSet = YES;
    [self createParticipantWithEmail:contactModel.email withName:contactModel.fullName];
    [self determineTextFieldsFrame];
}


#pragma mark - UITextFieldDelegate Methods
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    self.participantSet = NO;
    if ([self.delegate respondsToSelector:@selector(startEditparticipantName:)]) {
        [self.delegate startEditparticipantName:self.row];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {

    [textField resignFirstResponder];
    if (textField.text.length > 0) {
        NSString *email = textField.text;
        [self createParticipantWithEmail:textField.text withName:nil];
        [self determineTextFieldsFrame];
        
        if ([self.delegate respondsToSelector:@selector(addParticipantsEmail:row:)]) {
            [self.delegate addParticipantsEmail:email row:self.row];
        }
    }
    if ([self.delegate respondsToSelector:@selector(changeTableOffsetY)]) {
        [self.delegate changeTableOffsetY];
    }
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    
    if (textField.text.length > 0 && !self.participantSet) {
        self.participantSet = NO;
        NSString *email = textField.text;
        [self createParticipantWithEmail:textField.text withName:nil];
        [self determineTextFieldsFrame];
        
        if ([self.delegate respondsToSelector:@selector(addParticipantsEmail:row:)]) {
            [self.delegate addParticipantsEmail:email row:self.row];
        }
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if ([self.delegate respondsToSelector:@selector(participantEmail:)]) {
        [self.delegate participantEmail:string];
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
    if ([self.delegate respondsToSelector:@selector(removeParticipantsEmail:row:)]) {
        [self.delegate removeParticipantsEmail:removdParticipant.email row:self.row];
    }
}

- (void)onRevokeClicked:(id)participantView {
    
    ParticipantView *revokedParticipant = (ParticipantView *)participantView;
    if ([self.delegate respondsToSelector:@selector(revokeParticipantWithEmail: name:)]) {
        [self.delegate revokeParticipantWithEmail:revokedParticipant.email name:revokedParticipant.name];
    }
}



#pragma mark - VENTokenFieldDelegate

- (void)tokenField:(VENTokenField *)tokenField didEnterText:(NSString *)text
{
    [self.names addObject:text];
    [self.tokenField reloadData];
}

- (void)tokenField:(VENTokenField *)tokenField didDeleteTokenAtIndex:(NSUInteger)index
{
    [self.names removeObjectAtIndex:index];
    [self.tokenField reloadData];
}


#pragma mark - VENTokenFieldDataSource

- (NSString *)tokenField:(VENTokenField *)tokenField titleForTokenAtIndex:(NSUInteger)index
{
    return self.names[index];
}

- (NSUInteger)numberOfTokensInTokenField:(VENTokenField *)tokenField
{
    return [self.names count];
}

- (NSString *)tokenFieldCollapsedText:(VENTokenField *)tokenField
{
    return [NSString stringWithFormat:@"%tu people", [self.names count]];
}

@end
