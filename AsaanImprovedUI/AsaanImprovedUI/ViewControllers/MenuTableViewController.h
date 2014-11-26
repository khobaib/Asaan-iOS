//
//  MenuTableViewController.h
//  AsaanImprovedUI
//
//  Created by Nirav Saraiya on 11/20/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataReceiver.h"
#import "GTLStoreendpoint.h"

@interface MenuTableViewController : UITableViewController <DataReceiver>
@property (strong, nonatomic) GTLStoreendpointStore *selectedStore;
@end
