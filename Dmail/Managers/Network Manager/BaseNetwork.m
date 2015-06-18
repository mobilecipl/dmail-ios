//
//  BaseNetwork.m
//  Dmail
//
//  Created by Karen Petrosyan on 6/17/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "BaseNetwork.h"


@implementation BaseNetwork

- (NSString *)getMessageForError:(NSError *)error {

    NSLog(@"ERROR CODE           ----------- %ld", (long)error.code);
    NSLog(@"ERROR DESCRIPTION    ----------- %@" , error.localizedDescription);
    
    NSString *errorMessage;
    if ([error.localizedDescription isEqualToString:@"The Internet connection appears to be offline."] || [error.localizedDescription isEqualToString:@"The network connection was lost."]) {
        
        errorMessage = error.localizedDescription;
    } else if ([error.localizedDescription isEqualToString:@"The request timed out."]) {
        errorMessage = kGlobalAlertMessageRequestTimeOutReplaceler;
    }
    else {
        errorMessage = kGlobalAlertMessageInvalidLoginCridentials;
    }
    
    return errorMessage;
}


@end
