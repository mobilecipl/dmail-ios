//
//  MessageParseService.h
//  Dmail
//
//  Created by Karen Petrosyan on 6/16/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageParseService : NSObject

+ (MessageParseService *)sharedInstance;

- (NSString *)gmailMessageId:(NSDictionary *)messageDict;

@end
