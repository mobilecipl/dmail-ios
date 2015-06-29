//
//  AppDelegate.m
//  Dmail
//
//  Created by Karen Petrosyan on 6/12/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "AppDelegate.h"
#import "Configurations.h"
#import <GoogleSignIn/GoogleSignIn.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "UserService.h"
#import "SyncService.h"
#import "GmailManager.h"
#import "NSString+AESCrypt.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [Fabric with:@[CrashlyticsKit]];

    [self setupGoogleSignIn];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    return [[GIDSignIn sharedInstance] handleURL:url sourceApplication:sourceApplication annotation:annotation];
}

- (void)applicationWillResignActive:(UIApplication *)application {

}

- (void)applicationDidEnterBackground:(UIApplication *)application {

}

- (void)applicationWillEnterForeground:(UIApplication *)application {

}

- (void)applicationDidBecomeActive:(UIApplication *)application {

    [[GmailManager sharedInstance] getMessages];
}

- (void)applicationWillTerminate:(UIApplication *)application {

}


#pragma mark - Private Methods
- (void)setupGoogleSignIn {
    
    [GIDSignIn sharedInstance].clientID = kGoogleClientID;
    [[GIDSignIn sharedInstance] setScopes:[NSArray arrayWithObject:@"https://mail.google.com/"]];
}

@end
