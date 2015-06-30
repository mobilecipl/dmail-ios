//
//  InboxMessageViewController.h
//  Dmail
//
//  Created by Karen Petrosyan on 6/14/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "MessageItem.h"


@interface InboxMessageViewController : BaseViewController

@property (nonatomic, strong) MessageItem *messageItem;

@end