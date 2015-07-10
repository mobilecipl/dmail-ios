//
//  VMSentMessage.h
//  Dmail
//
//  Created by Armen Mkrtchian on 7/10/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "BaseViewModel.h"

@class ModelMessage;

@interface VMSentMessage : BaseViewModel

@property (nonatomic, strong) NSString *dmailId;
@property (nonatomic, strong) NSString *profileImageUrl;
@property (nonatomic, strong) NSString *messageSubject;
@property (nonatomic, assign) long long internalDate;
@property (nonatomic, strong) NSString *messageIdentifier;

@property NSArray *arrayTo;
@property NSArray *arrayCc;
@property NSArray *arrayBcc;

- (instancetype)initWithModel:(ModelMessage *)model;

@end
