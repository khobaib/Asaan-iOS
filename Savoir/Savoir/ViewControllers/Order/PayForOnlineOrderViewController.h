//
//  PayForOnlineOrderViewController.h
//  Savoir
//
//  Created by Nirav Saraiya on 5/1/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StripePay.h"
#import "GTLStoreendpointStore.h"
#import "GTLStoreendpointPlaceOrderArguments.h"

@interface PayForOnlineOrderViewController : UIViewController<StripeApplePayReceiver>
@property (strong, nonatomic) GTLStoreendpointStore *selectedStore;
@property (nonatomic) double subTotalNoDiscount;
@property (nonatomic) double discountAmount;
@property (nonatomic) double deliveryFee;
@property (nonatomic) double subTotal;
@property (strong, nonatomic) NSString *discountTitle;

@end
