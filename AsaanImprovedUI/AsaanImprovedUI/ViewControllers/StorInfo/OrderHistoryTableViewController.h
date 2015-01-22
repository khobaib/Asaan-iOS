//
//  OrderHistoryTableViewController.h
//  AsaanImprovedUI
//
//  Created by Nirav Saraiya on 1/16/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTLStoreendpoint.h"
#import "DataReceiver.h"

@interface OrderHistoryTableViewController : UITableViewController <DataReceiver>

@property (nonatomic, strong) GTLStoreendpointStore *selectedStore;

@end
