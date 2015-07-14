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
#import "MessageService.h"

// view model
#import "VMSentMessage.h"

// model

#import "ParticipantsCell.h"
#import "MessageComposeCell.h"

#import "UIColor+AppColors.h"
#import "UIImageView+WebCache.h"

typedef NS_ENUM(NSInteger, AlertTags) {
    Revoke = 1,
    Destroy
};

@interface SentMessageViewController () <ParticipantsCellDelegate, MessageComposeCellDelegate>

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
    
    self.arrayTableItems = [[NSMutableArray alloc] init];
    [self loadData];
    [self setupController];
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
            @weakify(self);
            [self.serviceMessage getMessageBodyWithIdentifier:self.messageId completionBlock:^(NSString *body, ErrorDataModel *error) {
                @strongify(self);
                self.body = body;
                NSInteger bodyRow = [self getBodyRow];
                NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:bodyRow inSection:0];
                NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
                [self.tableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
                
                [self hideLoadingView];
            }];
        }
        else {
            self.body = self.modelMessage.body;
        }
    }
    [self.tableView reloadData];
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
    
    [[MessageService sharedInstance] revokeUserWithEmail:[self.arrayAllParticipants objectAtIndex:self.participantIndex] dmailId:self.modelMessage.dmailId completionBlock:^(BOOL success) {
        if (success) {
            self.participantIndex ++;
            if (self.participantIndex > [self.arrayAllParticipants count] - 1) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dmail"
                                                                message:@"Participants are successfully destroyed"
                                                               delegate:self
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil, nil];
                [alert show];
            }
            else {
                [self destroyAllParticipants];
            }
        }
        else {
            if (self.participantIndex <= [self.arrayAllParticipants count] - 1) {
                [self destroyAllParticipants];
            }
        }
    }];
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


#pragma mark - Private Methods
- (void)setupController {
    
    self.viewNavigation.layer.shadowColor = [[UIColor navigationShadowColor] CGColor];
    self.viewNavigation.layer.shadowOpacity = 0.6;
    self.viewNavigation.layer.shadowRadius = 0.5;
    self.viewNavigation.layer.shadowOffset = CGSizeMake(0, 1);
    
    self.viewSecure.layer.cornerRadius = 5;
    self.viewSecure.layer.borderColor = [UIColor colorWithRed:197.0/255.0 green:215.0/255.0 blue:227.0/255.0 alpha:1].CGColor;
    self.viewSecure.layer.borderWidth = 1;
    
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
    if ([self.arrayTo count] > 0) {
        [self.arrayTableItems addObject:@"1"];
        self.toCellHeight = 57;
    }
    if ([self.arrayCc count] > 0) {
        self.ccCellHeight = 57;
        [self.arrayTableItems addObject:@"2"];
    }
    if ([self.arrayBcc count] > 0) {
        self.bccCellHeight = 57;
        if ([self.arrayCc count] > 0) {
        }
        else {
            [self.arrayTableItems addObject:@"2"];
            [self.arrayTableItems addObject:@"3"];
        }
    }
    [self.arrayTableItems addObject:@"4"];
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
            rowHeight = [UIScreen mainScreen].bounds.size.height - (70 + self.toCellHeight + self.ccCellHeight + self.bccCellHeight + self.viewSecure.frame.size.height);
        }
    }
    else if ([self.arrayTableItems count] == 3) {
        switch (indexPath.row) {
            case 0:
                rowHeight = self.toCellHeight;
                break;
            case 1:
                rowHeight = self.ccCellHeight;
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
    
    return self.arrayTableItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self.arrayTableItems count] == 2) {
        switch (indexPath.row) {
            case 0: {
                ParticipantsCell *participantsCell = [tableView dequeueReusableCellWithIdentifier:@"participantsCellId"];
                participantsCell.delegate = self;
                [participantsCell configureCellForSentWithRow:indexPath.row withParticipants:self.arrayTo messageId:self.messageId];
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
    else if ([self.arrayTableItems count] == 3) {
        switch (indexPath.row) {
            case 0: {
                ParticipantsCell *participantsCell = [tableView dequeueReusableCellWithIdentifier:@"participantsCellId"];
                participantsCell.translatesAutoresizingMaskIntoConstraints = YES;
                participantsCell.delegate = self;
                [participantsCell configureCellForSentWithRow:indexPath.row withParticipants:self.arrayTo messageId:self.messageId];
                participantsCell.selectionStyle = UITableViewCellSelectionStyleNone;
                return participantsCell;
            }
            case 1: {
                ParticipantsCell *participantsCell = [tableView dequeueReusableCellWithIdentifier:@"participantsCellId"];
                participantsCell.delegate = self;
                [participantsCell configureCellForSentWithRow:indexPath.row withParticipants:self.arrayCc messageId:self.messageId];
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
                [participantsCell configureCellForSentWithRow:indexPath.row withParticipants:self.arrayTo messageId:self.messageId];
                participantsCell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                return participantsCell;
            }
                break;
            case 1: {
                ParticipantsCell *participantsCell = [tableView dequeueReusableCellWithIdentifier:@"participantsCellId"];
                participantsCell.delegate = self;
                [participantsCell configureCellForSentWithRow:indexPath.row withParticipants:self.arrayCc messageId:self.messageId];
                participantsCell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                return participantsCell;
            }
                break;
            case 2: {
                ParticipantsCell *participantsCell = [tableView dequeueReusableCellWithIdentifier:@"participantsCellId"];
                participantsCell.delegate = self;
                [participantsCell configureCellForSentWithRow:indexPath.row withParticipants:self.arrayBcc messageId:self.messageId];
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
                [[MessageService sharedInstance] revokeUserWithEmail:self.revokedEmail dmailId:self.modelMessage.dmailId completionBlock:^(BOOL success) {
                    NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:0 inSection:0];
                    if ([self.arrayCc count] > 0) {
                        rowToReload = [NSIndexPath indexPathForRow:1 inSection:0];
                    }
                    if ([self.arrayBcc count] > 0) {
                        rowToReload = [NSIndexPath indexPathForRow:2 inSection:0];
                    }
                    NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
                    [self.tableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
                    if (success) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dmail"
                                                                        message:@"Participant is revoked"
                                                                       delegate:self
                                                              cancelButtonTitle:@"Ok"
                                                              otherButtonTitles:nil, nil];
                        [alert show];
                        [self.navigationController popViewControllerAnimated:YES];
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
