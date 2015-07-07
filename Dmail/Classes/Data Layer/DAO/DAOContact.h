//
//  DAOContact.h
//  Dmail
//
//  Created by Karen Petrosyan on 7/3/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseDAO.h"

@interface DAOContact : BaseDAO

- (void)syncGoogleContacts;

- (NSMutableArray *)getContactsFromLocalDBWithName:(NSString *)name;

@end
