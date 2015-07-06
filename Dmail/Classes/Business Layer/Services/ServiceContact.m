//
//  ServiceContact.m
//  Dmail
//
//  Created by Karen Petrosyan on 7/3/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "ServiceContact.h"
#import "DAOContact.h"

@interface ServiceContact ()

@property (nonatomic, strong) DAOContact *daoContact;

@end

@implementation ServiceContact

- (instancetype)init {
    
    if (self) {
        _daoContact = [[DAOContact alloc] init];
    }
    
    return self;
}

- (void)getContactsFromGoogle {
    
    [self.daoContact syncGoogleContacts];
}

@end
