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

#pragma mark - Messages
static NSString * kGlobalAlertMessageBasicFailure = @"Something went wrong\nPlease try again.";
static NSString * kGlobalAlertMessageRequestTimeOutReplaceler = @"Looks like there's a bad connection. Please try again in a minute or so!";
static NSString * kGlobalAlertMessageInvalidLoginCridentials = @"Please check your login information and try again.";

static NSString * const kErrorMessageNoServer = @"Please try later\nWe are unable to connect to the server";


#pragma mark - Notifications
static NSString * const NotificationNewMessageFetched = @"NotificationNewMessageFetched";
static NSString * const NotificationNewMessageSent = @"NotificationNewMessageSent";
static NSString * const NotificationNewMessageSentError = @"NotificationNewMessageSentError";
static NSString * const NotificationGMailUniqueFetched = @"NotificationGMailUniqueFetched";
static NSString * const NotificationGMailMessageFetched = @"NotificationGMailMessageFetched";
static NSString * const NotificationDestroySuccess = @"NotificationDestroySuccess";
static NSString * const NotificationDestroyFailed = @"NotificationDestroyFailed";
static NSString * const NotificationRevokeSuccess = @"NotificationRevokeSuccess";
static NSString * const NotificationRevokeFailed = @"NotificationRevokeFailed";
static NSString * const NotificationGetDecryptedMessage = @"NotificationGetDecryptedMessage";
static NSString * const NotificationMenuOpened = @"menuOpened";
static NSString * const NotificationMenuClosed = @"menuClosed";

typedef NS_ENUM(NSInteger, MessageLabel) {
    Inbox = 1,
    Sent
};

typedef NS_ENUM(NSInteger, MessageType) {
    Unread = 1,
    Read
};

typedef NS_ENUM(NSInteger, MessageStatus) {
    MessageFetchedOnlyDmailIds = 1,
    MessageFetchedOnlyGmailIds,
    MessageFetchedFull,
    MessageSentOnlyBody,
    MessageSentParticipants,
    MessageSentToGmail,
    MessageSentFull,
    MessageRevoke,
    MessageRemovedFromGmail
};


static NSInteger kMessageUpdateTime = 10;
static NSInteger kMessageGetCount = 30;
static NSInteger kProfileImageSize = 50;

#endif
