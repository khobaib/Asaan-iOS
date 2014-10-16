//
//  ResturantListViewController.h
//  Asaan
//
//  Created by MC MINI on 9/23/14.
//  Copyright (c) 2014 Tech Fiesta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <MapKit/MapKit.h>

@interface ResturantListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,MKMapViewDelegate>{
    NSMutableArray *resturantList;
}

@property IBOutlet MKMapView *mapView;
@property IBOutlet UITableView *tableView;

@end
