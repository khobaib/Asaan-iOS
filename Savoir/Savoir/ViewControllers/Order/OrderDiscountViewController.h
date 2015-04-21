//
//  OrderDiscountViewController.h
//  Savoir
//
//  Created by NSARAIYA on 1/18/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DiscountReceiver.h"
#import "GTLStoreendpoint.h"

@interface OrderDiscountViewController : UIViewController

@property (weak) id<DiscountReceiver>receiver;
@property (strong, nonatomic) GTLStoreendpointStore *selectedStore;

@end
