//
//  InboxMessageViewController.h
//  Dmail
//
//  Created by Karen Petrosyan on 6/14/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface InboxMessageViewController : BaseViewController

@property (nonatomic, strong) NSString *messageIdentifier;
@property (nonatomic, strong) NSString *messageId;

@end
