//
//  InboxMessageViewController.m
//  Dmail
//
//  Created by Karen Petrosyan on 6/14/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "InboxMessageViewController.h"

//#import "CoreDataManager.h"
//#import "DmailMessage.h"
//#import <NSDate+DateTools.h>
//#import "MessageItem.h"

// service
#import "ServiceMessage.h"

// view model
#import "VMInboxMessageItem.h"


#import "UIColor+AppColors.h"

@interface InboxMessageViewController ()

@property (nonatomic, weak) IBOutlet UIView *viewNavigation;
@property (nonatomic, weak) IBOutlet UIView *viewContainer;
@property (nonatomic, weak) IBOutlet UILabel *labelSenderName;
@property (nonatomic, weak) IBOutlet UILabel *labelMessageSubject;
@property (nonatomic, weak) IBOutlet UILabel *labelTime;
@property (nonatomic, weak) IBOutlet UITextView *textViewMessageBody;

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
    
    if (self.messageIdentifier) {
        
        VMInboxMessageItem *modelMessage = [self.serviceMessage getInboxMessageWithIdentifier:self.messageIdentifier];
        
        self.labelMessageSubject.text = modelMessage.messageSubject;
        self.labelSenderName.text = modelMessage.senderName;
        self.labelTime.text = modelMessage.messageDate;
        
        [self showLoadingView];
        
        @weakify(self);
        [self.serviceMessage getMessageBodyWithIdentifier:self.messageIdentifier
                                          completionBlock:^(NSString *body, ErrorDataModel *error) {
                                              
                                              @strongify(self);
                                              self.textViewMessageBody.text = body;
                                              [self hideLoadingView];
                                          }];
    }
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

@end
