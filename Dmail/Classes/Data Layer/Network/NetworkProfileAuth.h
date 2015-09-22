//
//  NetworkProfileAuth.h
//  Dmail
//
//  Created by Karen Petrosyan on 9/22/15.
//  Copyright © 2015 Karen Petrosyan. All rights reserved.
//

#import "BaseNetwork.h"

@interface NetworkProfileAuth : BaseNetwork

- (void)refreshTokenWith:(NSString *)refreshToken completionBlock:(CompletionBlock)completionBlock;

@end
