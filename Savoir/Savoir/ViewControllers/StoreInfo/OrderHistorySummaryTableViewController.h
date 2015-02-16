//
//  OrderHistorySummaryTableViewController.h
//  Savoir
//
//  Created by Nirav Saraiya on 1/20/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTLStoreendpointStoreOrder.h"

@interface OrderHistorySummaryTableViewController : UITableViewController

@property (nonatomic, strong) GTLStoreendpointStoreOrder *selectedOrder;

@end
