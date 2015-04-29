//
//  OrderTypeTableViewController.h
//  Savoir
//
//  Created by Nirav Saraiya on 4/28/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTLStoreendpoint.h"

@interface OrderTypeTableViewController : UITableViewController

@property (strong, nonatomic) GTLStoreendpointStore *selectedStore;
@property (nonatomic) int orderType;

+ (int) ORDERTYPE_CARRYOUT;
+ (int) ORDERTYPE_DELIVERY;
+ (int) ORDERTYPE_PREVISIT;
+ (int) ORDERTYPE_DININGIN;

@end
