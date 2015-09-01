//
//  DAOQueue.m
//  Dmail
//
//  Created by Karen Petrosyan on 8/31/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "DAOQueue.h"
#import "NetworkQueue.h"

@interface DAOQueue ()

@property (nonatomic, strong) NetworkQueue *networkQueue;

@end

@implementation DAOQueue

- (instancetype)init {
    
    self = [super init];
    if (self) {
        _networkQueue = [[NetworkQueue alloc] init];
    }
    
    return self;
}

- (void)getQueueWithUserId:(NSString *)deviceId completionBlock:(CompletionBlock)completionBlock {
    
    [self.networkQueue getQueueWithUserId:deviceId completionBlock:^(id data, ErrorDataModel *error) {
        completionBlock(data, error);
    }];
}

- (void)sendTokenWithDeviceId:(NSString *)deviceId token:(NSString *)token completionBlock:(CompletionBlock)completionBlock {
    
    [self.networkQueue sendTokenWithDeviceId:deviceId token:token completionBlock:^(id data, ErrorDataModel *error) {
        completionBlock(data, error);
    }];
}

@end
