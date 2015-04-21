//
//  DiscountReceiver.h
//  Savoir
//
//  Created by Nirav Saraiya on 4/17/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTLStoreendpointStoreDiscount.h"

@protocol DiscountReceiver <NSObject>

- (void)selectedDiscount:(GTLStoreendpointStoreDiscount *)discount;

@end
