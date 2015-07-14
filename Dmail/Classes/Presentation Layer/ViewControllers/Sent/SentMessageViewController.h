//
//  SentMessageViewController.h
//  Dmail
//
//  Created by Karen Petrosyan on 6/25/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface SentMessageViewController : BaseViewController

@property (nonatomic, strong) NSString *messageId;
@property (nonatomic, strong) NSString *messageIdentifier;

@end
