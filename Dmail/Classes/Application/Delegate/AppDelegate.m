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

//Leanplum
#import <Leanplum/Leanplum.h>

// fabric
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

//Realm
#import <Realm.h>


//Service
#import "ServiceQueue.h"

//DAO
#import "DAOAddressBook.h"

@interface AppDelegate ()

@property (nonatomic, strong) ServiceQueue *serviceQueue;

@end

DEFINE_VAR_STRING(welcomeMessage, @"Welcome to Leanplum!");

@implementation AppDelegate


#pragma mark - UIApplicationDelegate Methods
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [Fabric with:@[CrashlyticsKit]];

    //Realm
    [self realmMigration];
    //Google
    [self setupGoogleSignIn];
    
    [self registerNotifications];
    
    self.serviceProfilesSyncing = [[ServiceProfilesSyncing alloc] init];
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *viewController;
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:InQueue]) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        viewController = [storyBoard instantiateViewControllerWithIdentifier:@"queue"];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
        self.window.rootViewController = navController;
    }
    else if ([[NSUserDefaults standardUserDefaults] boolForKey:GetStarted]) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        if (![[NSUserDefaults standardUserDefaults] boolForKey:OnboardingWasShowed]) {
            viewController = [storyBoard instantiateViewControllerWithIdentifier:@"onboarding"];
        }
        else {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:SetupPin]) {
                viewController = [storyBoard instantiateViewControllerWithIdentifier:@"setupPin"];
            }
            else {
                viewController = [storyBoard instantiateViewControllerWithIdentifier:@"loadingView"];
            }
        }
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
        self.window.rootViewController = navController;
    }
    
#ifdef DEBUG
    LEANPLUM_USE_ADVERTISING_ID;
    [Leanplum setAppId:@"app_awUO5zXzZsvHX83Qv1l3WdwcHaJDvxyykuNF1uwuWo8" withDevelopmentKey:@"dev_bHCcm15KKEvqBBRpaaVe0tNiezEOEQj6Bo1jEMKQyiE"];
#else
    [Leanplum setAppId:@"app_awUO5zXzZsvHX83Qv1l3WdwcHaJDvxyykuNF1uwuWo8" withProductionKey:@"prod_0QrMhGuGOxeqlDQYsdWNpMFoZpWZENdaIzDaNQ1g6Lo"];
#endif
    [Leanplum start];
    
    [Leanplum onVariablesChanged:^{
        NSLog(@"%@", welcomeMessage.stringValue);
        [Leanplum track:@"Launch"];
    }];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    return [[GIDSignIn sharedInstance] handleURL:url sourceApplication:sourceApplication annotation:annotation];
}

- (void)applicationWillResignActive:(UIApplication *)application {

}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {

    [DAOAddressBook setShouldSyncAddressBookChanges:YES];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    if ([deviceToken length] > 0) {
        NSString *token = [[deviceToken description] stringByReplacingOccurrencesOfString:@" " withString:@""];
        token = [token stringByReplacingOccurrencesOfString:@"<" withString:@""];
        token = [token stringByReplacingOccurrencesOfString:@">" withString:@""];
        
        [[NSUserDefaults standardUserDefaults] setObject:token forKey:Token];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        self.serviceQueue = [[ServiceQueue alloc] init];
        NSString *deviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        [self.serviceQueue sendTokenWithDeviceId:deviceId token:token completionBlock:^(id data, ErrorDataModel *error) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:ActivatePushNotification];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }];
    }
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandlerx {
    
    [Leanplum handleNotification:userInfo fetchCompletionHandler:completionHandlerx];
    completionHandlerx(UIBackgroundFetchResultNewData);
}


#pragma mark - Private Methods
- (void)realmMigration {
    
    [RLMRealmConfiguration defaultConfiguration].schemaVersion = 1;
    [RLMRealmConfiguration defaultConfiguration].migrationBlock = ^(RLMMigration *migration, uint64_t oldSchemaVersion) {
        if (oldSchemaVersion < 1) {
            // Nothing to do!
            // Realm will automatically detect new properties and removed properties
            // And will update the schema on disk automatically
        }
    };
    NSLog(@"RLMRealm path: %@", [RLMRealm defaultRealm].path);
}

- (void)setupGoogleSignIn {
    
    [GIDSignIn sharedInstance].clientID = kGoogleClientID;
    [[GIDSignIn sharedInstance] setScopes:@[@"https://www.google.com/m8/feeds/", @"https://mail.google.com/", @"https://apps-apis.google.com/a/feeds/emailsettings/2.0/"]];
}


#pragma mark - Public Methods 
+ (AppDelegate *)sharedDelegate {
    
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)registerNotifications {
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:ActivatePushNotification]) {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
            [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
            [[UIApplication sharedApplication] registerForRemoteNotifications];
        }
        else {
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
        }
    }
}

- (void)setupProfilesSync {
    
    if ([self.serviceProfilesSyncing hasProfile]) {
        [self.serviceProfilesSyncing sync];
    }
}

@end
