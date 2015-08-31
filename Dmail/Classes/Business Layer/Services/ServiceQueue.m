//
//  ServiceQueue.m
//  Dmail
//
//  Created by Karen Petrosyan on 8/31/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "ServiceQueue.h"
#import "DAOQueue.h"

@interface ServiceQueue ()

@property (nonatomic, strong) DAOQueue *daoQueue;

@end


@implementation ServiceQueue

- (instancetype)init {
    
    self = [super init];
    if (self) {
        _daoQueue = [[DAOQueue alloc] init];
    }
    
    return self;
}

- (void)getQueueWithUserId:(NSString *)deviceId completionBlock:(CompletionBlock)completionBlock {
    
    [self.daoQueue getQueueWithUserId:deviceId completionBlock:^(id data, ErrorDataModel *error) {
        completionBlock(data, error);
    }];
}

- (void)sendTokenWithDeviceId:(NSString *)deviceId token:(NSString *)token completionBlock:(CompletionBlock)completionBlock {
    
    [self.daoQueue sendTokenWithDeviceId:deviceId token:token completionBlock:^(id data, ErrorDataModel *error) {
        completionBlock(data, error);
    }];
}

@end
