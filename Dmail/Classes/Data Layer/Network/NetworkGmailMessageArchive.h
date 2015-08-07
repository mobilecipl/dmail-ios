//
//  NetworkGmailMessageArchive.h
//  Dmail
//
//  Created by Karen Petrosyan on 7/28/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "BaseNetwork.h"

@interface NetworkGmailMessageArchive : BaseNetwork

- (void)archiveMessageWithFrom:(NSString *)from to:(NSString *)to subject:(NSString *)subject userID:(NSString *)userID CompletionBlock:(CompletionBlock)completionBlock;

@end
