//
//  InboxMessageViewController.m
//  Dmail
//
//  Created by Karen Petrosyan on 6/14/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "InboxMessageViewController.h"

// service
#import "ServiceMessage.h"

// view model
#import "VMInboxMessageItem.h"

#import "UIColor+AppColors.h"
#import "UIImageView+WebCache.h"

#import "CommonMethods.h"

@interface InboxMessageViewController ()

@property (nonatomic, weak) IBOutlet UIView *viewNavigation;
@property (nonatomic, weak) IBOutlet UIView *viewContainer;
@property (nonatomic, weak) IBOutlet UILabel *labelSenderName;
@property (nonatomic, weak) IBOutlet UILabel *labelMessageSubject;
@property (nonatomic, weak) IBOutlet UILabel *labelTime;
@property (nonatomic, weak) IBOutlet UITextView *textViewMessageBody;
@property (nonatomic, weak) IBOutlet UIImageView *imageViewProfile;

@property (nonatomic, strong) ServiceMessage *serviceMessage;
@end

@implementation InboxMessageViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        _serviceMessage = [[ServiceMessage alloc] init];
    }
    return self;
}

#pragma mark - Class Methods
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setupController];
    [self loadData];
}


#pragma mark - Action Methods
- (IBAction)backClicked:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Private Methods
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
        CGFloat profileNameWidth = [[CommonMethods sharedInstance] textWidthWithText:modelMessage.senderName height:self.labelSenderName.frame.size.height fontName:@"ProximaNova-Regular" fontSize:12];
        CGFloat profileImageAndNameWidth = self.imageViewProfile.frame.size.width + profileNameWidth + 5;
        CGFloat imageOryginX = ([UIScreen mainScreen].bounds.size.width - profileImageAndNameWidth)/2;
        self.imageViewProfile.frame = CGRectMake(imageOryginX, self.imageViewProfile.frame.origin.y, self.imageViewProfile.frame.size.width, self.imageViewProfile.frame.size.height);
        self.labelSenderName.frame = CGRectMake(self.imageViewProfile.frame.origin.x + self.imageViewProfile.frame.size.width + 5, self.labelSenderName.frame.origin.y, profileNameWidth, self.labelSenderName.frame.size.height);
        if (!modelMessage.body) {
            [self showLoadingView];
            @weakify(self);
            [self.serviceMessage getMessageBodyWithIdentifier:self.messageId completionBlock:^(NSString *body, ErrorDataModel *error) {
                @strongify(self);
                self.textViewMessageBody.text = body;
                [self hideLoadingView];
            }];
        }
        else {
            self.textViewMessageBody.text = modelMessage.body;
        }
        [self.serviceMessage changeMessageStatusToReadWithMessageId:self.messageId];
    }
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

@end
