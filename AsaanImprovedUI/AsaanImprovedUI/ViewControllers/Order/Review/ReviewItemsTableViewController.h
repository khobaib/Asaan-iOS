//
//  ReviewItemsTableViewController.h
//  AsaanImprovedUI
//
//  Created by Nirav Saraiya on 1/23/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTLStoreendpointStoreOrder.h"
#import "GTLStoreendpointOrderReviewAndItemReviews.h"

@interface ReviewItemsTableViewController : UITableViewController
@property (nonatomic, strong) GTLStoreendpointStoreOrder *selectedOrder;
@property (strong, nonatomic) GTLStoreendpointOrderReviewAndItemReviews *reviewAndItems;
@end
