//
//  ServiceQueue.h
//  Dmail
//
//  Created by Karen Petrosyan on 8/31/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "BaseService.h"

@interface ServiceQueue : BaseService

- (void)getQueueWithUserId:(NSString *)deviceId completionBlock:(CompletionBlock)completionBlock;
- (void)sendTokenWithDeviceId:(NSString *)deviceId token:(NSString *)token completionBlock:(CompletionBlock)completionBlock;

@end
