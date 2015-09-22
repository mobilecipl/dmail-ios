//
//  ContactModel.m
//  Dmail
//
//  Created by Karen Petrosyan on 7/3/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "ContactModel.h"
#import "RMModelContact.h"

@implementation ContactModel

- (instancetype)initWithEmail:(NSString *)email fullName:(NSString *)fullName firstName:(NSString *)firstName lastName:(NSString *)lastName contactId:(NSString *)contactId urlPhoto:(NSString *)urlPhoto profile:(NSString *)profile addressBook:(BOOL)addressBook {
    
    self = [super init];
    if (self) {
        _email = email;
        _firstName = firstName;
        _lastName = lastName;
        _fullName = fullName;
        _contactId = contactId;
        _urlPhoto = urlPhoto;
        _addressBook = addressBook;
        _profile = profile;
    }
    
    return self;
}

- (instancetype)initWithRMModel:(RMModelContact *)rmModel {
    
    self = [super init];
    if (self) {
        _email = rmModel.email;
        _firstName = rmModel.firstName;
        _lastName = rmModel.lastName;
        _fullName = rmModel.fullName;
        _contactId = rmModel.contactId;
        _urlPhoto = rmModel.imageUrl;
        _addressBook = rmModel.addressBook;
        _profile = rmModel.profile;
    }
    
    return self;
}

@end
