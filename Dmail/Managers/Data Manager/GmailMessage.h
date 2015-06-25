//
//  GmailMessage.h
//  Dmail
//
//  Created by Karen Petrosyan on 6/25/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface GmailMessage : NSManagedObject

@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * dmailId;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSString * subject;
@property (nonatomic, retain) NSString * senderEmail;
@property (nonatomic, retain) NSString * senderName;
@property (nonatomic, retain) NSNumber * internalDate;
@property (nonatomic, retain) NSNumber * label;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSString * receiverEmail;
@property (nonatomic, retain) NSString * receiverName;

@end
