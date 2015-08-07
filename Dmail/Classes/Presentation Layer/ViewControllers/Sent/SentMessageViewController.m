//
//  SentMessageViewController.m
//  Dmail
//
//  Created by Karen Petrosyan on 6/25/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "SentMessageViewController.h"

// service
#import "ServiceMessage.h"

// view model
#import "VMSentMessage.h"

// model
#import "ParticipantsCell.h"
#import "MessageComposeCell.h"

//Categories
#import "UIColor+AppColors.h"
#import "UIImageView+WebCache.h"

//helpers
#import "CustomAlertView.h"

typedef NS_ENUM(NSInteger, AlertTags) {
    Revoke = 1,
    Destroy
};

@interface SentMessageViewController () <ParticipantsCellDelegate, MessageComposeCellDelegate, CustomAlertViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIView *viewSecure;
@property (nonatomic, weak) IBOutlet BaseNavigationController *viewNavigation;
@property (nonatomic, weak) IBOutlet UIImageView *imageViewProfile;
@property (nonatomic, weak) IBOutlet UIWebView *webViewDecryption;

@property (nonatomic, strong) NSArray *arrayTo;
@property (nonatomic, strong) NSArray *arrayCc;
@property (nonatomic, strong) NSArray *arrayBcc;
@property (nonatomic, strong) NSString *encryptedMessage;
@property (nonatomic, strong) NSString *clientKey;
@property (nonatomic, assign) CGFloat toCellHeight;
@property (nonatomic, assign) CGFloat ccCellHeight;
@property (nonatomic, assign) CGFloat bccCellHeight;
@property (nonatomic, assign) CGFloat messageContentCellHeight;

@property (nonatomic, strong) NSString *revokedEmail;
@property (nonatomic, strong) NSMutableArray *arrayAllParticipants;
@property (nonatomic, strong) NSString *body;
@property (nonatomic, assign) NSInteger tableRowNumbers;

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
    
    self.tableRowNumbers = 2;
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
    alertView.tag = Destroy;
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
    
    self.body = [[notification userInfo] valueForKey:@"decryptedMessage"];
    NSInteger bodyRow = [self getBodyRow];
    NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:bodyRow inSection:0];
    NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
    [self.tableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
    [self hideLoadingView];
    [self.serviceMessage writeDecryptedBodyWithMessageId:self.messageId body:self.body];
}

- (void)loadData {
    
    if (self.messageId) {
        self.modelMessage = [self.serviceMessage getSentMessageWithMessageId:self.messageId];
        self.arrayTo = self.modelMessage.arrayTo;
        self.arrayCc = self.modelMessage.arrayCc;
        self.arrayBcc = self.modelMessage.arrayBcc;
        [self createTableItems];
        if (!self.modelMessage.body) {
            [self showLoadingView];
            [self.serviceMessage getMessageBodyWithIdentifier:self.messageId];
        }
        else {
            self.body = self.modelMessage.body;
        }
    }
    [self.tableView reloadData];
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
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.viewSecure.bounds byRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerBottomRight) cornerRadii:CGSizeMake(5.0, 5.0)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.view.bounds;
    maskLayer.path  = maskPath.CGPath;
    self.viewSecure.layer.mask = maskLayer;
    
    CAShapeLayer *borderLayer = [[CAShapeLayer alloc] init];
    borderLayer.frame = self.view.bounds;
    borderLayer.path  = maskPath.CGPath;
    borderLayer.lineWidth   = 2.0f;
    borderLayer.strokeColor = [UIColor colorWithRed:197.0/255.0 green:215.0/255.0 blue:227.0/255.0 alpha:1].CGColor;
    borderLayer.fillColor = [UIColor clearColor].CGColor;
    [self.viewSecure.layer addSublayer:borderLayer];
    
    self.imageViewProfile.layer.masksToBounds = YES;
    self.imageViewProfile.layer.cornerRadius = self.imageViewProfile.frame.size.width/2;
    [self.imageViewProfile sd_setImageWithURL:[NSURL URLWithString:self.modelMessage.imageUrl]];
}

- (void)fillFields {
    
    
}

- (void)createTableItems {
    
    self.ccCellHeight = 0;
    self.bccCellHeight = 0;
    self.messageContentCellHeight = 450;
    self.toCellHeight = 57;
    if ([self.arrayCc count] > 0) {
        self.ccCellHeight = 57;
        self.tableRowNumbers++;
    }
    if ([self.arrayBcc count] > 0) {
        self.bccCellHeight = 57;
        self.tableRowNumbers++;
    }
}

- (NSInteger)getBodyRow {
    
    NSInteger row = 1;
    if ([self.arrayCc count] > 0) {
        row = 2;
    }
    if ([self.arrayBcc count] > 0) {
        if ([self.arrayCc count] > 0) {
            row = 3;
        }
    }
    
    return row;
}

- (NSMutableArray *)getAllParticipants {
    
    self.arrayAllParticipants = [[NSMutableArray alloc] init];
    for (NSString *to in self.modelMessage.arrayTo) {
        [self.arrayAllParticipants addObject:to];
    }
    for (NSString *cc in self.modelMessage.arrayCc) {
        [self.arrayAllParticipants addObject:cc];
    }
    for (NSString *bcc in self.modelMessage.arrayBcc) {
        [self.arrayAllParticipants addObject:bcc];
    }
    
    return self.arrayAllParticipants;
}


#pragma mark - TableView DataSource & Delegate Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat rowHeight = 0;
    if (self.tableRowNumbers == 2) {
        if (indexPath.row == 0) {
            rowHeight = self.toCellHeight;
        }
        else {
            rowHeight = [UIScreen mainScreen].bounds.size.height - (70 + self.toCellHeight + self.ccCellHeight + self.bccCellHeight + self.viewSecure.frame.size.height);
        }
    }
    else if (self.tableRowNumbers == 3) {
        switch (indexPath.row) {
            case 0:
                rowHeight = self.toCellHeight;
                break;
            case 1:
                rowHeight = [self.arrayCc count]>0?self.ccCellHeight:self.bccCellHeight;
                break;
            case 2:
                rowHeight = [UIScreen mainScreen].bounds.size.height - (70 + self.toCellHeight +self.ccCellHeight + self.bccCellHeight + self.viewSecure.frame.size.height);
                break;
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
                rowHeight = [UIScreen mainScreen].bounds.size.height - (70 + self.toCellHeight +self.ccCellHeight + self.bccCellHeight + self.viewSecure.frame.size.height);
                break;
            default:
                break;
        }
    }
    return rowHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.tableRowNumbers;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.tableRowNumbers == 2) {
        switch (indexPath.row) {
            case 0: {
                ParticipantsCell *participantsCell = [tableView dequeueReusableCellWithIdentifier:@"participantsCellId"];
                participantsCell.delegate = self;
                [participantsCell configureCellForSentWithRow:indexPath.row withParticipants:self.arrayTo participantsType:@"To" messageId:self.messageId];
                participantsCell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                return participantsCell;
            }
                break;
            case 1: {
                MessageComposeCell *messageComposeCell = [tableView dequeueReusableCellWithIdentifier:@"messageComposeCellId"];
                messageComposeCell.delegate = self;
                [messageComposeCell configureCellWithBody:self.body subject:self.modelMessage.messageSubject internalDate:self.modelMessage.internalDate];
                messageComposeCell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                return messageComposeCell;
            }
                break;
            default:
                break;
        }
    }
    else if (self.tableRowNumbers == 3) {
        switch (indexPath.row) {
            case 0: {
                ParticipantsCell *participantsCell = [tableView dequeueReusableCellWithIdentifier:@"participantsCellId"];
                participantsCell.translatesAutoresizingMaskIntoConstraints = YES;
                participantsCell.delegate = self;
                [participantsCell configureCellForSentWithRow:indexPath.row withParticipants:self.arrayTo participantsType:@"To" messageId:self.messageId];
                participantsCell.selectionStyle = UITableViewCellSelectionStyleNone;
                return participantsCell;
            }
            case 1: {
                NSArray *arrayParticipants;
                NSString *participantType;
                if ([self.arrayCc count] > 0) {
                    arrayParticipants = [NSArray arrayWithArray:self.arrayCc];
                    participantType = @"Cc";
                }
                else {
                    arrayParticipants = [NSArray arrayWithArray:self.arrayBcc];
                    participantType = @"Bcc";
                }
                ParticipantsCell *participantsCell = [tableView dequeueReusableCellWithIdentifier:@"participantsCellId"];
                participantsCell.delegate = self;
                [participantsCell configureCellForSentWithRow:indexPath.row withParticipants:arrayParticipants participantsType:participantType messageId:self.messageId];
                participantsCell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                return participantsCell;
            }
                break;
            case 2: {
                MessageComposeCell *messageComposeCell = [tableView dequeueReusableCellWithIdentifier:@"messageComposeCellId"];
                messageComposeCell.delegate = self;
                [messageComposeCell configureCellWithBody:self.body subject:self.modelMessage.messageSubject internalDate:self.modelMessage.internalDate];
                messageComposeCell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                return messageComposeCell;
            }
                break;
        }
    }
    else {
        switch (indexPath.row) {
            case 0: {
                ParticipantsCell *participantsCell = [tableView dequeueReusableCellWithIdentifier:@"participantsCellId"];
                participantsCell.translatesAutoresizingMaskIntoConstraints = YES;
                participantsCell.delegate = self;
                [participantsCell configureCellForSentWithRow:indexPath.row withParticipants:self.arrayTo participantsType:@"To" messageId:self.messageId];
                participantsCell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                return participantsCell;
            }
                break;
            case 1: {
                ParticipantsCell *participantsCell = [tableView dequeueReusableCellWithIdentifier:@"participantsCellId"];
                participantsCell.delegate = self;
                [participantsCell configureCellForSentWithRow:indexPath.row withParticipants:self.arrayCc participantsType:@"Cc" messageId:self.messageId];
                participantsCell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                return participantsCell;
            }
                break;
            case 2: {
                ParticipantsCell *participantsCell = [tableView dequeueReusableCellWithIdentifier:@"participantsCellId"];
                participantsCell.delegate = self;
                [participantsCell configureCellForSentWithRow:indexPath.row withParticipants:self.arrayBcc participantsType:@"Bcc" messageId:self.messageId];
                participantsCell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                return participantsCell;
            }
                break;
            case 3: {
                MessageComposeCell *messageComposeCell = [tableView dequeueReusableCellWithIdentifier:@"messageComposeCellId"];
                messageComposeCell.delegate = self;
                [messageComposeCell configureCellWithBody:self.body subject:self.modelMessage.messageSubject internalDate:self.modelMessage.internalDate];
                messageComposeCell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                return messageComposeCell;
            }
                break;
            default:
                break;
        }
    }
    
    return nil;
}


#pragma mark - ParticipantCellDelegate Methods
- (void)revokeParticipantWithEmail:(NSString *)email name:(NSString *)name {
    
    self.revokedEmail = email;
    
    NSString *alertMessage = [NSString stringWithFormat:@"Are you sure you want to revoke acces to %@",name];
    CustomAlertView *alertView = [[CustomAlertView alloc] initWithTitle:@"Revoke access?"
                                                               withFont:@"ProximaNova-Semibold"
                                                               withSize:20
                                                            withMessage:alertMessage
                                                        withMessageFont:@"ProximaNova-Regular"
                                                    withMessageFontSize:15
                                                         withDeactivate:NO];
    NSDictionary *cancelButton = @{@"title" : @"Cancel",
                                   @"titleColor" : [UIColor whiteColor],
                                   @"backgroundColor" : [UIColor colorWithRed:120.0/255.0 green:132.0/255.0 blue:140.0/255.0 alpha:1],
                                   @"font" : @"ProximaNova-Regular",
                                   @"fontSize" : @"15"};
    NSDictionary *revokeButton = @{@"title" : @"Revoke",
                                    @"titleColor" : [UIColor whiteColor],
                                    @"backgroundColor" : [UIColor colorWithRed:215.0/255.0 green:34.0/255.0 blue:106.0/255.0 alpha:1],
                                    @"font" : @"ProximaNova-Regular",
                                    @"fontSize" : @"15"};
    alertView.tag = Revoke;
    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:cancelButton,revokeButton, nil]];
    [alertView setDelegate:self];
    [alertView setOnButtonTouchUpInside:^(CustomAlertView *alertView, int buttonIndex) {
        [alertView close];
    }];
    [alertView setUseMotionEffects:true];
    [alertView show];
}


#pragma mark - CustomAlertViewDelegate Methods
- (void)customIOS7dialogButtonTouchUpInside: (CustomAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    [alertView close];
    if (alertView.tag == Revoke) {
        if (buttonIndex == 1) {
            [self.serviceMessage revokeMessageWithMessageId:self.modelMessage.dmailId participant:self.revokedEmail];
        }
    }
    else {
        if (buttonIndex == 1) {
            [self.serviceMessage destroyMessageWithMessageId:self.modelMessage.dmailId participant:nil];
        }
    }
}

@end
