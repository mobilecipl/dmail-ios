//
//  ReachabilityManager.m
//  pium
//
//  Created by Anatoli Petrosyants on 12/26/14.
//  Copyright (c) 2014 Armen Mkrtchian. All rights reserved.
//

#import "ReachabilityManager.h"

NSString * const kReachabilityReachable = @"kReachabilityReachable";
NSString * const kReachabilityNotReachable = @"kReachabilityNotReachable";

@implementation ReachabilityManager

// Get the shared instance and create it using GCD.
+ (ReachabilityManager *)sharedInstance
{
    static ReachabilityManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // Create an instance of reachability
        self.reachability = [Reachability reachabilityForInternetConnection];
        self.reachability.reachableOnWWAN = YES;
        // Listen for changes
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reachabilityChanged:)
                                                     name:kReachabilityChangedNotification
                                                   object:nil];
        
        // Start notifications
        [self.reachability startNotifier];
    }
    return self;
}

// called after network status changes
- (void)reachabilityChanged:(NSNotification *)notification {
    NetworkStatus internetStatus = [self.reachability currentReachabilityStatus];
    
    // Listen for changes
    switch (internetStatus) {
        case NotReachable: {
            NSLog(@"The internet is not working.");
            if(self.unreachableBlock) {
                self.unreachableBlock(self.reachability);
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kReachabilityNotReachable object:self];
            break;
        }
        case ReachableViaWiFi: {
            NSLog(@"The internet is working WiFi");
            if(self.reachableBlock) {
                self.reachableBlock(self.reachability);
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kReachabilityReachable object:self];
            break;
        }
        case ReachableViaWWAN: {
            NSLog(@"The internet is working via WWAN.");
            [[NSNotificationCenter defaultCenter] postNotificationName:kReachabilityReachable object:self];
            break;
        }
    }
}


@end
