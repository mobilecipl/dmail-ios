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

#import "UIColor+AppColors.h"
#import "UIImageView+WebCache.h"

@interface InboxMessageViewController ()

@property (nonatomic, weak) IBOutlet UIView *viewNavigation;
@property (nonatomic, weak) IBOutlet UIView *viewContainer;
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

- (IBAction)buttonReplayClicked:(id)sender {
    
    
}

#pragma mark - Private Methods
- (void)registerNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getDecryptedMessage:) name:NotificationGetDecryptedMessage object:nil];
}

- (void)getDecryptedMessage:(NSNotification *)notification {
    
    NSLog(@"decryptedMessage ======= %@", [[notification userInfo] valueForKey:@"decryptedMessage"]);
    self.textViewMessageBody.text = [[notification userInfo] valueForKey:@"decryptedMessage"];
    [self hideLoadingView];
    [self.serviceMessage writeDecryptedBodyWithMessageId:self.messageId body:self.textViewMessageBody.text];
}

- (void)setupController {
    
    self.viewNavigation.layer.shadowColor = [[UIColor navigationShadowColor] CGColor];
    self.viewNavigation.layer.shadowOpacity = 0.6;
    self.viewNavigation.layer.shadowRadius = 0.5;
    self.viewNavigation.layer.shadowOffset = CGSizeMake(0, 1);
    
    self.viewContainer.layer.cornerRadius = 5;
    self.viewContainer.layer.borderColor = [[UIColor borderColor] CGColor];
    self.viewContainer.layer.borderWidth = 1;
    
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
        CGFloat profileNameWidth = [self textWidthWithText:modelMessage.senderName height:self.labelSenderName.frame.size.height fontName:@"ProximaNova-Regular" fontSize:12];
        CGFloat profileImageAndNameWidth = self.imageViewProfile.frame.size.width + profileNameWidth + 5;
        CGFloat imageOryginX = ([UIScreen mainScreen].bounds.size.width - profileImageAndNameWidth)/2;
        self.imageViewProfile.frame = CGRectMake(imageOryginX, self.imageViewProfile.frame.origin.y, self.imageViewProfile.frame.size.width, self.imageViewProfile.frame.size.height);
        self.labelSenderName.frame = CGRectMake(self.imageViewProfile.frame.origin.x + self.imageViewProfile.frame.size.width + 5, self.labelSenderName.frame.origin.y, profileNameWidth, self.labelSenderName.frame.size.height);
        if (!modelMessage.body) {
            [self showLoadingView];
            [self.serviceMessage getMessageBodyWithIdentifier:self.messageId];
        }
        else {
            self.textViewMessageBody.text = modelMessage.body;
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

- (CGFloat)textWidthWithText:(NSString *)text height:(CGFloat)height fontName:(NSString *)fontName fontSize:(CGFloat)fontSize {
    
    NSDictionary *headerAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:fontName size:fontSize], NSFontAttributeName, nil];
    CGRect textSize = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX,height)
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:headerAttributes
                                         context:nil];
    return textSize.size.width;
}

@end
