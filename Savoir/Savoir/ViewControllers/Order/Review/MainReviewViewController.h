//
//  MainReviewViewController.h
//  Savoir
//
//  Created by Nirav Saraiya on 1/23/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTLStoreendpointStoreOrder.h"
#import "GTLStoreendpointOrderReviewAndItemReviews.h"
#import "BaseViewController.h"

@interface MainReviewViewController : BaseViewController
@property (nonatomic, strong) GTLStoreendpointStoreOrder *selectedOrder;
@property (strong, nonatomic) GTLStoreendpointOrderReviewAndItemReviews *reviewAndItems;
@property (nonatomic) Boolean presentedFromNotification;
@end
