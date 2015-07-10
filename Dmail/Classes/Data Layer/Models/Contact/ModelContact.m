//
//  ModelContact.m
//  Dmail
//
//  Created by Gevorg Ghukasyan on 7/8/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "ModelContact.h"



@implementation ModelContact

- (instancetype)initWithEmail:(NSString *)email fullName:(NSString *)fullName contactId:(NSString *)contactId urlPhoto:(NSString *)urlPhoto {
    
    self = [super init];
    if (self) {
        _email = email;
        _fullName = fullName;
        _contactId = contactId;
        _urlPhoto = urlPhoto;
    }
    
    return self;
}

@end
