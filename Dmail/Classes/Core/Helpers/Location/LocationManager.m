//
//  LocationManager.m
//  pium
//
//  Created by Anatoli Petrosyants on 12/3/14.
//  Copyright (c) 2014 Armen Mkrtchian. All rights reserved.
//

#import "LocationManager.h"

NSString *const kRegionMonitoringNotification = @"kRegionMonitoringNotification";
NSInteger const kRegionMonitoringAccuracy = 500;
NSInteger const kLocationAccuracy = 500;

@interface LocationManager ()

@end

@implementation LocationManager

// Get the shared instance and create it using GCD.
+ (LocationManager *)sharedInstance
{
    static LocationManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    if (self = [super init]) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
    }
    return self;
}

#pragma mark -- Public methods --

/*!
 * @function startUpdatingLocation
 *
 * @discussion:
 * Start updating location.
 */
- (void)startUpdatingLocation
{
    if (self.locationManager) {
        [self.locationManager startUpdatingLocation];
    }
}

/*!
 * @function stopUpdatingLocation
 *
 * @discussion:
 * Stop updating location.
 */
- (void)stopUpdatingLocation
{
    if (self.locationManager) {
        [self.locationManager stopUpdatingLocation];
    }
}

///*!
// * @function registerRegionMonitoring
// *
// * @discussion:
// * Register region monitoring.
// */
//- (void)registerRegionMonitoring {
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(enterRegionHandler:)
//                                                 name:kRegionMonitoringNotification
//                                               object:nil];
//}

/*!
 * @function startMonitoringWithCoordinate: identifier:
 *
 * @param coordintae - region coordintae
 * @param identifier - region identifier
 *
 * @discussion:
 * Start monitoring region.
 */
- (void)startMonitoringWithCoordinate:(CLLocationCoordinate2D)coordintae identifier:(NSString *)identifier {
    if (self.locationManager) {
        CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:coordintae
                                                                     radius:kRegionMonitoringAccuracy
                                                                 identifier:identifier];
        
        [self.locationManager startMonitoringForRegion:region];
    }
    
}

/*!
 * @function stoptMonitoringForIdentifier:
 *
 * @param identifier - region identifier
 *
 * @discussion:
 * Stop monitoring region by identifier.
 */
- (void)stoptMonitoringForIdentifier:(NSString *)identifier {
    if (self.locationManager) {
        for (CLRegion *region in [self.locationManager monitoredRegions]) {
            if ([region.identifier isEqual:identifier]) {
                // NSLog(@"Stop region: %@", region.identifier);
                [self.locationManager stopMonitoringForRegion:region];
            }
        }
    }
}

/*!
 * @function stopMonitoringAllRegions
 *
 * @discussion:
 * Stop monitoring all regions.
 */
- (void)stopMonitoringAllRegions {
    // NSLog(@"regions count %lu", (unsigned long)[self.locationManager monitoredRegions].count);
    
    // stop monitoring for any and all current regions
    if (self.locationManager) {
        for (CLRegion *region in [[self.locationManager monitoredRegions] allObjects]) {
            // [self.locationManager stopMonitoringForRegion:region];
            NSLog(@"Region: %@", region);
        }
    }
    
    // NSLog(@"Currently monitoring regions count %lu", (unsigned long)[self.locationManager monitoredRegions].count);
}

#pragma mark -- CLLocationManagerDelegate --

- (void)locationManager:(CLLocationManager *)manager
didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    // NSLog(@"locationManager: didChangeAuthorizationStatus:");
    
    if (status == kCLAuthorizationStatusDenied) {
        // permission denied
        [self setAuthorizationStatusGranted:NO];
    } else {
        // check.
        // status == kCLAuthorizationStatusAuthorizedAlways
        /*
         if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)] &&
         status == kCLAuthorizationStatusAuthorizedWhenInUse)
         {
         // Alert: you need authorization status always.
         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Attantion"
         message:@"Change to always"
         delegate:nil
         cancelButtonTitle:@"Cancel"
         otherButtonTitles:nil];
         [alertView show];
         }
         */
        
        // status == kCLAuthorizationStatusAuthorized
        
        // kCLAuthorizationStatusAuthorized --> iOS 7
        
        // permission granted
        [self setAuthorizationStatusGranted:YES];
    }
    
    if ([self.delegate respondsToSelector:@selector(didAuthorizationStatusGranted:)]) {
        [self.delegate didAuthorizationStatusGranted:self.isAuthorizationStatusGranted];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    // NSLog(@"locations: %@", [locations lastObject]);
    
    self.currentLocation = [locations lastObject];
    CLLocationAccuracy accuracy = self.currentLocation.horizontalAccuracy;
    
    if (accuracy <= kLocationAccuracy) {
        [self.locationManager stopUpdatingLocation];
        
        if ([self isResultsLoaded])
            return;
        
        [self setResultsLoaded:YES];
        
        if ([self.delegate respondsToSelector:@selector(didUpdatingLocation:)]) {
            [self.delegate didUpdatingLocation:_currentLocation];
        }
    }
}


-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    CLLocation *lastLocation = [manager location];    
    if(lastLocation) {
        // this makes sure the change notification happens on the MAIN THREAD
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kRegionMonitoringNotification
                                                                object:self
                                                              userInfo:@{@"identifier":region.identifier}];
        });
        
        /*
        if ([self.delegate respondsToSelector:@selector(didEnterRegionWithIdentifier:)]) {
            [self.delegate didEnterRegionWithIdentifier:region.identifier];            
        }
        */
    }
    
    /*
    BOOL doesItContainMyPoint;
    
    if(lastLocation == nil) {
        doesItContainMyPoint = NO;
    } else {
        CLLocationCoordinate2D theLocationCoordinate = lastLocation.coordinate;
        CLCircularRegion * theRegion = (CLCircularRegion*)region;
        doesItContainMyPoint = [theRegion containsCoordinate:theLocationCoordinate];
    }
    
    if(doesItContainMyPoint) {
        
        if ([self.delegate respondsToSelector:@selector(didEnterRegionWithIdentifier:)]) {
            [self.delegate didEnterRegionWithIdentifier:region.identifier];
        }
    }
    */
}

- (void)locationManager:(CLLocationManager *)manager
          didExitRegion:(CLRegion *)region
{
    // No need to handle.
    
}

#pragma mark -- Private methods --

//- (void)enterRegionHandler:(NSNotification *)notification {
//    
//    NSLog(@"notification.userInfo: %@", notification.userInfo);
//    
//    if(self.regionMonitoringBlock) {
//        self.regionMonitoringBlock(notification.userInfo[@"identifier"]);
//    }
//}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    // NSLog(@"%@", [error description]);
}

@end

