//
//  DeliveryOrCarryoutViewController.h
//  Savoir
//
//  Created by Nirav Saraiya on 12/5/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTLStoreendpoint.h"

@interface DeliveryOrCarryoutViewController : UITableViewController
@property (strong, nonatomic) GTLStoreendpointStore *selectedStore;
@property (nonatomic) int orderType;
@property (nonatomic) Boolean bCalledFromStoreList;

+ (int) ORDERTYPE_CARRYOUT;
+ (int) ORDERTYPE_DELIVERY;
@end
