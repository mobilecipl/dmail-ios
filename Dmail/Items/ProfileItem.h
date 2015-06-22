//
//  ProfileItem.h
//  Dmail
//
//  Created by Karen Petrosyan on 6/22/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProfileItem : NSObject

@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *name;

- (instancetype)initWithEmail:(NSString *)email name:(NSString *)name;

@end
