//
//  OrderTimeTableViewController.h
//  Savoir
//
//  Created by Nirav Saraiya on 4/28/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTLStoreendpoint.h"

@interface OrderTimeTableViewController : UITableViewController
@property (strong, nonatomic) GTLStoreendpointStore *selectedStore;
@property (nonatomic) int orderType;

@end
