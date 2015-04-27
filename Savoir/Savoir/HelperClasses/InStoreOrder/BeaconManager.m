//
//  BeaconManager.m
//  Savoir
//
//  Created by Nirav Saraiya on 4/24/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import "BeaconManager.h"
#import <EstimoteSDK/EstimoteSDK.h>
#import "AppDelegate.h"
#import "InStoreUtils.h"


@interface BeaconManager ()<ESTBeaconManagerDelegate>

// ----------------------------------------------------------
// GETTING STARTED INTERFACE starts here
// ----------------------------------------------------------
@property (strong, nonatomic) ESTBeaconManager *beaconManager;
@property (strong, nonatomic) CLBeaconRegion *beaconRegion;
@property (strong, nonatomic) CLBeacon *beacon;
// ----------------------------------------------------------
// GETTING STARTED INTERFACE ends here
// ----------------------------------------------------------

@end

@implementation BeaconManager

- (id)init
{
    if (self = [super init])
    {
        NSLog(@"beaconManager init");
        self.beaconManager = [[ESTBeaconManager alloc] init];
        [self.beaconManager requestAlwaysAuthorization];
        self.beaconManager.delegate = self;
        NSUUID *beaconUUID = [[NSUUID alloc]initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"];
        self.beaconRegion = [[CLBeaconRegion alloc]
                             initWithProximityUUID:beaconUUID
                             identifier:@"Savoir"];
        
        self.beaconRegion.notifyOnEntry = YES;
        self.beaconRegion.notifyOnExit = YES;
        
        [self.beaconManager startMonitoringForRegion:self.beaconRegion];
    }
    return self;
}

- (void) startBeaconRanging
{
    if ([ESTBeaconManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)
    {
        NSLog(@"beaconManager kCLAuthorizationStatusNotDetermined");
        [self.beaconManager requestAlwaysAuthorization];
        [self.beaconManager startRangingBeaconsInRegion:self.beaconRegion];
    }
    else if([ESTBeaconManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways)
    {
        NSLog(@"beaconManager kCLAuthorizationStatusAuthorizedAlways");
        [self.beaconManager startRangingBeaconsInRegion:self.beaconRegion];
    }
    else if([ESTBeaconManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
        NSLog(@"beaconManager kCLAuthorizationStatusDenied");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Access Denied"
                                                        message:@"You have denied access to location services. Change this in app settings."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        
        [alert show];
    }
    else if([ESTBeaconManager authorizationStatus] == kCLAuthorizationStatusRestricted)
    {
        NSLog(@"beaconManager kCLAuthorizationStatusRestricted");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Not Available"
                                                        message:@"You have no access to location services."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        
        [alert show];
    }
}

/**
 * Tells the delegate that a region monitoring error occurred.
 *
 * @param manager The beacon manager object reporting the event.
 * @param region The region for which the error occurred.
 * @param error An error object describing why monitoring failed.
 */
- (void)beaconManager:(id)manager
monitoringDidFailForRegion:(CLBeaconRegion *)region
            withError:(NSError *)error
{
    NSLog(@"beaconManager monitoringDidFailForRegion error = %@", [error description]);
}

/**
 * Tells the delegate that the user entered the specified region.
 *
 * Because regions are a shared application resource, every active beacon and location manager object delivers this message to its associated delegate. It does not matter which beacon or location manager actually registered the specified region. And if multiple beacon and location managers share a delegate object, that delegate receives the message multiple times.
 *
 *The region object provided may not be the same one that was registered. As a result, you should never perform pointer-level comparisons to determine equality. Instead, use the region's identifier string to determine if your delegate should respond.
 *
 * @param manager The beacon manager object reporting the event.
 * @param region The region that was entered.
 */
- (void)beaconManager:(id)manager
       didEnterRegion:(CLBeaconRegion *)region
{
    NSLog(@"beaconManager didEnterRegion");
//    NotificationUtils *notificationUtils = [[NotificationUtils alloc]init];
//    [notificationUtils scheduleLocalNotificationWithString:@"You have entered the region."];
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Entered Region"
//                                                    message:@"You have entered the region."
//                                                   delegate:nil
//                                          cancelButtonTitle:@"OK"
//                                          otherButtonTitles: nil];
//    
//    [alert show];
    [self startBeaconRanging];
}

/**
 * Tells the delegate that the user left the specified region.
 *
 * Because regions are a shared application resource, every active beacon and location manager object delivers this message to its associated delegate. It does not matter which beacon or location manager actually registered the specified region. And if multiple beacon and location managers share a delegate object, that delegate receives the message multiple times.
 *
 *The region object provided may not be the same one that was registered. As a result, you should never perform pointer-level comparisons to determine equality. Instead, use the region's identifier string to determine if your delegate should respond.
 *
 * @param manager The beacon manager object reporting the event.
 * @param region The region that was exited.
 */
- (void)beaconManager:(id)manager
        didExitRegion:(CLBeaconRegion *)region
{
    NSLog(@"beaconManager didExitRegion %ld", self.beaconRegion.major.longValue);
//    NotificationUtils *notificationUtils = [[NotificationUtils alloc]init];
//    [notificationUtils scheduleLocalNotificationWithString:@"You have exited the region."];

//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Exit Region"
//                                                    message:@"You have exited the region."
//                                                   delegate:nil
//                                          cancelButtonTitle:@"OK"
//                                          otherButtonTitles: nil];
//    
//    [alert show];
    self.beacon = nil;
}

/**
 * Tells the delegate about the state of the specified region.
 *
 * The beacon manager calls this method whenever there is a boundary transition for a region. It calls this method in addition to calling the `<beaconManager:didEnterRegion:>` and `<beaconManager:didExitRegion:>` methods. The beacon manager also calls this method in response to a call to its `<[ESTBeaconManager requestStateForRegion:]>` method, which runs asynchronously.
 *
 * @param manager The beacon manager object reporting the event.
 * @param state The state of the specified region: `CLRegionStateUnknown`, `CLRegionStateInside` or `CLRegionStateOutside`.
 * @param region The region which state was determined.
 */
- (void)beaconManager:(id)manager
    didDetermineState:(CLRegionState)state
            forRegion:(CLBeaconRegion *)region
{
    NSLog(@"beaconManager didDetermineState %ld forRegion %ld", (long)state, region.major.longValue);
}

#pragma mark Ranging Events
///--------------------------------------------------------------------
/// @name Ranging Events
///--------------------------------------------------------------------

/**
 * Tells the delegate that one or more beacons are in range.
 *
 * @param manager The beacon manager object reporting the event.
 * @param beacons An array of `<CLBeacon>` objects representing the beacons currently in range. You can use the information in these objects to determine the range of each beacon and its identifying information.
 * @param region The region that was used to range the beacons.
 */
- (void)beaconManager:(id)manager
      didRangeBeacons:(NSArray *)beacons
             inRegion:(CLBeaconRegion *)region
{
    CLBeacon *nearestBeacon = [beacons firstObject];
    NSLog(@"beaconManager didRangeBeacons %ld", nearestBeacon.major.longValue);
    if (nearestBeacon)
    {
        [self.beaconManager stopRangingBeaconsInRegion:self.beaconRegion];
        self.beacon = nearestBeacon;
        self.beaconRegion = region;
        [InStoreUtils getStoreForBeaconId:125];
    }
}


/**
 * Tells the delegate that a region ranging error occurred.
 *
 * @param manager The beacon manager object reporting the event.
 * @param region The region for which the error occurred.
 * @param error An error object describing why ranging failed.
 */
- (void)beaconManager:(id)manager
rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region
            withError:(NSError *)error
{
    NSLog(@"beaconManager rangingBeaconsDidFailForRegion error = %@", [error description]);
}

@end
