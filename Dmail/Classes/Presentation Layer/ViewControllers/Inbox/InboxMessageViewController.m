//
//  InboxMessageViewController.m
//  Dmail
//
//  Created by Karen Petrosyan on 6/14/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "InboxMessageViewController.h"
#import "UIColor+AppColors.h"
#import "MessageService.h"
#import "CoreDataManager.h"
#import "DmailMessage.h"


@interface InboxMessageViewController ()

@property (nonatomic, weak) IBOutlet UIView *viewNavigation;
@property (nonatomic, weak) IBOutlet UIView *viewContainer;
@property (nonatomic, weak) IBOutlet UILabel *labelSenderName;
@property (nonatomic, weak) IBOutlet UILabel *labelMessageSubject;
@property (nonatomic, weak) IBOutlet UILabel *labelTime;
@property (nonatomic, weak) IBOutlet UITextView *textViewMessageBody;

@end

@implementation InboxMessageViewController


#pragma mark - Class Methods
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setupController];
    [self fillFields];
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
}

- (void)fillFields {
    
    self.labelMessageSubject.text = self.messageItem.subject;
    self.labelSenderName.text = self.messageItem.fromEmail;
    NSString *dmailMessageId = self.messageItem.dmailId;
    DmailMessage *dmailMessage = [[CoreDataManager sharedCoreDataManager] getDmailMessageWithMessageId:dmailMessageId];
    if (dmailMessage.body) {
        self.textViewMessageBody.text = dmailMessage.body;
    }
    else {
        [self showLoadingView];
        [[MessageService sharedInstance] getDecodedMessageWithGmailUniqueId:dmailMessageId withCompletionBlock:^(NSString *message, NSInteger statusCode) {
            [self hideLoadingView];
            self.textViewMessageBody.text = message;
            [[CoreDataManager sharedCoreDataManager] changeMessageTypeWithMessageId:self.messageItem.dmailId messageType:Read];
        }];
    }
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

@end
