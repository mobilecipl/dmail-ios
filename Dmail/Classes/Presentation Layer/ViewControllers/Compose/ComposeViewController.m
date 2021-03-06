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
#import "ContactCell.h"
#import "VENTokenField.h"
#import "TextViewPlaceHolder.h"
#import "CustomAlertView.h"

// model
#import "ContactModel.h"

@interface ComposeViewController () <VENTokenFieldDelegate, VENTokenFieldDataSource, CustomAlertViewDelegate>

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UITableView *tableViewContacts;
@property (nonatomic, weak) IBOutlet UIWebView *webEncryptor;
@property (nonatomic, weak) IBOutlet UIView *viewMessageCompose;
@property (nonatomic, weak) IBOutlet UIView *viewSecure;
@property (nonatomic, weak) IBOutlet UIView *viewTextViewContainer;
@property (nonatomic, weak) IBOutlet UIButton *buttonSend;
@property (nonatomic, weak) IBOutlet UIButton *buttonCcBcc;
@property (nonatomic, weak) IBOutlet UIButton *buttonUpArrow;
@property (nonatomic, weak) IBOutlet UITextField *textFieldSubject;
@property (nonatomic, weak) IBOutlet UITextView *textViewBody;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *constraitHeight;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *constraitBottomTextView;
@property (nonatomic, weak) IBOutlet VENTokenField *fieldTo;
@property (nonatomic, weak) IBOutlet VENTokenField *fieldCc;
@property (nonatomic, weak) IBOutlet VENTokenField *fieldBcc;
@property (nonatomic, weak) IBOutlet BaseNavigationController *viewNavigation;

@property (nonatomic, strong) VENTokenField *selectedToken;
@property (nonatomic, strong) ContactModel *tempContactModel;
@property (nonatomic, strong) ServiceMessage *serviceMessage;
@property (nonatomic, strong) ServiceContact *serviceContact;

@property (nonatomic, strong) NSMutableArray *arrayTo;
@property (nonatomic, strong) NSMutableArray *arrayCc;
@property (nonatomic, strong) NSMutableArray *arrayBcc;
@property (nonatomic, strong) NSMutableArray *arrayTempTo;
@property (nonatomic, strong) NSMutableArray *arrayTempCc;
@property (nonatomic, strong) NSMutableArray *arrayTempBcc;
@property (nonatomic, strong) NSMutableArray *arrayContacts;

@property (nonatomic, assign) CGFloat textViewHeight;
@property (nonatomic, assign) CGFloat keyboardHeight;
@property (nonatomic, assign) CGFloat scrollViewContentOffset;
@property (nonatomic, assign) long long timer;
@property (nonatomic, assign) BOOL backClicked;
@property (nonatomic, assign) BOOL ccBccOpened;

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
    
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:@"Subject" attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithRed:48.0/255.0 green:56.0/255.0 blue:61.0/255.0 alpha:1],
                                                                                                     NSFontAttributeName : [UIFont fontWithName:@"ProximaNova-Semibold" size:15]}];
    self.textFieldSubject.attributedPlaceholder = string;
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
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, self.scrollView.contentSize.height + self.fieldCc.frame.size.height);
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Action Methods
- (IBAction)sendClicked:(id)sender {
    
    [self.view endEditing:YES];
    [self showLoadingView];
    [self.webEncryptor loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"GiberishEnc" ofType:@"html"]isDirectory:NO]]];
}

- (IBAction)backClicked:(id)sender {
    
    self.backClicked = YES;
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onCcBccClickedd:(id)sender {
    
    self.ccBccOpened = YES;
    self.constraitHeight.constant = 221;
    self.fieldCc.alpha = 1;
    self.fieldBcc.alpha = 1;
    self.buttonCcBcc.alpha = 0;
    self.buttonUpArrow.alpha = 1;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, self.scrollView.contentSize.height + 2*self.fieldCc.frame.size.height);
    [self defineTextViewFrame];
}

- (IBAction)onArrowUpClicked:(id)sender {
    
    self.ccBccOpened = NO;
    self.constraitHeight.constant = 101;
    self.fieldCc.alpha = 0;
    self.fieldBcc.alpha = 0;
    self.buttonCcBcc.alpha = 1;
    self.buttonUpArrow.alpha = 0;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, self.scrollView.contentSize.height - 2*self.fieldCc.frame.size.height);
    [self defineTextViewFrame];
}


#pragma mark - Private Methods
- (void)setupController {
    
    [self setupViewLayers];
    [self setupRecipientsFields];
    
    if (self.replyedMessageSubject) {
        self.textFieldSubject.text = [NSString stringWithFormat:@"Re:%@",self.replyedMessageSubject];
        if (self.replyedRecipientName) {
            self.tempContactModel = [[ContactModel alloc] initWithEmail:self.replyedRecipientEmail fullName:self.replyedRecipientName firstName:nil lastName:nil contactId:nil urlPhoto:nil addressBook:NO];
            [self.fieldTo addTokenWithString:self.replyedRecipientName];
        }
        else {
            [self.fieldTo addTokenWithString:self.replyedRecipientEmail];
        }
    }
}

- (void)setupViewLayers {
    
    self.viewMessageCompose.layer.masksToBounds = YES;
    self.viewMessageCompose.layer.cornerRadius = 5;
    self.viewMessageCompose.layer.borderColor = [UIColor colorWithRed:197.0/255.0 green:215.0/255.0 blue:227.0/255.0 alpha:1].CGColor;
    self.viewMessageCompose.layer.borderWidth = 1;
    
    self.tableViewContacts.layer.masksToBounds = YES;
    self.tableViewContacts.layer.cornerRadius = 5;
    self.tableViewContacts.layer.borderColor = [UIColor colorWithRed:197.0/255.0 green:215.0/255.0 blue:227.0/255.0 alpha:1].CGColor;
    self.tableViewContacts.layer.borderWidth = 1;
    self.tableViewContacts.hidden = YES;
}

- (void)setupRecipientsFields {
    
    self.arrayTo = [NSMutableArray array];
    self.arrayTempTo = [NSMutableArray array];
    self.fieldTo.delegate = self;
    self.fieldTo.dataSource = self;
    [self.fieldTo setColorScheme:[UIColor colorWithRed:61/255.0f green:149/255.0f blue:206/255.0f alpha:1.0f]];
    self.fieldTo.toLabelText = @"To:";
    self.fieldTo.delimiters = @[@",", @";", @" "];
    if (self.replyedMessageSubject) {
        [self.textViewBody becomeFirstResponder];
    }
    else {
        [self.fieldTo becomeFirstResponder];
    }
    
    self.arrayCc = [NSMutableArray array];
    self.arrayTempCc = [NSMutableArray array];
    self.fieldCc.delegate = self;
    self.fieldCc.dataSource = self;
    [self.fieldCc setColorScheme:[UIColor colorWithRed:61/255.0f green:149/255.0f blue:206/255.0f alpha:1.0f]];
    self.fieldCc.toLabelText = @"Cc:";
    self.fieldCc.delimiters = @[@",", @";", @" "];
    
    self.arrayBcc = [NSMutableArray array];
    self.arrayTempBcc = [NSMutableArray array];
    self.fieldBcc.delegate = self;
    self.fieldBcc.dataSource = self;
    [self.fieldBcc setColorScheme:[UIColor colorWithRed:61/255.0f green:149/255.0f blue:206/255.0f alpha:1.0f]];
    self.fieldBcc.toLabelText = @"Bcc:";
    self.fieldBcc.delimiters = @[@",", @";", @" "];
}

- (void)keyboardWillShow:(NSNotification*)notification {
    
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    self.keyboardHeight = keyboardFrameBeginRect.size.height;
}

- (void)newMessageSent {
    
    [self hideLoadingView];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)messageSentError {
    
    [self hideLoadingView];
    [self showErrorAlertWithTitle:@"Error" message:@"Unable to send message at this time. Please try again."];
}

- (void)addRecipientWithField:(VENTokenField *)tokenField withName:(id)name {
    
    if (self.tempContactModel) {
        if (tokenField == self.fieldTo) {
            [self.arrayTempTo addObject:self.tempContactModel];
        }
        else if (tokenField == self.fieldCc) {
            [self.arrayTempCc addObject:self.tempContactModel];
        }
        else if (tokenField == self.fieldBcc) {
            [self.arrayTempBcc addObject:self.tempContactModel];
        }
    }
    else {
        if (tokenField == self.fieldTo) {
            [self.arrayTempTo addObject:name];
        }
        else if (tokenField == self.fieldCc) {
            [self.arrayTempCc addObject:name];
        }
        else if (tokenField == self.fieldBcc) {
            [self.arrayTempBcc addObject:name];
        }
    }
    self.tempContactModel = nil;
}

- (void)removRecipientWithField:(VENTokenField *)tokenField index:(NSInteger)index {
    
    if (tokenField == self.fieldTo) {
        [self.arrayTempTo removeObjectAtIndex:index];
    }
    else if (tokenField == self.fieldCc) {
        [self.arrayTempCc removeObjectAtIndex:index];
    }
    else if (tokenField == self.fieldBcc) {
        [self.arrayTempBcc removeObjectAtIndex:index];
    }
}

- (void)defineTextViewFrame {
    
    CGRect frame = self.textViewBody.frame;
    CGFloat textViewOriginY = self.scrollView.frame.origin.y + self.viewTextViewContainer.frame.origin.y + self.textViewBody.frame.origin.y;
    self.textViewBody.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, [UIScreen mainScreen].bounds.size.height - textViewOriginY - self.keyboardHeight + self.scrollView.contentOffset.y - 5);
}

- (NSMutableArray *)cleanUnusedNamesFromRecipients:(NSMutableArray *)arrayRecipient {
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for (id object in arrayRecipient) {
        NSString *addedEmail;
        if ([object isKindOfClass:[NSString class]]) {
            addedEmail = object;
        }
        else if ([object isKindOfClass:[ContactModel class]]) {
            ContactModel *contactModel = (ContactModel *)object;
            addedEmail = contactModel.email;
        }
        BOOL success = YES;
        for (NSString *email in array) {
            if ([addedEmail isEqualToString:email]) {
                success = NO;
                break;
            }
        }
        if (success && addedEmail) {
            [array addObject:addedEmail];
        }
    }
    
    return array;
}

- (NSString *)convertEntersToDiv:(NSString *)body {
    
    NSString *result;
    NSArray *array = [body componentsSeparatedByString:@"\n"];
    if ([array count] > 1) {
        for (NSInteger i = 0; i < [array count]; i++) {
            NSString *str = [array objectAtIndex:i];
            if (i == 0) {
                result = str;
            }
            else {
                result = [result stringByAppendingString:@"<div>"];
                result = [result stringByAppendingString:str];
                result = [result stringByAppendingString:@"</div>"];
            }
        }
    }
    else {
        result = body;
    }
    
    return result;
}

- (BOOL)validateEmails {
    
    BOOL valid = NO;
    self.arrayTo = [self cleanUnusedNamesFromRecipients:self.arrayTempTo];
    self.arrayCc = [self cleanUnusedNamesFromRecipients:self.arrayTempCc];
    self.arrayBcc = [self cleanUnusedNamesFromRecipients:self.arrayTempBcc];
    
    if ([self verifyEmailAddresses:self.arrayTo] && [self verifyEmailAddresses:self.arrayCc] && [self verifyEmailAddresses:self.arrayBcc]) {
        valid = YES;
    }
    
    return valid;
}

- (BOOL)verifyEmailAddresses:(NSArray *)arrayEmails {
    
    BOOL success = YES;
    if ([arrayEmails count] > 0) {
        NSString *emailReg = @"[A-Z0-9a-z._%+-]+@[A-Z0-9a-z.-]+\\.[A-Za-z]{2,4}";
        NSPredicate *emailTest =[NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailReg];
        for (NSString *email in arrayEmails) {
            success = [emailTest evaluateWithObject:email];
            if (!success) {
                break;
            }
        }
    }
    
    return success;
}


#pragma mark - UIWebViewDelegate Methods
- (void)webViewDidFinishLoad:(UIWebView *)webView {

    NSString *messageBody = [self convertEntersToDiv:self.textViewBody.text];
    NSString *clientKey = [self.serviceMessage getClientKey];
    NSString *function = [NSString stringWithFormat:@"GibberishAES.enc('%@', '%@')",messageBody, clientKey];
    NSString *encyptedBody = [self.webEncryptor stringByEvaluatingJavaScriptFromString:function];
        
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // Add this part to your code
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [formatter setTimeZone:timeZone];
    
    NSDate *now = [NSDate date];
    NSDate *dateToFire = [now dateByAddingTimeInterval:1*60];
    NSTimeInterval timeInterval = [dateToFire timeIntervalSince1970];
    NSLog(@"dateToFire ==== %f", timeInterval);
    timeInterval = [now timeIntervalSince1970];
    NSLog(@"now ==== %f", timeInterval);
    self.timer = timeInterval;
    
    if ([self validateEmails]) {
        [self.serviceMessage sendMessage:encyptedBody clientKey:clientKey messageSubject:self.textFieldSubject.text to:self.arrayTo cc:self.arrayCc bcc:self.arrayBcc timer:self.timer completionBlock:^(id data, ErrorDataModel *error) {
            
        }];
    }
    else {
        [self hideLoadingView];
        [self showErrorAlertWithTitle:@"Error!" message:@"Please enter a valid email address"];
    }
}


#pragma mark - TableView DataSource & Delegate Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.arrayContacts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ContactCell *contactCell = [tableView dequeueReusableCellWithIdentifier:@"ContactCellID"];
    [contactCell configureCellWithContactModel:[self.arrayContacts objectAtIndex:indexPath.row]];
    
    return contactCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.tableViewContacts) {
        ContactModel *contactModel = [self.arrayContacts objectAtIndex:indexPath.row];
        if (contactModel.email) {
            self.tableViewContacts.hidden = YES;
            self.selectedToken.selectEmailFromContacts = YES;
            if (contactModel.fullName.length > 0) {
                self.tempContactModel = contactModel;
                [self.selectedToken addTokenWithString:contactModel.fullName];
            }
            else {
                [self.selectedToken addTokenWithString:contactModel.email];
            }
        }
    }
}


#pragma mark - VENTokenFieldDelegate Methods
- (void)setSelectedField:(VENTokenField *)venTokenField {
    
    self.selectedToken = venTokenField;
}

- (void)tokenField:(VENTokenField *)tokenField didEnterText:(NSString *)text {
    
    [self addRecipientWithField:tokenField withName:text];
    if ([tokenField.toLabelText isEqualToString:@"To:"]) {
        [self.arrayTo addObject:text];
        [self.fieldTo reloadData];
    }
    else if ([tokenField.toLabelText isEqualToString:@"Cc:"]) {
        [self.arrayCc addObject:text];
        [self.fieldCc reloadData];
    }
    else if ([tokenField.toLabelText isEqualToString:@"Bcc:"]) {
        [self.arrayBcc addObject:text];
        [self.fieldBcc reloadData];
    }
    [self.buttonSend setImage:[UIImage imageNamed:@"buttonSendEnable"] forState:UIControlStateNormal];
    self.buttonSend.enabled = YES;
}

- (void)tokenField:(VENTokenField *)tokenField didDeleteTokenAtIndex:(NSUInteger)index {
    
    [self removRecipientWithField:tokenField index:index];
    if ([tokenField.toLabelText isEqualToString:@"To:"]) {
        [self.arrayTo removeObjectAtIndex:index];
        [self.fieldTo reloadData];
    }
    else if ([tokenField.toLabelText isEqualToString:@"Cc:"]) {
        [self.arrayCc removeObjectAtIndex:index];
        [self.fieldCc reloadData];
    }
    else if ([tokenField.toLabelText isEqualToString:@"Bcc:"]) {
        [self.arrayBcc removeObjectAtIndex:index];
        [self.fieldBcc reloadData];
    }
    
    if ([self.arrayTo count] == 0 && [self.arrayCc count] == 0 && [self.arrayBcc count] == 0) {
        [self.buttonSend setImage:[UIImage imageNamed:@"buttonSendDisable"] forState:UIControlStateNormal];
        self.buttonSend.enabled = NO;
    }
}


#pragma mark - VENTokenFieldDataSource Methods
- (void)tokenField:(VENTokenField *)tokenField didChangeText:(NSString *)text {
    
    self.arrayContacts = [self.serviceContact getContactsWithName:text];
    if ([self.arrayContacts count] > 0) {
        CGFloat originY;
        if (self.selectedToken == self.fieldTo) {
            originY = 120;
        }
        else if (self.selectedToken == self.fieldCc) {
            originY = 180;
        }
        else {
            originY = 240;
        }
        self.tableViewContacts.frame = CGRectMake(10, originY, [UIScreen mainScreen].bounds.size.width - 2*10, [UIScreen mainScreen].bounds.size.height - self.keyboardHeight - originY);
        self.tableViewContacts.hidden = NO;
        [self.tableViewContacts reloadData];
    }
    else {
        self.tableViewContacts.hidden = YES;
    }
}

- (NSString *)tokenField:(VENTokenField *)tokenField titleForTokenAtIndex:(NSUInteger)index {
    
    if ([tokenField.toLabelText isEqualToString:@"To:"]) {
        return self.arrayTo[index];
    }
    else if ([tokenField.toLabelText isEqualToString:@"Cc:"]) {
        return self.arrayCc[index];
    }
    else if ([tokenField.toLabelText isEqualToString:@"Bcc:"]) {
        return self.arrayBcc[index];
    }
    
    return nil;
}

- (NSUInteger)numberOfTokensInTokenField:(VENTokenField *)tokenField {
    
    if ([tokenField.toLabelText isEqualToString:@"To:"]) {
        return [self.arrayTo count];
    }
    else if ([tokenField.toLabelText isEqualToString:@"Cc:"]) {
        return [self.arrayCc count];
    }
    else if ([tokenField.toLabelText isEqualToString:@"Bcc:"]) {
        return [self.arrayBcc count];
    }
    
    return 0;
}

- (NSString *)tokenFieldCollapsedText:(VENTokenField *)tokenField {
    
    if ([tokenField.toLabelText isEqualToString:@"To:"]) {
        return [NSString stringWithFormat:@"%tu people", [self.arrayTo count]];
    }
    else if ([tokenField.toLabelText isEqualToString:@"Cc:"]) {
        return [NSString stringWithFormat:@"%tu people", [self.arrayCc count]];
    }
    else if ([tokenField.toLabelText isEqualToString:@"Bcc:"]) {
        return [NSString stringWithFormat:@"%tu people", [self.arrayBcc count]];
    }
    
    return nil;
}


#pragma mark - UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if(scrollView == self.scrollView) {
        CGFloat scrollViewOffsetY = 0;
        if (self.ccBccOpened) {
            scrollViewOffsetY = 180;
        }
        else {
            scrollViewOffsetY = 60;
        }
        self.scrollViewContentOffset = scrollView.contentOffset.y;
        
        if (scrollView.contentOffset.y > scrollViewOffsetY) {
            scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, scrollViewOffsetY);
        }
        if (scrollView.contentOffset.y < 0) {
            scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, 0);
        }
        [self defineTextViewFrame];
    }
}


#pragma mark - UITextFieldDelegate Methods
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    BOOL validEmails = [self validateEmails];
    if (!validEmails) {
        [self showErrorAlertWithTitle:@"Error!" message:@"Please enter a valid email address"];
    }
}

#pragma mark - UITextViewDelegate Methods
- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    [self defineTextViewFrame];
    
    BOOL validEmails = [self validateEmails];
    if (!validEmails) {
        [self showErrorAlertWithTitle:@"Error!" message:@"Please enter a valid email address"];
    }
}


#pragma mark - CustomAlertViewDelegate Methods
- (void)customIOS7dialogButtonTouchUpInside: (CustomAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    [alertView close];
}


@end
