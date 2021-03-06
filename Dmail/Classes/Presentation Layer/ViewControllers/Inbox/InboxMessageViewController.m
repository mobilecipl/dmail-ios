//
//  InboxMessageViewController.m
//  Dmail
//
//  Created by Karen Petrosyan on 6/14/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "InboxMessageViewController.h"
#import "ComposeViewController.h"

// service
#import "ServiceMessage.h"
#import "ServiceGmailMessage.h"

// view model
#import "VMInboxMessageItem.h"

// categories
#import "UIColor+AppColors.h"
#import "UIImageView+WebCache.h"

@interface InboxMessageViewController ()

@property (nonatomic, weak) IBOutlet UIView *viewNavigation;
@property (nonatomic, weak) IBOutlet UIView *viewMessageBody;
@property (nonatomic, weak) IBOutlet UIView *viewSecure;
@property (nonatomic, weak) IBOutlet UILabel *labelSenderName;
@property (nonatomic, weak) IBOutlet UILabel *labelMessageSubject;
@property (nonatomic, weak) IBOutlet UILabel *labelTime;
@property (nonatomic, weak) IBOutlet UITextView *textViewMessageBody;
@property (nonatomic, weak) IBOutlet UIImageView *imageViewProfile;

@property (nonatomic, strong) ServiceMessage *serviceMessage;
@property (nonatomic, strong) ServiceGmailMessage *serviceGmailMessage;

@end

@implementation InboxMessageViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        _serviceMessage = [[ServiceMessage alloc] init];
        _serviceGmailMessage = [[ServiceGmailMessage alloc] init];
    }
    return self;
}

#pragma mark - Class Methods
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setupController];
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self registerNotifications];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"fromInboxViewToCompose"]) {
        ComposeViewController *composeViewController = (ComposeViewController *)segue.destinationViewController;
        if ([composeViewController isKindOfClass:[ComposeViewController class]]) {
            VMInboxMessageItem *modelMessage = [self.serviceMessage getInboxMessageWithMessageId:self.messageId];
            composeViewController.replyedRecipientEmail = modelMessage.senderEmail;
            composeViewController.replyedRecipientName = modelMessage.senderName;
            composeViewController.replyedMessageSubject = modelMessage.messageSubject;
        }
    }
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}


#pragma mark - Action Methods
- (IBAction)backClicked:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Private Methods
- (void)registerNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getDecryptedMessage:) name:NotificationGetDecryptedMessage object:nil];
}

- (void)getDecryptedMessage:(NSNotification *)notification {
    
    NSString *decryptedBody = [[notification userInfo] valueForKey:@"decryptedMessage"];
    self.textViewMessageBody.text = [self cleanText:decryptedBody];
    [self hideLoadingView];
    [self.serviceMessage writeDecryptedBodyWithMessageId:self.messageId body:self.textViewMessageBody.text];
}

- (void)setupController {
    
    self.viewNavigation.layer.shadowColor = [[UIColor navigationShadowColor] CGColor];
    self.viewNavigation.layer.shadowOpacity = 0.6;
    self.viewNavigation.layer.shadowRadius = 0.5;
    self.viewNavigation.layer.shadowOffset = CGSizeMake(0, 1);
    
    self.viewMessageBody.layer.cornerRadius = 5;
    self.viewMessageBody.layer.borderColor = [[UIColor borderColor] CGColor];
    self.viewMessageBody.layer.borderWidth = 1;
    
    self.viewSecure.layer.masksToBounds = YES;
    self.viewSecure.layer.cornerRadius = 5;
    self.viewSecure.layer.borderColor = [UIColor colorWithRed:197.0/255.0 green:215.0/255.0 blue:227.0/255.0 alpha:1].CGColor;
    self.viewSecure.layer.borderWidth = 1;
    
    self.imageViewProfile.layer.masksToBounds = YES;
    self.imageViewProfile.layer.cornerRadius = self.imageViewProfile.frame.size.width/2;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 10;
    NSString *string = self.textViewMessageBody.text;
    NSDictionary *ats = @{
                          NSFontAttributeName : [UIFont fontWithName:@"ProximaNova-Light" size:14.0f],
                          NSParagraphStyleAttributeName : paragraphStyle,
                          };
    
    self.textViewMessageBody.attributedText = [[NSAttributedString alloc] initWithString:string attributes:ats];
}

- (void)loadData {
    
    if (self.messageId) {
        VMInboxMessageItem *modelMessage = [self.serviceMessage getInboxMessageWithMessageId:self.messageId];
        self.labelMessageSubject.text = modelMessage.messageSubject;
        self.labelSenderName.text = modelMessage.senderName;
        self.labelTime.text = modelMessage.messageDate;
        [self.imageViewProfile sd_setImageWithURL:[NSURL URLWithString:modelMessage.imageUrl]];
        if (!modelMessage.body) {
            [self showLoadingView];
            [self.serviceMessage getMessageBodyWithIdentifier:self.messageId];
        }
        else {
            self.textViewMessageBody.text = [self cleanText:modelMessage.body];
        }
        if (!modelMessage.read) {
            NSString *gmailID = [self.serviceMessage getGmailIDWithMessageId:modelMessage.messageId];
            [self.serviceGmailMessage deleteMessageLabels:@[@"UNREAD"] messageId:gmailID completionBlock:^(id data, ErrorDataModel *error) {
                if (data) {
                    [self.serviceMessage changeMessageStatusToReadWithMessageId:self.messageId];
                }
            }];
        }
    }
}

- (NSString *)cleanText:(NSString *)body {
    
    NSString *result;
    NSArray *arrayDiv = [body componentsSeparatedByString:@"<div>"];
    NSArray *array_Div = [body componentsSeparatedByString:@"</div>"];
    if ([arrayDiv count] == [array_Div count]) {
        for (NSInteger i = 0; i < [arrayDiv count]; i++) {
            NSString *str = [arrayDiv objectAtIndex:i];
            if (i == 0) {
                result = str;
            }
            else {
                result = [result stringByAppendingString:@"\n"];
                result = [result stringByAppendingString:str];
            }
        }
        result = [result stringByReplacingOccurrencesOfString:@"</div>" withString:@""];
    }
    else {
        result = body;
    }
    
    result = [result stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
    
    return result;
}

- (CGFloat)textWidthWithText:(NSString *)text height:(CGFloat)height fontName:(NSString *)fontName fontSize:(CGFloat)fontSize {
    
    NSDictionary *headerAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:fontName size:fontSize], NSFontAttributeName, nil];
    CGRect textSize = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX,height) options:NSStringDrawingUsesLineFragmentOrigin attributes:headerAttributes context:nil];
    return textSize.size.width;
}

@end
