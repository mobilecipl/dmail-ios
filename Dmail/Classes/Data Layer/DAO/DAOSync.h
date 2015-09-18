//
//  DAOSync.h
//  Dmail
//
//  Created by Armen Mkrtchian on 7/7/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "BaseDAO.h"

@interface DAOSync : BaseDAO

- (void)syncMessagesForEmail:(NSString *)recipientEmail position:(NSNumber *)position count:(NSNumber *)count completionBlock:(CompletionBlock)completionBlock;

@end
