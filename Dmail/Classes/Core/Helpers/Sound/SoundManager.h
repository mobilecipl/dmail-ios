//
//  SoundManager.h
//  pium
//
//  Created by Anatoli Petrosyants on 2/1/15.
//  Copyright (c) 2015 Armen Mkrtchian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface SoundManager : NSObject

+ (SoundManager *)sharedInstance;

- (void)createNewPingNotificationSound;
- (void)createInboxReloadSound;
- (void)playPushNotificationSound;
- (void)playInboxReloadSound;

@end
