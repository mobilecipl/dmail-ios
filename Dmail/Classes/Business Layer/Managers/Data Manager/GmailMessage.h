//
//  GmailMessage.h
//  Dmail
//
//  Created by Karen Petrosyan on 6/29/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface GmailMessage : NSManagedObject

@property (nonatomic, retain) NSString * bcc;
@property (nonatomic, retain) NSString * cc;
@property (nonatomic, retain) NSString * dmailId;
@property (nonatomic, retain) NSString * gmailId;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSNumber * internalDate;
@property (nonatomic, retain) NSNumber * label;
@property (nonatomic, retain) NSString * subject;
@property (nonatomic, retain) NSString * to;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSString * publicKey;
@property (nonatomic, retain) NSString * from;

@end
