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


@property (nonatomic, weak) IBOutlet VENTokenField *fieldTo;
@property (nonatomic, weak) IBOutlet VENTokenField *fieldCc;
@property (nonatomic, weak) IBOutlet VENTokenField *fieldBcc;
@property (nonatomic, weak) IBOutlet UITextField *textFieldSubject;
@property (nonatomic, weak) IBOutlet UITextView *textViewBody;
@property (nonatomic, weak) IBOutlet UIView *viewMessageBody;
@property (nonatomic, weak) IBOutlet UILabel *labelTime;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *constraitHeight;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *constraitBetweenCcAndSubject;

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
    
    [self loadData];
    [self setupController];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self registerNotifications];
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(revokeSuccess) name:NotificationRevokeSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(revokeFailed) name:NotificationRevokeFailed object:nil];
}

- (void)getDecryptedMessage:(NSNotification *)notification {
    
    self.textViewBody.text = [[notification userInfo] valueForKey:@"decryptedMessage"];
    [self hideLoadingView];
    [self.serviceMessage writeDecryptedBodyWithMessageId:self.messageId body:self.textViewBody.text];
}

- (void)loadData {
    
    if (self.messageId) {
        self.modelMessage = [self.serviceMessage getSentMessageWithMessageId:self.messageId];
        
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
        
        if ([self.arrayCc count] > 0 && [self.arrayBcc count] == 0) {
            self.constraitHeight.constant = 161;
            self.constraitBetweenCcAndSubject.constant = 41;
            self.fieldCc.alpha = 1;
        }
        else if ([self.arrayBcc count] > 0 && [self.arrayCc count] == 0) {
            self.constraitHeight.constant = 161;
            self.fieldBcc.alpha = 1;
        }
        else if ([self.arrayCc count] > 0 && [self.arrayBcc count] > 0){
            self.constraitHeight.constant = 221;
            self.fieldCc.alpha = 1;
            self.fieldBcc.alpha = 1;
        }
        
        self.textFieldSubject.text = self.modelMessage.messageSubject;
        
        if (!self.modelMessage.body) {
            [self showLoadingView];
            [self.serviceMessage getMessageBodyWithIdentifier:self.messageId];
        }
        else {
            self.textViewBody.text = self.modelMessage.body;
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
}

- (void)revokeSuccess {
    
    [self hideLoadingView];
    [self showMessageDestroyedSuccess:YES];
}

- (void)revokeFailed {
    
    [self hideLoadingView];
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
    
    self.imageViewProfile.layer.masksToBounds = YES;
    self.imageViewProfile.layer.cornerRadius = self.imageViewProfile.frame.size.width/2;
    [self.imageViewProfile sd_setImageWithURL:[NSURL URLWithString:self.modelMessage.imageUrl]];
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


#pragma mark - CustomAlertViewDelegate Methods
- (void)customIOS7dialogButtonTouchUpInside: (CustomAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    [alertView close];
    if (buttonIndex == 1) {
        [self.serviceMessage destroyMessageWithMessageId:self.modelMessage.dmailId];
    }
}

@end
