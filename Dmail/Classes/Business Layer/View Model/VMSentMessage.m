//
//  VMSentMessage.m
//  Dmail
//
//  Created by Armen Mkrtchian on 7/10/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "VMSentMessage.h"

//Model
#import "ModelMessage.h"

@implementation VMSentMessage

- (instancetype)initWithModel:(ModelMessage *)model {
    
    self = [super init];
    if (self) {
        _dmailId = model.messageId;
        _messageSubject = model.subject;
        _internalDate = model.internalDate;
        _messageIdentifier = model.messageIdentifier;
        _imageUrl = model.imageUrl;
        _body = model.body;
        _arrayTo = model.to;
        _arrayCc = model.cc;
        _arrayBcc = model.bcc;
    }
    
    return self;
}

@end
