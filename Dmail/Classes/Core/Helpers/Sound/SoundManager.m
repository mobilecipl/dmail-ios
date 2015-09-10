//
//  SoundManager.m
//  pium
//
//  Created by Anatoli Petrosyants on 2/1/15.
//  Copyright (c) 2015 Armen Mkrtchian. All rights reserved.
//

#import "SoundManager.h"

@interface SoundManager ()

@property SystemSoundID newPingNotificationSound;
@property SystemSoundID inboxReloadSound;

@end

@implementation SoundManager

// Get the shared instance and create it using GCD.
+ (SoundManager *)sharedInstance {
    
    static SoundManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {

    }
    return self;
}

//- (void)createNewPingNotificationSound {
//    NSString *newPingNotificationSoundName = [[NSBundle mainBundle] pathForResource:kNewPingPushNotificationSound
//                                                                             ofType:@"aif"];
//    NSURL *newPingNotificationSoundURL = [NSURL fileURLWithPath:newPingNotificationSoundName];
//    AudioServicesCreateSystemSoundID((__bridge CFURLRef)newPingNotificationSoundURL, &_newPingNotificationSound);
//}
//
//- (void)createInboxReloadSound {
//    NSString *inboxReloadSoundName = [[NSBundle mainBundle] pathForResource:kInboxReloadSound
//                                                                     ofType:@"aif"];
//    NSURL *inboxReloadSoundURL = [NSURL fileURLWithPath:inboxReloadSoundName];
//    AudioServicesCreateSystemSoundID((__bridge CFURLRef)inboxReloadSoundURL, &_inboxReloadSound);
//}

- (void)playPushNotificationSound {
    if (self.newPingNotificationSound) {
        AudioServicesPlaySystemSound(self.newPingNotificationSound);
    }
}

- (void)playInboxReloadSound {
    if (self.inboxReloadSound) {
        AudioServicesPlaySystemSound(self.inboxReloadSound);
    }
}

- (void) dealloc {
    AudioServicesDisposeSystemSoundID(self.newPingNotificationSound);
}

@end
