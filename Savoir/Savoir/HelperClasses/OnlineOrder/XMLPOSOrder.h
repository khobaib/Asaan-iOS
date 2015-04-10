//
//  XMLPOSOrder.h
//  Savoir
//
//  Created by Nirav Saraiya on 3/19/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OnlineOrderDetails.h"

@interface XMLPOSOrder : NSObject

+ (NSString *)buildPOSOrder:(OnlineOrderDetails *)orderInProgress gratuity:(double)gratuity;

+ (NSString *)buildPOSResponseXML:(OnlineOrderDetails *)orderInProgress gratuity:(double)gratuity discountTitle:(NSString *)discountTitle discountAmount:(double)discountAmount subTotal:(double)subTotal deliveryFee:(double)deliveryFee taxAmount:(double)taxAmount finalAmount:(double)finalAmount guestCount:(NSUInteger)guestCount tableNumber:(NSUInteger)tableNumber;

+ (NSString *)buildPOSResponseXMLByAddingNewItems:(OnlineOrderDetails *)orderInProgress ToOrderString:(NSString *)XMLOrderStr;
+ (NSString *)buildPOSResponseXMLByRemovingItem:(int)entryId FromOrderString:(NSString *)XMLOrderStr;

@end
