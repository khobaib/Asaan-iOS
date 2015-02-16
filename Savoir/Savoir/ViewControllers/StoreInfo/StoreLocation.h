//
//  StoreLocation.h
//  testAutolayout
//
//  Created by Hasan Ibna Akbar on 12/28/13.
//  Copyright (c) 2013 Hasan Ibna Akbar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface StoreLocation : NSObject <MKAnnotation>

- (id)initWithName:(NSString*)name address:(NSString*)address coordinate:(CLLocationCoordinate2D)coordinate;
- (MKMapItem*)mapItem;

@end
