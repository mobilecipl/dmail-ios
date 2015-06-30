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
#import "GmailMessage.h"
#import "CoreDataManager.h"
#import "MessageService.h"
#import "CommonMethods.h"
#import "Profile.h"
#import "ParticipantsCell.h"
#import "MessageComposeCell.h"

typedef NS_ENUM(NSInteger, AlertTags) {
    Revoke = 1,
    Destroy
};


@interface SentViewController () <ParticipantsCellDelegate, MessageComposeCellDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIView *viewSecure;

@property (nonatomic, strong) NSMutableArray *arrayTableItems;
@property (nonatomic, strong) NSArray *arrayTo;
@property (nonatomic, strong) NSArray *arrayCc;
@property (nonatomic, strong) NSArray *arrayBcc;
@property (nonatomic, assign) CGFloat toCellHeight;
@property (nonatomic, assign) CGFloat ccCellHeight;
@property (nonatomic, assign) CGFloat bccCellHeight;
@property (nonatomic, assign) CGFloat messageContentCellHeight;

@property (nonatomic, weak) IBOutlet UIView *viewNavigation;
@property (nonatomic, weak) IBOutlet UIImageView *imageViewProfile;

@property (nonatomic, strong) NSString *revokedEmail;
@property (nonatomic, strong) NSMutableArray *arrayAllParticipants;
@property (nonatomic, strong) NSString *body;
@property (nonatomic, assign) NSInteger participantIndex;


@end

@implementation SentViewController

#pragma mark Class methods
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.arrayTableItems = [[NSMutableArray alloc] init];
    [self setupController];
    [self fillFields];
}


#pragma mark - Action Methods
- (IBAction)backClicked:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)destroyClicked:(id)sender {
    
    UIAlertView *alert= [[UIAlertView alloc] initWithTitle:@"Destroy message"
                                                   message:@"Are you sure you want to destroy this message?"
                                                  delegate:self
                                         cancelButtonTitle:@"Cancel"
                                         otherButtonTitles:@"Destroy", nil];
    alert.tag = Destroy;
    [alert show];
}

- (void)destroyAllParticipants {
    
    [[MessageService sharedInstance] revokeUserWithEmail:[self.arrayAllParticipants objectAtIndex:self.participantIndex] dmailId:self.messageItem.dmailId completionBlock:^(BOOL success) {
        if (success) {
            if (self.participantIndex == [self.arrayAllParticipants count] - 1) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dmail"
                                                                message:@"Participants are successfully destroyed"
                                                               delegate:self
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil, nil];
                [alert show];
            }
        }
    }];
}

- (NSMutableArray *)getAllParticipants {
    
    self.arrayAllParticipants = [[NSMutableArray alloc] init];
    for (NSString *to in self.messageItem.arrayTo) {
        [self.arrayAllParticipants addObject:to];
    }
    for (NSString *cc in self.messageItem.arrayCc) {
        [self.arrayAllParticipants addObject:cc];
    }
    for (NSString *bcc in self.messageItem.arrayBcc) {
        [self.arrayAllParticipants addObject:bcc];
    }
    
    return self.arrayAllParticipants;
}


#pragma mark - Private Methods
- (void)setupController {
    
    self.viewNavigation.layer.shadowColor = [[UIColor navigationShadowColor] CGColor];
    self.viewNavigation.layer.shadowOpacity = 0.6;
    self.viewNavigation.layer.shadowRadius = 0.5;
    self.viewNavigation.layer.shadowOffset = CGSizeMake(0, 1);
    
    self.viewSecure.layer.cornerRadius = 5;
    
    self.imageViewProfile.layer.cornerRadius = self.imageViewProfile.frame.size.width/2;
    self.imageViewProfile.image = [UIImage imageNamed:@"imageProfile1"];
    
    self.toCellHeight = 57;
    self.ccCellHeight = 57;
    self.bccCellHeight = 57;
}

- (void)fillFields {
    
    DmailMessage *dmailMessage = [[CoreDataManager sharedCoreDataManager] getDmailMessageWithMessageId:self.messageItem.dmailId];
    
    if (dmailMessage.body) {
        self.body = dmailMessage.body;
    }
    else {
        [self showLoadingView];
        [[MessageService sharedInstance] getDecodedMessageWithGmailUniqueId:self.messageItem.dmailId withCompletionBlock:^(NSString *message, NSInteger statusCode) {
            [self hideLoadingView];
            self.body = dmailMessage.body;
            [self.tableView reloadData];
        }];
    }
    
    [self createTableItems];
    [self.tableView reloadData];
}

- (void)createTableItems {
    
    GmailMessage *gmailMessage = [[CoreDataManager sharedCoreDataManager] getGmailMessageWithMessageId:self.messageItem.dmailId];
    self.arrayTo = [gmailMessage.to componentsSeparatedByString:@","];
    self.arrayCc = [gmailMessage.cc componentsSeparatedByString:@","];
    self.arrayBcc = [gmailMessage.bcc componentsSeparatedByString:@","];
    if ([self.arrayTo count] > 0) {
        [self.arrayTableItems addObject:@"1"];
    }
    if ([self.arrayCc count] > 0) {
        [self.arrayTableItems addObject:@"2"];
    }
    if ([self.arrayBcc count] > 0) {
        if ([self.arrayCc count] > 0) {
            [self.arrayTableItems addObject:@"3"];
        }
        else {
            [self.arrayTableItems addObject:@"2"];
            [self.arrayTableItems addObject:@"3"];
        }
    }
    [self.arrayTableItems addObject:@"4"];
}


#pragma mark - TableView DataSource & Delegate Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat rowHeight = 0;
    if ([self.arrayTableItems count] == 2) {
        if (indexPath.row == 0) {
            rowHeight = self.toCellHeight;
        }
        else {
            rowHeight = self.messageContentCellHeight;
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
                rowHeight = [UIScreen mainScreen].bounds.size.height - (65 + self.toCellHeight +self.ccCellHeight + self.bccCellHeight + self.viewSecure.frame.size.height);
                break;
            default:
                break;
        }
    }
    return rowHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.arrayTableItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self.arrayTableItems count] == 2) {
        switch (indexPath.row) {
            case 0: {
                ParticipantsCell *participantsCell = [tableView dequeueReusableCellWithIdentifier:@"participantsCellId"];
                participantsCell.delegate = self;
                [participantsCell configureCellForSentWithRow:indexPath.row withParticipants:self.arrayTo];
                participantsCell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                return participantsCell;
            }
                break;
            case 1: {
                MessageComposeCell *messageComposeCell = [tableView dequeueReusableCellWithIdentifier:@"messageComposeCellId"];
                messageComposeCell.delegate = self;
                [messageComposeCell configureCellWithBody:self.body subject:self.messageItem.subject];
                messageComposeCell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                return messageComposeCell;
            }
                break;
            default:
                break;
        }
    }
    else {
        switch (indexPath.row) {
            case 0: {
                ParticipantsCell *participantsCell = [tableView dequeueReusableCellWithIdentifier:@"participantsCellId"];
                participantsCell.translatesAutoresizingMaskIntoConstraints = YES;
                participantsCell.delegate = self;
                [participantsCell configureCellForSentWithRow:indexPath.row withParticipants:self.arrayTo];
                participantsCell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                return participantsCell;
            }
                break;
            case 1: {
                ParticipantsCell *participantsCell = [tableView dequeueReusableCellWithIdentifier:@"participantsCellId"];
                participantsCell.delegate = self;
                [participantsCell configureCellForSentWithRow:indexPath.row withParticipants:self.arrayCc];
                participantsCell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                return participantsCell;
            }
                break;
            case 2: {
                ParticipantsCell *participantsCell = [tableView dequeueReusableCellWithIdentifier:@"participantsCellId"];
                participantsCell.delegate = self;
                [participantsCell configureCellForSentWithRow:indexPath.row withParticipants:self.arrayBcc];
                participantsCell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                return participantsCell;
            }
                break;
            case 3: {
                MessageComposeCell *messageComposeCell = [tableView dequeueReusableCellWithIdentifier:@"messageComposeCellId"];
                messageComposeCell.delegate = self;
                [messageComposeCell configureCellWithBody:self.body subject:self.messageItem.subject];
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
    UIAlertView *alert= [[UIAlertView alloc] initWithTitle:@"Revoke access"
                                                   message:alertMessage
                                                  delegate:self
                                         cancelButtonTitle:@"Cancel"
                                         otherButtonTitles:@"Revoke", nil];
    alert.tag = Revoke;
    [alert show];
}

#pragma mark - UIAlertViewdelegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == Revoke) {
        switch (buttonIndex) {
            case 0:
                
                break;
            case 1: {
                [[MessageService sharedInstance] revokeUserWithEmail:self.revokedEmail dmailId:self.messageItem.dmailId completionBlock:^(BOOL success) {
                    if (success) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dmail"
                                                                        message:@"Participant are evoked"
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
    else {
        switch (buttonIndex) {
            case 0:
                
                break;
            case 1: {
                self.participantIndex = 0;
                [self getAllParticipants];
                [self destroyAllParticipants];
            }
                break;
            default:
                break;
        }
    }
}



@end
