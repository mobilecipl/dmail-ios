//
//  AppDelegate.h
//  Dmail
//
//  Created by Karen Petrosyan on 6/12/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServiceProfilesSyncing.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ServiceProfilesSyncing *serviceProfilesSyncing;
@property (nonatomic, assign) BOOL signedIn;

+ (AppDelegate *)sharedDelegate;
- (void)registerNotifications;

@end

