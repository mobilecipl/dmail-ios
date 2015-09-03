//
//  DAOProfilesSyncing.h
//  Dmail
//
//  Created by Karen Petrosyan on 9/3/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DAOProfilesSyncing : NSObject

- (NSArray *)getAllProfiles;
- (NSString *)getSelectedProfileEmail;

@end
