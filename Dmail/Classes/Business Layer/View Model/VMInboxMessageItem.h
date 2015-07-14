//
//  VMInboxMessageItem.h
//  Dmail
//
//  Created by Armen Mkrtchian on 7/9/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "BaseViewModel.h"

@interface VMInboxMessageItem : BaseViewModel

@property (nonatomic, strong) NSString *senderName;
@property (nonatomic, strong) NSString *senderEmail;
@property (nonatomic, strong) NSString *body;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSString *messageSubject;
@property (nonatomic, strong) NSString *messageDate;
@property (nonatomic, strong) NSString *messageId;
@property (nonatomic, getter=isRead) BOOL read;

@end
