//
//  ProfileItem.m
//  Dmail
//
//  Created by Karen Petrosyan on 6/22/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "ProfileItem.h"

@implementation ProfileItem

- (instancetype)initWithEmail:(NSString *)email name:(NSString *)name {
    
    self = [super init];
    if (self != nil) {
        self.email = email;
        self.name = (name)?name:@"";
    }
    
    return  self;
}

@end
