//
//  ContactModel.h
//  Dmail
//
//  Created by Karen Petrosyan on 7/3/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RMModelContact;

@interface ContactModel : NSObject

@property NSString *firstName;
@property NSString *lastName;
@property NSString *fullName;
@property NSString *email;
@property NSString *contactId;
@property NSString *urlPhoto;
@property NSDate *updated;

- (instancetype)initWithEmail:(NSString *)email
                     fullName:(NSString *)fullName
                    firstName:(NSString *)firstName
                     lastName:(NSString *)lastName
                    contactId:(NSString *)contactId
                     urlPhoto:(NSString *)urlPhoto
                      updated:(NSDate *)updated;

- (instancetype)initWithRMModel:(RMModelContact *)rmModel;

@end
