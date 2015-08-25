//
//  DAOAddressBook.h
//  Dmail
//
//  Created by Karen Petrosyan on 8/25/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DAOAddressBook : NSObject

- (void)syncAddressBook;
- (void)requestAccessWithCompletion:(void (^)(BOOL granted, NSError *requestError))completion;
+ (void)setShouldSyncAddressBookChanges:(BOOL)sync;

@end
