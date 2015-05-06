//
//  LocationManager.m
//  Savoir
//
//  Created by Nirav Saraiya on 5/5/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import "LocationManager.h"
#import "AppDelegate.h"

@interface LocationManager() <CLLocationManagerDelegate>

@end

@implementation LocationManager

- (id)init
{
    if (self = [super init])
    {
        self.locationAccessPermissionDenied = YES;
        self.askedForLocationAccessPermission = 0;
        self.locationManager = [[CLLocationManager alloc] init];
        self.lastLocation = [[CLLocation alloc]initWithLatitude:41.772193 longitude:-88.15099];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        self.locationManager.distanceFilter = 50; // meters
    }
    return self;
}

#pragma mark - Location

- (Boolean)canAccessLocationServices
{
    if ([CLLocationManager locationServicesEnabled] == YES && ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse))
        return YES;

    return NO;
}

- (Boolean)shouldAskForLocationAccessPermission
{
    if ([CLLocationManager locationServicesEnabled] == YES && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)
    {
        if (self.askedForLocationAccessPermission == nil || [[NSDate dateWithTimeIntervalSinceNow:86400] compare:self.askedForLocationAccessPermission] == NSOrderedDescending)
            return YES;
    }
    
    return NO;
}

- (void)requestAuthorization
{
    [self.locationManager requestAlwaysAuthorization];
}

- (void)startStandardUpdates:(id <LocationReceiver>)receiver
{
    self.locationReceiver = receiver;
    
    if ([self canAccessLocationServices] == YES)
        [self.locationManager startUpdatingLocation];
    else
        [receiver locationChanged];
}

- (void)stopStandardUpdates
{
    [self.locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [manager stopUpdatingLocation];
//    NSString *msg = [NSString stringWithFormat:@"Location update failed - error: %@", [error userInfo][@"error"]];
//    [self.view makeToast:msg];
//    NSLog(@"Location update failed - error: %@", [error userInfo][@"error"]);
    self.lastError = error;
    if (self.lastLocation == nil)
    {
        self.lastLocation = [[CLLocation alloc]initWithLatitude:41.772193 longitude:-88.15099];
    }
    [self.locationReceiver locationChanged];
}

// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [manager stopUpdatingLocation];
    self.lastError = nil;
    self.lastLocation = [locations lastObject];
    [self.locationReceiver locationChanged];
}

@end
