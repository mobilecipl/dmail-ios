//
//  ModelGmailMessage.m
//  Dmail
//
//  Created by Karen Petrosyan on 7/8/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "ModelGmailMessage.h"

@implementation ModelGmailMessage

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    
    self = [super initWithDictionary:dict];
    if (self) {
        
        _gmailId = dict[@"id"];
    }
    
    return self;
}
@end
