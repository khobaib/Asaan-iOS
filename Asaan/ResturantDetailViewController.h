//
//  ResturantDetailViewController.h
//  Asaan
//
//  Created by MC MINI on 9/23/14.
//  Copyright (c) 2014 Tech Fiesta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "GTLStoreendpoint.h"
#import "Store.h"
#import "DataCommunicator.h"
#import "DatabaseHelper.h"


@interface ResturantDetailViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>{

    BOOL isReview;
}

@property IBOutlet UIView *containerView;
@property IBOutlet UITableView *tableView;
@property IBOutlet UISegmentedControl *segment;

@property IBOutlet UILabel *addressLable;
@property IBOutlet UILabel *phoneNoLable;
@property IBOutlet MKMapView *mapView;



@property GTLStoreendpointStore *store;


@end
