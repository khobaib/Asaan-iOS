//
//  ReviewsSummaryTableViewController.h
//  AsaanImprovedUI
//
//  Created by Nirav Saraiya on 2/5/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataReceiver.h"
#import "GTLStoreendpoint.h"

@interface ReviewsSummaryTableViewController : UITableViewController <DataReceiver>

@property (weak, nonatomic) GTLStoreendpointStoreAndStats *selectedStore;

@end
