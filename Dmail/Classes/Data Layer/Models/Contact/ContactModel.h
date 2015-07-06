//
//  ContactModel.h
//  Dmail
//
//  Created by Karen Petrosyan on 7/3/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RealmContactModel;

@interface ContactModel : NSObject

@property NSString *fullName;
@property NSString *email;
@property NSString *contactId;

- (instancetype)initWithEmail:(NSString *)email fullName:(NSString *)fullName contactId:(NSString *)contactId;
- (instancetype)initWithRMModel:(RealmContactModel *)rmModel;

@end
