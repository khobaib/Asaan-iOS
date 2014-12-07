//
//  DeliveryOrCarryoutViewController.h
//  AsaanImprovedUI
//
//  Created by Nirav Saraiya on 12/5/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTLStoreendpoint.h"
#import "GTLUserendpointUserAddress.h"

@interface DeliveryOrCarryoutViewController : UITableViewController
@property (strong, nonatomic) GTLStoreendpointStore *selectedStore;
@property (nonatomic) int orderType;

+ (int) ORDERTYPE_CARRYOUT;
+ (int) ORDERTYPE_DELIVERY;
@end
