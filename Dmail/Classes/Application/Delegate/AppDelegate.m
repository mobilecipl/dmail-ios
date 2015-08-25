//
//  AppDelegate.m
//  Dmail
//
//  Created by Karen Petrosyan on 6/12/15.
//  Copyright (c) 2015 Karen Petrosyan. All rights reserved.
//

#import "AppDelegate.h"

// google
#import <GoogleSignIn/GoogleSignIn.h>

// fabric
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

#import <Realm.h>

//DAO
#import "DAOAddressBook.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


#pragma mark - UIApplicationDelegate Methods
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    NSLog(@"Test brunch");
    [Fabric with:@[CrashlyticsKit]];

    //Realm
    [self realmMigration];
    //Google
    [self setupGoogleSignIn];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    return [[GIDSignIn sharedInstance] handleURL:url sourceApplication:sourceApplication annotation:annotation];
}

- (void)applicationWillResignActive:(UIApplication *)application {

}

- (void)applicationDidEnterBackground:(UIApplication *)application {

    [DAOAddressBook setShouldSyncAddressBookChanges:YES];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {

}

- (void)applicationWillTerminate:(UIApplication *)application {

}


#pragma mark - Private Methods
- (void)realmMigration {
    
    [RLMRealm setSchemaVersion:1 forRealmAtPath:[RLMRealm defaultRealmPath] withMigrationBlock:^(RLMMigration *migration, uint64_t oldSchemaVersion) {
        // We haven’t migrated anything yet, so oldSchemaVersion == 0
        if (oldSchemaVersion < 1) {
            // Nothing to do!
            // Realm will automatically detect new properties and removed properties
            // And will update the schema on disk automatically
        }
    }];
    NSLog(@"RLMRealm path: %@", [RLMRealm defaultRealm].path);
}

- (void)setupGoogleSignIn {
    
    [GIDSignIn sharedInstance].clientID = kGoogleClientID;
    [[GIDSignIn sharedInstance] setScopes:@[@"https://www.google.com/m8/feeds/", @"https://mail.google.com/", @"https://apps-apis.google.com/a/feeds/emailsettings/2.0/"]];
}

@end
