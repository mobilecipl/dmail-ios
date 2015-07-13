//
//  MessageItem.m
//  Dmail
//
//  Created by Karen Petrosyan on 6/21/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "MessageItem.h"
#import "DAOContact.h"

@implementation MessageItem

- (void)createRecipients {
    
    self.recipients = @"";
    DAOContact *daoContact = [[DAOContact alloc] init];
    for (NSString *email in self.arrayTo) {
        NSString *name = [daoContact contactNameWithEmail:email];
        if (name.length > 0) {
            self.recipients = [self.recipients stringByAppendingString:name];
        }
        else {
            self.recipients = [self.recipients stringByAppendingString:email];
        }
        self.recipients = [self.recipients stringByAppendingString:@", "];
    }
    for (NSString *email in self.arrayCc) {
        NSString *name = [daoContact contactNameWithEmail:email];
        if (name.length > 0) {
            self.recipients = [self.recipients stringByAppendingString:name];
        }
        else {
            self.recipients = [self.recipients stringByAppendingString:email];
        }
        self.recipients = [self.recipients stringByAppendingString:@", "];
    }
    for (NSString *email in self.arrayBcc) {
        NSString *name = [daoContact contactNameWithEmail:email];
        if (name.length > 0) {
            self.recipients = [self.recipients stringByAppendingString:name];
        }
        else {
            self.recipients = [self.recipients stringByAppendingString:email];
        }
        self.recipients = [self.recipients stringByAppendingString:@", "];
    }
    
    if ([self.recipients length] > 0) {
        self.recipients = [self.recipients substringToIndex:[self.recipients length] - 2];
    }
}

@end
