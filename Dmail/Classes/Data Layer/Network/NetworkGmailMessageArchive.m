//
//  NetworkGmailMessageArchive.m
//  Dmail
//
//  Created by Karen Petrosyan on 7/28/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "NetworkGmailMessageArchive.h"

#import <GoogleSignIn.h>

@implementation NetworkGmailMessageArchive

static NSString * const kUrlMessagesArchive = @"%@/filter";
//static NSString * const kUrlMessagesArchive = @"venu/forwarding";


- (instancetype)init {
    
    self = [super initWithUrl:@"https://apps-apis.google.com/a/feeds/emailsettings/2.0/science-inc.com"];
    if (self) {
        
    }
    return self;
}

@end