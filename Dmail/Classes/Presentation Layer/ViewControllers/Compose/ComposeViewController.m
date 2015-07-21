//
//  ComposeViewController.m
//  Dmail
//
//  Created by Karen Petrosyan on 6/16/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "ComposeViewController.h"

// service
#import "ServiceMessage.h"
#import "ServiceContact.h"

// view

#import "ParticipantsCell.h"
#import "MessageComposeCell.h"
#import "ContactCell.h"

// model
#import "ContactModel.h"

@interface ComposeViewController () <ParticipantsCellDelegate, MessageComposeCellDelegate>

@property (nonatomic, weak) IBOutlet UIButton *buttonSend;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UITableView *tableViewContacts;
@property (nonatomic, weak) IBOutlet BaseNavigationController *viewNavigation;
@property (nonatomic, weak) IBOutlet UIView *viewSecure;

@property (nonatomic, strong) ServiceMessage *serviceMessage;
@property (nonatomic, strong) ServiceContact *serviceContact;

@property (nonatomic, strong) NSMutableArray *arrayTableItems;
@property (nonatomic, strong) NSMutableArray *arrayContacts;
@property (nonatomic, strong) NSMutableArray *arrayTo;
@property (nonatomic, strong) NSMutableArray *arrayCc;
@property (nonatomic, strong) NSMutableArray *arrayBcc;
@property (nonatomic, strong) NSString *messageSubject;
@property (nonatomic, strong) NSString *messageBody;
@property (nonatomic, strong) NSString *participantEmail;
@property (nonatomic, assign) CGFloat toCellHeight;
@property (nonatomic, assign) CGFloat ccCellHeight;
@property (nonatomic, assign) CGFloat bccCellHeight;
@property (nonatomic, assign) CGFloat messageContentCellHeight;
@property (nonatomic, assign) NSInteger selectedRow;
@property (nonatomic, assign) BOOL backClicked;

@end

@implementation ComposeViewController


#pragma mark - Class Methods
- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        _serviceMessage = [[ServiceMessage alloc] init];
        _serviceContact = [[ServiceContact alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setupController];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newMessageSent) name:NotificationNewMessageSent object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageSentError) name:NotificationNewMessageSentError object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    self.backClicked = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    if (self.replyedRecipientEmail) {
        ContactModel *contactModel = [[ContactModel alloc] initWithEmail:self.replyedRecipientEmail fullName:self.replyedRecipientName firstName:nil lastName:nil contactId:nil urlPhoto:nil];
        ParticipantsCell *participantCell = (ParticipantsCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedRow inSection:0]];
        participantCell.participantSet = YES;
        [participantCell addParticipantWithContactModel:contactModel];
        [self addParticipantsEmail:contactModel.email row:self.selectedRow];
        [self.tableView setContentOffset:CGPointMake(self.tableView.contentOffset.x, 0) animated:YES];
        [self.tableView reloadData];
    }
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Action Methods
- (IBAction)sendClicked:(id)sender {
    
    [self.view endEditing:YES];
    if ([self.arrayTo count] > 0 && !self.backClicked) {
        [self showLoadingView];
        [self.serviceMessage sendMessage:self.messageBody messageSubject:self.messageSubject to:self.arrayTo cc:self.arrayCc bcc:self.arrayBcc completionBlock:^(id data, ErrorDataModel *error) {
            
        }];
    }
}

- (IBAction)backClicked:(id)sender {
    
    self.backClicked = YES;
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Private Methods
- (void)keyboardWillShow:(NSNotification*)notification {
    
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    CGRect frame = self.tableViewContacts.frame;
    self.tableViewContacts.translatesAutoresizingMaskIntoConstraints = YES;
    self.tableViewContacts.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, [UIScreen mainScreen].bounds.size.height - frame.origin.y - keyboardFrameBeginRect.size.height);
}

- (void)setupController {
    
    self.tableViewContacts.hidden = YES;
    self.messageBody = @"";
    self.participantEmail = @"";
    
    self.arrayTableItems = [[NSMutableArray alloc] initWithObjects:@"1",@"4", nil];
    [self createTableItems];
    
    self.messageContentCellHeight = [UIScreen mainScreen].bounds.size.height - (65 + self.toCellHeight + self.viewSecure.frame.size.height);
    self.arrayTo = [[NSMutableArray alloc] init];
    self.arrayCc = [[NSMutableArray alloc] init];
    self.arrayBcc = [[NSMutableArray alloc] init];
    
//    self.viewNavigation.layer.masksToBounds = NO;
//    self.viewNavigation.layer.shadowOffset = CGSizeMake(0, 2);
//    self.viewNavigation.layer.shadowColor = [UIColor colorWithRed:197.0/255.0 green:215.0/255.0 blue:227.0/255.0 alpha:1].CGColor;
//    self.viewNavigation.layer.shadowRadius = 5;
//    self.viewNavigation.layer.shadowOpacity = 0.8;
    
    UIBezierPath *secureMaskPath = [UIBezierPath bezierPathWithRoundedRect:self.viewSecure.bounds byRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerBottomRight) cornerRadii:CGSizeMake(5.0, 5.0)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.view.bounds;
    maskLayer.path  = secureMaskPath.CGPath;
    self.viewSecure.layer.mask = maskLayer;
    
    CAShapeLayer *borderLayer = [[CAShapeLayer alloc] init];
    borderLayer.frame = self.view.bounds;
    borderLayer.path  = secureMaskPath.CGPath;
    borderLayer.lineWidth   = 2.0f;
    borderLayer.strokeColor = [UIColor colorWithRed:197.0/255.0 green:215.0/255.0 blue:227.0/255.0 alpha:1].CGColor;
    borderLayer.fillColor = [UIColor clearColor].CGColor;
    [self.viewSecure.layer addSublayer:borderLayer];
}

- (void)createTableItems {
    
    self.toCellHeight = 57;
    self.ccCellHeight = 0;
    self.bccCellHeight = 0;
//    [self.arrayTableItems addObject:@"1"];
//    [self.arrayTableItems addObject:@"4"];
//    self.bccCellHeight = 0;
//    self.messageContentCellHeight = 450;
//    if ([self.arrayTo count] > 0) {
//        [self.arrayTableItems addObject:@"1"];
//        self.toCellHeight = 57;
//    }
//    if ([self.arrayCc count] > 0) {
//        self.ccCellHeight = 57;
//        [self.arrayTableItems addObject:@"2"];
//    }
//    if ([self.arrayBcc count] > 0) {
//        self.bccCellHeight = 57;
//        if ([self.arrayCc count] > 0) {
//        }
//        else {
//            [self.arrayTableItems addObject:@"2"];
//            [self.arrayTableItems addObject:@"3"];
//        }
//    }
//    [self.arrayTableItems addObject:@"4"];
}

- (void)newMessageSent {
    
    [self hideLoadingView];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)messageSentError {
    
    [self hideLoadingView];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dmail" message:@"Error With Sending Message" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert show];
}


#pragma mark - TableView DataSource & Delegate Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat rowHeight = 0;
    if (tableView == self.tableView) {
        if ([self.arrayTableItems count] == 2) {
            if (indexPath.row == 0) {
                rowHeight = self.toCellHeight;
            }
            else {
                rowHeight = [UIScreen mainScreen].bounds.size.height - (70 + self.toCellHeight + self.ccCellHeight + self.bccCellHeight + self.viewSecure.frame.size.height);//self.messageContentCellHeight;
            }
        }
        else {
            switch (indexPath.row) {
                case 0:
                    rowHeight = self.toCellHeight;
                    break;
                case 1:
                    rowHeight = self.ccCellHeight;
                    break;
                case 2:
                    rowHeight = self.bccCellHeight;
                    break;
                case 3:
                    rowHeight = [UIScreen mainScreen].bounds.size.height - (70 + self.toCellHeight + self.ccCellHeight + self.bccCellHeight + self.viewSecure.frame.size.height);//[UIScreen mainScreen].bounds.size.height - 65;//(65 + self.toCellHeight +self.ccCellHeight + self.bccCellHeight + self.viewSecure.frame.size.height);
                    break;
                default:
                    break;
            }
        }
    }
    else {
        rowHeight = 44;
    }
    return rowHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (tableView == self.tableView) {
        return [self.arrayTableItems count];
    }
    else {
        return [self.arrayContacts count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.tableView) {
        if ([self.arrayTableItems count] == 2) {
            switch (indexPath.row) {
                case 0: {
                    ParticipantsCell *participantsCell = [tableView dequeueReusableCellWithIdentifier:@"participantsCellId"];
                    participantsCell.delegate = self;
                    [participantsCell configureCell:indexPath.row hideCcBcc:([self.arrayTableItems count]==2?NO:YES)];
                    participantsCell.selectionStyle = UITableViewCellSelectionStyleNone;
                    
                    return participantsCell;
                }
                    break;
                case 1: {
                    MessageComposeCell *messageComposeCell = [tableView dequeueReusableCellWithIdentifier:@"messageComposeCellId"];
                    messageComposeCell.delegate = self;
                    [messageComposeCell configureCell];
                    messageComposeCell.selectionStyle = UITableViewCellSelectionStyleNone;
                    
                    return messageComposeCell;
                }
                    break;
                default:
                    break;
            }
        }
        else {
            switch (indexPath.row) {
                case 0: {
                    ParticipantsCell *participantsCell = [tableView dequeueReusableCellWithIdentifier:@"participantsCellId"];
                    participantsCell.translatesAutoresizingMaskIntoConstraints = YES;
                    participantsCell.delegate = self;
                    [participantsCell configureCell:indexPath.row hideCcBcc:([self.arrayTableItems count]==2?NO:YES)];
                    participantsCell.selectionStyle = UITableViewCellSelectionStyleNone;
                    
                    return participantsCell;
                }
                    break;
                case 1: {
                    ParticipantsCell *participantsCell = [tableView dequeueReusableCellWithIdentifier:@"participantsCellId"];
                    participantsCell.delegate = self;
                    [participantsCell configureCell:indexPath.row hideCcBcc:([self.arrayTableItems count]==2?NO:YES)];
                    participantsCell.selectionStyle = UITableViewCellSelectionStyleNone;
                    
                    return participantsCell;
                }
                    break;
                case 2: {
                    ParticipantsCell *participantsCell = [tableView dequeueReusableCellWithIdentifier:@"participantsCellId"];
                    participantsCell.delegate = self;
                    [participantsCell configureCell:indexPath.row hideCcBcc:([self.arrayTableItems count]==2?NO:YES)];
                    participantsCell.selectionStyle = UITableViewCellSelectionStyleNone;
                    
                    return participantsCell;
                }
                    break;
                case 3: {
                    MessageComposeCell *messageComposeCell = [tableView dequeueReusableCellWithIdentifier:@"messageComposeCellId"];
                    messageComposeCell.delegate = self;
                    [messageComposeCell configureCell];
                    messageComposeCell.selectionStyle = UITableViewCellSelectionStyleNone;
                    
                    return messageComposeCell;
                }
                    break;
                default:
                    break;
            }
        }
    }
    else {
        ContactCell *contactCell = [tableView dequeueReusableCellWithIdentifier:@"ContactCellID"];
        [contactCell configureCellWithContactModel:[self.arrayContacts objectAtIndex:indexPath.row] searchText:self.participantEmail];
        
        return contactCell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.tableViewContacts) {
        ContactModel *contactModel = [self.arrayContacts objectAtIndex:indexPath.row];
        if (contactModel.email) {
            ParticipantsCell *participantCell = (ParticipantsCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedRow inSection:0]];
            participantCell.participantSet = YES;
            [participantCell addParticipantWithContactModel:contactModel];
            self.tableViewContacts.hidden = YES;
            [self addParticipantsEmail:contactModel.email row:self.selectedRow];
            [self.tableView setContentOffset:CGPointMake(self.tableView.contentOffset.x, 0) animated:YES];
        }
    }
}


#pragma mark - ParticipantsCellDelegate Methods
- (void)onCCBCCClickedd {
    
    [self.arrayTableItems addObject:@"2"];
    [self.arrayTableItems addObject:@"3"];
    self.ccCellHeight = 57;
    self.bccCellHeight = 57;
    NSIndexPath *indexPathCc = [NSIndexPath indexPathForRow:1 inSection:0];
    NSIndexPath *indexPathBcc = [NSIndexPath indexPathForRow:2 inSection:0];
    
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[indexPathCc,indexPathBcc] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    
    ParticipantsCell *cell = (ParticipantsCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [cell configureCell:0 hideCcBcc:YES];
}

- (void)onArrowUpClicked {
    
    [self.arrayTableItems removeObjectAtIndex:[self.arrayTableItems count] - 1];
    [self.arrayTableItems removeObjectAtIndex:[self.arrayTableItems count] - 1];
    self.ccCellHeight = 0;
    self.bccCellHeight = 0;
    NSIndexPath *indexPathCc = [NSIndexPath indexPathForRow:1 inSection:0];
    NSIndexPath *indexPathBcc = [NSIndexPath indexPathForRow:2 inSection:0];
    
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[indexPathCc,indexPathBcc] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    
    ParticipantsCell *cell = (ParticipantsCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [cell configureCell:0 hideCcBcc:NO];
}

- (void)changeCellHeightWith:(CGFloat)height cellRow:(NSInteger)row {
    
    switch (row) {
        case 0:
            self.toCellHeight = height;
            break;
        case 1:
            self.ccCellHeight = height;
            break;
        case 2:
            self.bccCellHeight = height;
            break;
            
        default:
            break;
    }
    
    [self.tableView reloadData];
}

- (void)participantEmail:(NSString *)email {
    
    if ([email isEqualToString:@""]) {
        self.participantEmail = [self.participantEmail substringToIndex:self.participantEmail.length - 1];
    }
    else {
        self.participantEmail = [self.participantEmail stringByAppendingString:email];
    }
    
    self.arrayContacts = [self.serviceContact getContactsWithName:self.participantEmail];
    if ([self.arrayContacts count] > 0) {
        self.tableViewContacts.hidden = NO;
        [self.tableViewContacts reloadData];
    }
    else {
        self.tableViewContacts.hidden = YES;
    }
}

- (void)startEditparticipantName:(NSInteger)cellRow {
    
    self.participantEmail = @"";
    self.selectedRow = cellRow;
    switch (cellRow) {
        case 0:
            [self.tableView setContentOffset:CGPointMake(self.tableView.contentOffset.x, 0) animated:YES];
            break;
        case 1:
            [self.tableView setContentOffset:CGPointMake(self.tableView.contentOffset.x, self.toCellHeight) animated:YES];
            break;
        case 2:
            [self.tableView setContentOffset:CGPointMake(self.tableView.contentOffset.x, self.toCellHeight + self.ccCellHeight) animated:YES];
            break;
        default:
            break;
    }
}

- (void)addParticipantsEmail:(NSString *)email row:(NSInteger)row {
    
    switch (row) {
        case 0:
            [self.arrayTo addObject:email];
            break;
        case 1:
            [self.arrayCc addObject:email];
            break;
        case 2:
            [self.arrayBcc addObject:email];
            break;
            
        default:
            break;
    }
    if ([self.arrayTo count] > 0 || [self.arrayCc count] > 0 || [self.arrayBcc count] > 0) {
        [self.buttonSend setImage:[UIImage imageNamed:@"buttonSendEnable"] forState:UIControlStateNormal];
        self.buttonSend.enabled = YES;
    }
    else {
        [self.buttonSend setImage:[UIImage imageNamed:@"buttonSendDisable"] forState:UIControlStateNormal];
        self.buttonSend.enabled = NO;
    }
    self.tableViewContacts.hidden = YES;
}

- (void)removeParticipantsEmail:(NSString *)email row:(NSInteger)row {
    
    switch (row) {
        case 0:
            [self.arrayTo removeObject:email];
            break;
        case 1:
            [self.arrayCc removeObject:email];
            break;
        case 2:
            [self.arrayBcc removeObject:email];
            break;
            
        default:
            break;
    }
    if ([self.arrayTo count] > 0 || [self.arrayCc count] > 0 || [self.arrayBcc count] > 0) {
        [self.buttonSend setImage:[UIImage imageNamed:@"buttonSendEnable"] forState:UIControlStateNormal];
        self.buttonSend.enabled = YES;
    }
    else {
        [self.buttonSend setImage:[UIImage imageNamed:@"buttonSendDisable"] forState:UIControlStateNormal];
        self.buttonSend.enabled = NO;
    }
}

- (void)changeTableOffsetY {
    
    [self.tableView setContentOffset:CGPointMake(self.tableView.contentOffset.x, 0) animated:YES];
}


#pragma mark - MessageComposeCellDelegate Methods
- (void)messageSubject:(NSString *)subject {
    
    self.messageSubject = subject;
}

- (void)messageBody:(NSString *)letter {
    
    if ([letter isEqualToString:@""]) {
        self.messageBody = [self.messageBody substringToIndex:self.messageBody.length - 1];
    }
    else {
        self.messageBody = [self.messageBody stringByAppendingString:letter];
    }
}

@end
