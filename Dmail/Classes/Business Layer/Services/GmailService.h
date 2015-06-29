//
//  GmailService.h
//  Dmail
//
//  Created by Karen Petrosyan on 6/15/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleSignIn/GoogleSignIn.h>

@protocol GmailServiceDelegate <NSObject>

@optional

- (void)gmailSignedInWithUser:(GIDGoogleUser *)user;

@end

@interface GmailService : NSObject <GIDSignInDelegate>

@property (nonatomic, weak) id <GmailServiceDelegate> delegate;

- (id)init;

- (void)gmailSignIn;

@end
