//
//  ComposeViewController.h
//  Dmail
//
//  Created by Karen Petrosyan on 6/16/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface ComposeViewController : BaseViewController

@property (nonatomic, strong) NSString *replyedMessageSubject;
@property (nonatomic, strong) NSString *replyedRecipientEmail;
@property (nonatomic, strong) NSString *replyedRecipientName;

@end
