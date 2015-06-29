//
//  Message.h
//  Dmail
//
//  Created by Karen Petrosyan on 6/21/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Message : NSManagedObject

@property (nonatomic, retain) NSString * access;
@property (nonatomic, retain) NSString * bcc;
@property (nonatomic, retain) NSString * body;
@property (nonatomic, retain) NSString * cc;
@property (nonatomic, retain) NSString * from;
@property (nonatomic, retain) NSString * messageId;
@property (nonatomic, retain) NSString * messageIdentifier;
@property (nonatomic) int16_t messageStatus;
@property (nonatomic) float position;
@property (nonatomic, retain) NSString * subject;
@property (nonatomic, retain) NSString * to;
@property (nonatomic, retain) NSString * type;

@end
