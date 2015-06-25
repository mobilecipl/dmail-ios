//
//  SentViewController.m
//  Dmail
//
//  Created by Karen Petrosyan on 6/25/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "SentViewController.h"
#import "UIColor+AppColors.h"
#import "DmailMessage.h"
#import "CoreDataManager.h"
#import "MessageService.h"
#import "CommonMethods.h"


@interface SentViewController ()

@property (nonatomic, weak) IBOutlet UIView *viewNavigation;
@property (nonatomic, weak) IBOutlet UIView *viewContainer;
@property (nonatomic, weak) IBOutlet UIView *viewParticipants;
@property (nonatomic, weak) IBOutlet UIImageView *imageViewProfile;
@property (nonatomic, weak) IBOutlet UILabel *labelMessageSubject;
@property (nonatomic, weak) IBOutlet UILabel *labelTime;
@property (nonatomic, weak) IBOutlet UILabel *labelTo;
@property (nonatomic, weak) IBOutlet UITextView *textViewMessageBody;

@property (nonatomic, strong) NSString *senderName;

@end

@implementation SentViewController

#pragma mark Class methods
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self setupController];
    [self fillFields];
    [self createSenderNames];
}


#pragma mark - Action Methods
- (IBAction)backClicked:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)revokeClicked {
    
    NSString *alertMessage = [NSString stringWithFormat:@"Are you sure you want to revoke acces to %@",self.senderName];
    UIAlertView *alert= [[UIAlertView alloc] initWithTitle:@"Revoke access"
                                                   message:alertMessage
                                                  delegate:self
                                         cancelButtonTitle:@"Cancel"
                                         otherButtonTitles:@"Revoke", nil];
    [alert show];
}

#pragma mark - Private Methods
- (void)createSenderNames {
    
    CGFloat senderNameWidth = [[CommonMethods sharedInstance] textWidthWithText:self.senderName height:15.0 fontName:@"ProximaNova-Light" fontSize:12.5];
    UILabel *labelSenderName = [[UILabel alloc] initWithFrame:CGRectMake(self.labelTo.frame.origin.x + self.labelTo.frame.size.width + 5, 0, senderNameWidth + 4 + 18, 22)];
    labelSenderName.backgroundColor = [UIColor participantsColor];
    labelSenderName.textColor = [UIColor whiteColor];
    labelSenderName.font = [UIFont fontWithName:@"ProximaNova-Light" size:12.5];
    labelSenderName.center = CGPointMake(labelSenderName.center.x, self.labelTo.center.y);
    labelSenderName.text = self.messageItem.senderName;
    [self.viewParticipants addSubview:labelSenderName];
    
    labelSenderName.layer.cornerRadius = 5.0;
    labelSenderName.layer.borderColor = [[UIColor participantsColor] CGColor];
    labelSenderName.layer.borderWidth = 1;
    
    UIButton *buttonRevoke = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonRevoke setImage:[UIImage imageNamed:@"buttonRevoke.png"] forState:UIControlStateNormal];
    buttonRevoke.frame = CGRectMake(labelSenderName.frame.origin.x + labelSenderName.frame.size.width - 20, 0, 25, 25);
    buttonRevoke.center = CGPointMake(buttonRevoke.center.x, labelSenderName.center.y);
    [buttonRevoke addTarget:self action:@selector(revokeClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.viewParticipants addSubview:buttonRevoke];
}

- (void)setupController {
    
    self.viewNavigation.layer.shadowColor = [[UIColor navigationShadowColor] CGColor];
    self.viewNavigation.layer.shadowOpacity = 0.6;
    self.viewNavigation.layer.shadowRadius = 0.5;
    self.viewNavigation.layer.shadowOffset = CGSizeMake(0, 1);
    
    self.imageViewProfile.layer.cornerRadius = self.imageViewProfile.frame.size.width/2;
    self.imageViewProfile.image = [UIImage imageNamed:@"imageProfile1"];
    
    self.viewContainer.layer.cornerRadius = 5;
    self.viewContainer.layer.borderColor = [[UIColor borderColor] CGColor];
    self.viewContainer.layer.borderWidth = 1;
    
    self.senderName = self.messageItem.senderName;
    if (self.senderName.length == 0) {
        self.senderName = self.messageItem.senderEmail;
    }
}

- (void)fillFields {
    
    self.labelMessageSubject.text = self.messageItem.subject;
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


#pragma mark - UIAlertViewdelegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 0:
            
            break;
        case 1: {
            [[MessageService sharedInstance] revokeUserWithEmail:self.messageItem.senderEmail dmailId:self.messageItem.dmailId completionBlock:^(BOOL success) {
                if (success) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dmail"
                                                                    message:@"Participant revoked"
                                                                   delegate:self
                                                          cancelButtonTitle:@"Ok"
                                                          otherButtonTitles:nil, nil];
                    [alert show];
                }
            }];
        }
            break;
        default:
            break;
    }
}



@end
