//
//  DmailManager.h
//  Dmail
//
//  Created by Karen Petrosyan on 6/25/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DmailManager : NSObject

+ (DmailManager *)sharedInstance;

- (void)getDmailIds;

@end
