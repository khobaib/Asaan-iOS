//
//  XMLPOSOrder.h
//  Savoir
//
//  Created by Nirav Saraiya on 3/19/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OnlineOrderDetails.h"
#import "OrderedDictionary.h"

@interface XMLPOSOrder : NSObject

+ (NSString *)buildPOSOrder:(OnlineOrderDetails *)orderInProgress gratuity:(double)gratuity;

+ (NSString *)buildPOSResponseXML:(OnlineOrderDetails *)orderInProgress checkId:(long)checkId gratuity:(double)gratuity subTotal:(double)subTotal deliveryFee:(double)deliveryFee taxAmount:(double)taxAmount finalAmount:(double)finalAmount guestCount:(NSUInteger)guestCount tableNumber:(NSUInteger)tableNumber;

+ (NSString *)buildPOSResponseXMLByAddingNewItems:(OnlineOrderDetails *)orderInProgress ToOrderString:(NSString *)XMLOrderStr;

+ (NSString *)buildPOSResponseXMLByRemovingItem:(int)entryId FromOrderString:(NSString *)XMLOrderStr;

+ (NSString *) replaceValuesInOrderString:(NSString *)XMLOrderStr gratuity:(double)gratuity subTotal:(double)subTotal deliveryFee:(double)deliveryFee taxAmount:(double)taxAmount finalAmount:(double)finalAmount checkId:(long)checkId guestCount:(NSUInteger)guestCount tableNumber:(NSUInteger)tableNumber;

+ (NSString *)replaceDiscountIdWith:(long long)discountId Description:(NSString *)desc IsPercent:(int) discountIsPercent Value:(int) discountValue Amount:(double)newAmount InOrderString:(NSString *)XMLOrderStr;

+ (MutableOrderedDictionary *)getCheckItemsFromXML:(NSString *)strPOSCheckDetails;
+ (NSMutableArray *) parseOrderDetails:(NSString *)orderDetails;

+ (GTLStoreendpointStoreDiscount *)getDiscountFromXML:(NSString *)strPOSCheckDetails;

@end
