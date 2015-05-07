//
//  OrderSummaryViewController.h
//  Savoir
//
//  Created by Nirav Saraiya on 12/7/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StripePay.h"
#import "GTLStoreendpoint.h"

@interface OrderSummaryViewController : UIViewController <StripeApplePayReceiver>
@property (strong, nonatomic) GTLStoreendpointStore *selectedStore;

@end
