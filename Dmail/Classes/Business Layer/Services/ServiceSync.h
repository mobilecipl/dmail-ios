//
//  ServiceSync.h
//  Dmail
//
//  Created by Armen Mkrtchian on 7/7/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "BaseService.h"

@interface ServiceSync : BaseService

@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *token;

- (instancetype)initWithEmail:(NSString *)email userId:(NSString *)userId;
- (void)sync;
- (void)logOut;
- (void)stopSync;
- (void)refreshAccessToken;

@end
