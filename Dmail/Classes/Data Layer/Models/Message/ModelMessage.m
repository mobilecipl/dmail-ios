//
//  ModelMessage.m
//  Dmail
//
//  Created by Karen Petrosyan on 7/10/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "ModelMessage.h"
#import <Realm/Realm.h>
#import "RMModelGmailMessage.h"
#import "RMModelDmailMessage.h"

@implementation ModelMessage

- (instancetype)initWithIdentifier:(NSString *)identifier {
    
    self = [super init];
    if (self) {
        RLMRealm *realm = [RLMRealm defaultRealm];
        
        RLMResults *resultsGmailMessages = [RMModelGmailMessage objectsInRealm:realm where:@"messageIdentifier = %@", identifier];
        RMModelGmailMessage *gmailMessage = [resultsGmailMessages firstObject];
        
        RLMResults *resultsDmailMessages = [RMModelDmailMessage objectsInRealm:realm where:@"messageIdentifier = %@", identifier];
        RMModelDmailMessage *dmailMessage = [resultsDmailMessages firstObject];
        
        self.messageIdentifier = identifier;
        self.internalDate = gmailMessage.internalDate;
        self.dmailId = dmailMessage.dmailId;
        self.gmailId = dmailMessage.gmailId;
        self.type = dmailMessage.type;
        self.read = gmailMessage.read;
        self.to = gmailMessage.to;
        //        self.cc = gmailMessage.cc;
        //        self.bcc = gmailMessage.bcc;
        
        self.subject = gmailMessage.subject;
        self.from = gmailMessage.from;
    }
    
    return self;
}

@end
