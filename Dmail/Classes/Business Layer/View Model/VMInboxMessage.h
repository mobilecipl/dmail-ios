//
//  VMInboxMessage.h
//  Dmail
//
//  Created by Armen Mkrtchian on 7/9/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "BaseViewModel.h"

@interface VMInboxMessage : BaseViewModel

@property (nonatomic, strong) NSString *senderName;
@property (nonatomic, strong) NSString *messageSubject;
@property (nonatomic, strong) NSString *messageDate;
@property (nonatomic, strong) NSString *messageIdentifier;
@property (nonatomic, getter=isRead) BOOL read;

- (NSAttributedString *)senderNameAttributed;
@end
