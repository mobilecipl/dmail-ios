//
//  AppDelegate.m
//  Dmail
//
//  Created by Karen Petrosyan on 6/12/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "AppDelegate.h"

// service
#import "GmailManager.h"

// google
#import <GoogleSignIn/GoogleSignIn.h>

// fabric
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

// util
#import "NSString+AESCrypt.h"

#import <Realm.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [Fabric with:@[CrashlyticsKit]];

    //Realm
    [self realmMigration];
    
    [self setupGoogleSignIn];
    
    return YES;
}

- (void)realmMigration {
    
    [RLMRealm setSchemaVersion:1
                forRealmAtPath:[RLMRealm defaultRealmPath]
            withMigrationBlock:^(RLMMigration *migration, uint64_t oldSchemaVersion) {
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < 1) {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
            }];
    NSLog(@"RLMRealm path: %@", [RLMRealm defaultRealm].path);
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
