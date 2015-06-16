//
//  MessageParseService.m
//  Dmail
//
//  Created by Karen Petrosyan on 6/16/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "MessageParseService.h"

@implementation MessageParseService

static NSString * const messages = @"messages";
static NSString * const messageID = @"messages";


+ (MessageParseService *)sharedInstance {
    static MessageParseService *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[MessageParseService alloc] init];
    });
    
    return sharedInstance;
}

- (NSString *)gmailMessageId:(NSDictionary *)messageDict {
    
    NSString *messageId = @"";
//    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"key",@"aaaa", nil];
//    NSLog(@"dict.allKeys === %@", dict.allKeys);
    NSDictionary *messageFields = messageDict[messages];
//    messageId = messageFields[messageID];
    
    return messageId;
}

@end
