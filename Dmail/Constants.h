//
//  Constants.h
//  Dmail
//
//  Created by Karen Petrosyan on 6/17/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#ifndef Dmail_Constants_h
#define Dmail_Constants_h

typedef void(^mainCompletionBlock)(NSDictionary *requestData, NSInteger statusCode);

#pragma mark - Inbox Constants
static NSString * SenderName = @"senderName";
static NSString * MessageSubject = @"messageSubject";
static NSString * MessageDate = @"messageDate";
static NSString * MessageGmailUniqueId = @"messageGmailUniqueId";


#pragma mark - Messages
static NSString * kGlobalAlertMessageBasicFailure = @"Something went wrong\nPlease try again.";
static NSString * kGlobalAlertMessageRequestTimeOutReplaceler = @"Looks like there's a bad connection. Please try again in a minute or so!";
static NSString * kGlobalAlertMessageInvalidLoginCridentials = @"Please check your login information and try again.";


typedef NS_ENUM(NSInteger, MessageType) {
    Inbox,
    Sent
};

#endif
