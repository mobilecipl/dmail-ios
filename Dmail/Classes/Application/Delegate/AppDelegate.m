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
    
    
    NSString *key = @"key";
    NSString *secret = @"text";
    
    NSData *plain = [secret dataUsingEncoding:NSUTF8StringEncoding];
    NSData *cipher = [plain AES256EncryptWithKey:key];
    NSString* newStr = [[NSString alloc] initWithData:cipher encoding:NSUTF8StringEncoding];
    NSLog(@"newStr === %@", newStr);
    printf("%s\n", [[cipher description] UTF8String]);
    
    plain = [cipher AES256DecryptWithKey:key];
    NSLog(@"newStr === %@", newStr);
    printf("%s\n", [[plain description] UTF8String]);
    printf("%s\n", [[[NSString alloc] initWithData:plain encoding:NSUTF8StringEncoding] UTF8String]);
    
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
}

- (void)setupGoogleSignIn {
    
    [GIDSignIn sharedInstance].clientID = kGoogleClientID;
    [[GIDSignIn sharedInstance] setScopes:[NSArray arrayWithObject:@"https://mail.google.com/"]];
}

@end
