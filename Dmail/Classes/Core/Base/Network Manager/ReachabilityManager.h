//
//  ReachabilityManager.h
//  pium
//
//  Created by Anatoli Petrosyants on 12/26/14.
//  Copyright (c) 2014 Armen Mkrtchian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Reachability/Reachability.h>

typedef void (^NetworkReachable)(Reachability * reachability);
typedef void (^NetworkUnreachable)(Reachability * reachability);

extern NSString * const kReachabilityReachable;
extern NSString * const kReachabilityNotReachable;

@interface ReachabilityManager : NSObject

+ (ReachabilityManager *)sharedInstance;

@property (strong, nonatomic) Reachability *reachability;
@property (nonatomic, copy) NetworkReachable   reachableBlock;
@property (nonatomic, copy) NetworkUnreachable unreachableBlock;

@end
