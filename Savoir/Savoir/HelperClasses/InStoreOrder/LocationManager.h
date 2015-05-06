//
//  LocationManager.h
//  Savoir
//
//  Created by Nirav Saraiya on 5/5/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "LocationReceiver.h"

@interface LocationManager : NSObject
@property (strong, nonatomic) CLLocation *lastLocation;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSError *lastError;
@property (nonatomic) NSUInteger distanceFromLastLocation;
@property (strong, nonatomic) NSDate *askedForLocationAccessPermission;
@property (weak, nonatomic) id <LocationReceiver> locationReceiver;

- (Boolean)canAccessLocationServices;
- (Boolean)shouldAskForLocationAccessPermission;
- (void)requestAuthorization;
- (void)startStandardUpdates:(id <LocationReceiver>)receiver;

@end
