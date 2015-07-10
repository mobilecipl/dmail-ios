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
        _dmailId = model.dmailId;
        _messageSubject = model.subject;
        _internalDate = model.internalDate;
        _messageIdentifier = model.messageIdentifier;
        
        _arrayTo = [model.to componentsSeparatedByString:@","];
        _arrayCc = [model.cc componentsSeparatedByString:@","];
        _arrayBcc = [model.bcc componentsSeparatedByString:@","];
    }
    
    return self;
}

@end
