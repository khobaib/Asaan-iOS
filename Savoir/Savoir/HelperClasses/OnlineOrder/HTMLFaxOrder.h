//
//  HTMLFaxOrder.h
//  Savoir
//
//  Created by Nirav Saraiya on 3/19/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OnlineOrderDetails.h"

@interface HTMLFaxOrder : NSObject

+ (NSString *)buildHTMLOrder:(OnlineOrderDetails *)orderInProgress gratuity:(double)gratuity discountTitle:(NSString *)discountTitle discountAmount:(double)discountAmount subTotal:(double)subTotal deliveryFee:(double)deliveryFee taxAmount:(double)taxAmount finalAmount:(double)finalAmount orderEstTime:(NSString *)orderEstTime;
@end
