//
//  LocationManager.h
//  pium
//
//  Created by Anatoli Petrosyants on 12/3/14.
//  Copyright (c) 2014 Armen Mkrtchian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

extern NSString *const kRegionMonitoringNotification;
extern NSInteger const kRegionMonitoringAccuracy;
extern NSInteger const kLocationAccuracy;

@protocol LocationManagerDelegate <NSObject>

@optional
- (void)didUpdatingLocation:(CLLocation *)location;
- (void)didAuthorizationStatusGranted:(BOOL)status;
- (void)didEnterRegionWithIdentifier:(NSString *)identifier;

@end

//@class LocationManager;

//typedef void (^EnterRegionBlock)(NSString *identifier);

@interface LocationManager : NSObject <CLLocationManagerDelegate>

@property (weak, nonatomic) id <LocationManagerDelegate> delegate;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation        *currentLocation;

@property (nonatomic, getter = isAuthorizationStatusGranted) BOOL authorizationStatusGranted;
@property (nonatomic, getter = isResultsLoaded) BOOL resultsLoaded;

//@property (nonatomic, copy) EnterRegionBlock regionMonitoringBlock;

+ (LocationManager *)sharedInstance;

- (void)startUpdatingLocation;
- (void)stopUpdatingLocation;

//- (void)registerRegionMonitoring;
- (void)startMonitoringWithCoordinate:(CLLocationCoordinate2D)coordintae identifier:(NSString *)identifier;
- (void)stoptMonitoringForIdentifier:(NSString *)identifier;
- (void)stopMonitoringAllRegions;

@end
