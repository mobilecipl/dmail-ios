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

static NSString * const kErrorMessageNoServer = @"Please try later\nWe are unable to connect to the server";


#pragma mark - Notifications
static NSString * const NotificationMenuButton = @"NotificationMenuButton";
static NSString * const NotificationInbox = @"NotificationInbox";
static NSString * const NotificationSent = @"NotificationSent";
static NSString * const NotificationMessageInbox = @"NotificationMessageInbox";
static NSString * const NotificationMessageSent = @"NotificationMessageSent";
static NSString * const NotificationNewMessageFetched = @"NotificationNewMessageFetched";
static NSString * const NotificationNewMessageSent = @"NotificationNewMessageSent";
static NSString * const NotificationNewMessageSentError = @"NotificationNewMessageSentError";
static NSString * const NotificationUpdateContacts = @"NotificationUpdateContacts";
static NSString * const NotificationGMailUniqueFetched = @"NotificationGMailUniqueFetched";
static NSString * const NotificationGMailMessageFetched = @"NotificationGMailMessageFetched";

static NSString * const NotificationDestroySuccess = @"NotificationDestroySuccess";
static NSString * const NotificationDestroyFailed = @"NotificationDestroyFailed";
static NSString * const NotificationRevokeSuccess = @"NotificationRevokeSuccess";
static NSString * const NotificationRevokeFailed = @"NotificationRevokeFailed";


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



#pragma mark - Request Keys
#pragma mark - Get Message List
static NSString * const Recipients = @"recipients";

static NSString * const Count = @"count";
static NSString * const RecipientType = @"recipient_type";
static NSString * const RecipientEmail = @"recipient_email";
static NSString * const EncryptedMessage = @"encrypted_message";
static NSString * const SenderEmail = @"sender_email";
static NSString * const Bottom = @"bottom";
static NSString * const Subject = @"Subject";
static NSString * const Body = @"body";
static NSString * const InternalDate = @"internalDate";
static NSString * const Payload = @"payload";
static NSString * const Headers = @"headers";
static NSString * const Name = @"name";
static NSString * const Value = @"value";
static NSString * const From = @"From";
static NSString * const To = @"To";
static NSString * const Cc = @"Cc";
static NSString * const Bcc = @"Bcc";
static NSString * const Email = @"email";
static NSString * const Message_Id = @"Message-Id";
static NSString * const Status = @"status";
static NSString * const PublicKey = @"PublicKey";
static NSString * const Snippet = @"snippet";
static NSString * const DmailId = @"DmailId";

//Dmail Keys
static NSString * const Access = @"access";
static NSString * const MessageId = @"messageId";
static NSString * const MessageIdentifier = @"messageIdentifier";
static NSString * const Position = @"position";
static NSString * const Type = @"type";

static NSString * const AccessTypeGaranted = @"GRANTED";
static NSString * const AccessTypeRevoked = @"REVOKED";

#endif
