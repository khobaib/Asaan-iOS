//
//  ReserveOrWaitlistTableViewController.h
//  AsaanImprovedUI
//
//  Created by Nirav Saraiya on 2/9/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTLStoreendpoint.h"

@interface ReserveOrWaitlistTableViewController : UITableViewController

@property (strong, nonatomic) GTLStoreendpointStore *selectedStore;

@end
