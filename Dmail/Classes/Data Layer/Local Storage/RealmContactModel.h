//
//  RealmContactModel.h
//  Dmail
//
//  Created by Karen Petrosyan on 7/3/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AutoDefaultsRMLObject.h"
#import "ContactModel.h"

@interface RealmContactModel : AutoDefaultsRMLObject

@property NSString *fullName;
@property NSString *email;
@property NSString *contactId;

- (instancetype)initWithContactModel:(ContactModel *)model;

@end
