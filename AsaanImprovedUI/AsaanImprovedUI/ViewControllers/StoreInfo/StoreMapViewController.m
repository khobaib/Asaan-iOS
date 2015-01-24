//
//  StoreMapViewController.m
//  AsaanImprovedUI
//
//  Created by Hasan Ibna Akbar on 1/20/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import "StoreMapViewController.h"

#import "GTLStoreendpoint.h"
#import "StoreLocation.h"
#import <MapKit/MapKit.h>

#define METER_DISTANCE  800

@interface StoreMapViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *storeMapView;

// Needed for MapView
- (void)plotStorePosition;

@end

@implementation StoreMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSLog(@"Store Showed %@ : lat - %@, lang - %@", self.selectedStore.name, self.selectedStore.lat, self.selectedStore.lng);
    
    if (self.selectedStore.lat && self.selectedStore.lng) {
        
        // Configure MapView
        CLLocationCoordinate2D zoomLocation;
        zoomLocation.latitude = [self.selectedStore.lat doubleValue];
        zoomLocation.longitude= [self.selectedStore.lng doubleValue];
        
        if (CLLocationCoordinate2DIsValid(zoomLocation)) {
            MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 5*METER_DISTANCE, 5*METER_DISTANCE);
            viewRegion = [self.storeMapView regionThatFits:viewRegion];
            [self.storeMapView setRegion:viewRegion animated:YES];
            [self plotStorePosition];
        }
        else {
            NSLog(@"Store coordinate is invalid");
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // We have to delete annotation from mapView,
    for (id<MKAnnotation> annotation in self.storeMapView.annotations) {
        [self.storeMapView removeAnnotation:annotation];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Private Methods
- (void)plotStorePosition {
    
    for (id<MKAnnotation> annotation in self.storeMapView.annotations) {
        [self.storeMapView removeAnnotation:annotation];
    }
    
    NSNumber *latitude = self.selectedStore.lat;
    NSNumber *longitude = self.selectedStore.lng;
    NSString *storeDescription = self.selectedStore.name;
    NSString *address = self.selectedStore.address;
    
    if ((latitude != NULL) && (longitude != NULL)) {
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = latitude.doubleValue;
        coordinate.longitude = longitude.doubleValue;
        if (CLLocationCoordinate2DIsValid(coordinate)) {
            StoreLocation *annotation = [[StoreLocation alloc] initWithName:storeDescription address:address coordinate:coordinate];
            [self.storeMapView addAnnotation:annotation];
        }
        else {
            NSLog(@"Store coordinate is invalid");
        }
    }
}

#pragma mark - MKMapViewDelegate
- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error
{
    NSLog(@"Error<Loading Map> : %@", error);
}

@end
