//
//  SentMessageViewController.m
//  Dmail
//
//  Created by Karen Petrosyan on 6/25/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "SentMessageViewController.h"
#import "VENTokenField.h"

// service
#import "ServiceMessage.h"

// view model
#import "VMSentMessage.h"

//Categories
#import "UIColor+AppColors.h"
#import "UIImageView+WebCache.h"
#import <NSDate+DateTools.h>

//helpers
#import "CustomAlertView.h"

@interface SentMessageViewController () <CustomAlertViewDelegate, VENTokenFieldDelegate, VENTokenFieldDataSource>

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet VENTokenField *fieldTo;
@property (nonatomic, weak) IBOutlet VENTokenField *fieldCc;
@property (nonatomic, weak) IBOutlet VENTokenField *fieldBcc;
@property (nonatomic, weak) IBOutlet UILabel *labelSubject;
@property (nonatomic, weak) IBOutlet UITextView *textViewBody;
@property (nonatomic, weak) IBOutlet UIView *viewRecipients;
@property (nonatomic, weak) IBOutlet UIView *viewMessageSubject;
@property (nonatomic, weak) IBOutlet UIView *viewMessageBody;
@property (nonatomic, weak) IBOutlet UIView *viewSecure;
@property (nonatomic, weak) IBOutlet UILabel *labelTime;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *constraitHeight;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *constraitTopCc;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *constraitTopBcc;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *constraitHeightMessageBody;
@property (nonatomic, weak) IBOutlet BaseNavigationController *viewNavigation;
@property (nonatomic, weak) IBOutlet UIImageView *imageViewProfile;
@property (nonatomic, weak) IBOutlet UIWebView *webViewDecryption;

@property (nonatomic, strong) NSArray *arrayTo;
@property (nonatomic, strong) NSArray *arrayCc;
@property (nonatomic, strong) NSArray *arrayBcc;
@property (nonatomic, strong) NSString *encryptedMessage;
@property (nonatomic, strong) NSString *clientKey;
@property (nonatomic, strong) NSString *revokedEmail;
@property (nonatomic, strong) NSMutableArray *arrayAllParticipants;
@property (nonatomic, strong) ServiceMessage *serviceMessage;
@property (nonatomic, strong) VMSentMessage *modelMessage;

@end

@implementation SentMessageViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        _serviceMessage = [[ServiceMessage alloc] init];
    }
    return self;
}


#pragma mark Class methods
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    if (self.messageId) {
        self.modelMessage = [self.serviceMessage getSentMessageWithMessageId:self.messageId];
        [self loadData];
        [self fillFields];
        [self setupController];
        [self setupConstraits];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self registerNotifications];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.constraitHeightMessageBody.constant + self.viewRecipients.frame.size.height + self.viewMessageSubject.frame.size.height);
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Action Methods
- (IBAction)backClicked:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)destroyClicked:(id)sender {
    
    CustomAlertView *alertView = [[CustomAlertView alloc] initWithTitle:@"Destroy message"
                                                               withFont:@"ProximaNova-Semibold"
                                                               withSize:20
                                                            withMessage:@"Are you sure you want to destroy this message?"
                                                        withMessageFont:@"ProximaNova-Regular"
                                                    withMessageFontSize:15
                                                         withDeactivate:NO];
    NSDictionary *cancelButton = @{@"title" : @"Cancel",
                                        @"titleColor" : [UIColor whiteColor],
                                        @"backgroundColor" : [UIColor colorWithRed:120.0/255.0 green:132.0/255.0 blue:140.0/255.0 alpha:1],
                                        @"font" : @"ProximaNova-Regular",
                                        @"fontSize" : @"15"};
    NSDictionary *destroyButton = @{@"title" : @"Destroy",
                                        @"titleColor" : [UIColor whiteColor],
                                        @"backgroundColor" : [UIColor colorWithRed:215.0/255.0 green:34.0/255.0 blue:106.0/255.0 alpha:1],
                                        @"font" : @"ProximaNova-Regular",
                                        @"fontSize" : @"15"};
    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:cancelButton,destroyButton, nil]];
    [alertView setDelegate:self];
    [alertView setOnButtonTouchUpInside:^(CustomAlertView *alertView, int buttonIndex) {
        [alertView close];
    }];
    [alertView setUseMotionEffects:true];
    [alertView show];
}


#pragma mark - Private Methods
- (void)registerNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getDecryptedMessage:) name:NotificationGetDecryptedMessage object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(destroySuccess) name:NotificationDestroySuccess object:nil];
}

- (void)getDecryptedMessage:(NSNotification *)notification {
    
    self.textViewBody.text = [[notification userInfo] valueForKey:@"decryptedMessage"];
    [self hideLoadingView];
    [self.serviceMessage writeDecryptedBodyWithMessageId:self.messageId body:self.textViewBody.text];
}

- (void)loadData {
    
    self.arrayTo = [NSMutableArray array];
    self.arrayTo = self.modelMessage.arrayTo;
    if([self.arrayTo count] > 0) {
        self.fieldTo.forInboxOrSent = YES;
        self.fieldTo.delegate = self;
        self.fieldTo.dataSource = self;
        [self.fieldTo setColorScheme:[UIColor colorWithRed:61/255.0f green:149/255.0f blue:206/255.0f alpha:1.0f]];
        self.fieldTo.toLabelText = @"To:";
        for (NSString *string in self.arrayTo) {
            [self.fieldTo addTokenWithString:string];
        }
    }
    
    self.arrayCc = [NSMutableArray array];
    self.arrayCc = self.modelMessage.arrayCc;
    if([self.arrayCc count] > 0) {
        self.fieldCc.forInboxOrSent = YES;
        self.fieldCc.delegate = self;
        self.fieldCc.dataSource = self;
        [self.fieldCc setColorScheme:[UIColor colorWithRed:61/255.0f green:149/255.0f blue:206/255.0f alpha:1.0f]];
        self.fieldCc.toLabelText = @"Cc:";
        for (NSString *string in self.arrayCc) {
            [self.fieldCc addTokenWithString:string];
        }
    }
    
    self.arrayBcc = [NSMutableArray array];
    self.arrayBcc = self.modelMessage.arrayBcc;
    if([self.arrayBcc count] > 0) {
        self.fieldBcc.forInboxOrSent = YES;
        self.fieldBcc.delegate = self;
        self.fieldBcc.dataSource = self;
        [self.fieldBcc setColorScheme:[UIColor colorWithRed:61/255.0f green:149/255.0f blue:206/255.0f alpha:1.0f]];
        self.fieldBcc.toLabelText = @"Bcc:";
        for (NSString *string in self.arrayBcc) {
            [self.fieldBcc addTokenWithString:string];
        }
    }
}

- (void)fillFields {
    
    self.labelSubject.text = self.modelMessage.messageSubject;
    
    if (!self.modelMessage.body) {
        [self showLoadingView];
        [self.serviceMessage getMessageBodyWithIdentifier:self.messageId];
    }
    else {
        self.textViewBody.text = self.modelMessage.body;
    }
    CGFloat bodyHeight = [self textHeightWithText:self.textViewBody.text width:self.textViewBody.frame.size.width fontName:@"ProximaNova-Light" fontSize:14];
    if (bodyHeight > self.constraitHeightMessageBody.constant) {
        self.constraitHeightMessageBody.constant = bodyHeight + 70;
    }
    
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:self.modelMessage.internalDate/1000];
    NSInteger days = [[NSDate date] daysFrom:date];
    if (days > 30) {
        self.labelTime.text = [NSString stringWithFormat:@"%ldw",(long)days/7];
    }
    else {
        self.labelTime.text = [NSDate shortTimeAgoSinceDate:date];
    }
}

- (void)destroySuccess {
    
    [self hideLoadingView];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setupConstraits {
    
    if ([self.arrayCc count] > 0 && [self.arrayBcc count] == 0) {
        self.constraitHeight.constant = 120;
        self.constraitTopCc.constant = 60;
        self.fieldCc.alpha = 1;
    }
    else if ([self.arrayBcc count] > 0 && [self.arrayCc count] == 0) {
        self.constraitHeight.constant = 120;
        self.constraitTopBcc.constant = 60;
        self.fieldBcc.alpha = 1;
    }
    else if ([self.arrayCc count] > 0 && [self.arrayBcc count] > 0){
        self.constraitHeight.constant = 180;
        self.constraitTopCc.constant = 60;
        self.constraitTopBcc.constant = 120;
        self.fieldCc.alpha = 1;
        self.fieldBcc.alpha = 1;
    }
}

- (void)setupController {
    
    self.viewNavigation.layer.shadowColor = [[UIColor navigationShadowColor] CGColor];
    self.viewNavigation.layer.shadowOpacity = 0.6;
    self.viewNavigation.layer.shadowRadius = 0.5;
    self.viewNavigation.layer.shadowOffset = CGSizeMake(0, 1);
    
    self.viewMessageBody.layer.masksToBounds = YES;
    self.viewMessageBody.layer.cornerRadius = 5;
    self.viewMessageBody.layer.borderColor = [UIColor colorWithRed:197.0/255.0 green:215.0/255.0 blue:227.0/255.0 alpha:1].CGColor;
    self.viewMessageBody.layer.borderWidth = 1;
    
    self.viewSecure.layer.masksToBounds = YES;
    self.viewSecure.layer.cornerRadius = 5;
    self.viewSecure.layer.borderColor = [UIColor colorWithRed:197.0/255.0 green:215.0/255.0 blue:227.0/255.0 alpha:1].CGColor;
    self.viewSecure.layer.borderWidth = 1;
    
    self.imageViewProfile.layer.masksToBounds = YES;
    self.imageViewProfile.layer.cornerRadius = self.imageViewProfile.frame.size.width/2;
    [self.imageViewProfile sd_setImageWithURL:[NSURL URLWithString:self.modelMessage.imageUrl]];
}

- (CGFloat)textHeightWithText:(NSString *)text width:(CGFloat)width fontName:(NSString *)fontName fontSize:(CGFloat)fontSize {
    
    NSDictionary *headerAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:fontName size:fontSize], NSFontAttributeName, nil];
    CGRect textSize = [text boundingRectWithSize:CGSizeMake(width,CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:headerAttributes context:nil];
    return textSize.size.height;
}

#pragma mark - VENTokenFieldDelegate
- (void)tokenField:(VENTokenField *)tokenField didEnterText:(NSString *)text {
    
    if ([tokenField.toLabelText isEqualToString:@"To:"]) {
        [self.fieldTo reloadData];
    }
    else if ([tokenField.toLabelText isEqualToString:@"Cc:"]) {
        [self.fieldCc reloadData];
    }
    else if ([tokenField.toLabelText isEqualToString:@"Bcc:"]) {
        [self.fieldBcc reloadData];
    }
}


#pragma mark - VENTokenFieldDataSource
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

    if (scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.size.height) {
        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, scrollView.contentSize.height - scrollView.frame.size.height);
    }
}


#pragma mark - CustomAlertViewDelegate Methods
- (void)customIOS7dialogButtonTouchUpInside: (CustomAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    [self showLoadingView];
    [alertView close];
    if (buttonIndex == 1) {
        [self.serviceMessage destroyMessageWithMessageId:self.modelMessage.dmailId fromSentList:NO];
    }
}

@end
