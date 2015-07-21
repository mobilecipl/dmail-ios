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

- (NSMutableArray *)getContactsWithName:(NSString *)name;

- (NSString *)contactNameWithEmail:(NSString *)email;

- (void)getContactsForEmail:(NSString *)email startIndex:(NSString *)startIndex maxResult:(NSString *)maxResult completionBlock:(CompletionBlock)completionBlock;

@end
