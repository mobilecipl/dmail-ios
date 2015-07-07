//
//  NetworkGmailContacts.h
//  Dmail
//
//  Created by Gevorg Ghukasyan on 7/6/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkGmailContacts : BaseNetwork

- (void)getGoogleContactsForEmail:(NSString *)email completionBlock:(CompletionBlock)completionBlock;

@end
