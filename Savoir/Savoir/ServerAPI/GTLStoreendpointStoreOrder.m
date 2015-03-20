/* This file was generated by the ServiceGenerator.
 * The ServiceGenerator is Copyright (c) 2015 Google Inc.
 */

//
//  GTLStoreendpointStoreOrder.m
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   storeendpoint/v1
// Description:
//   This is an API
// Classes:
//   GTLStoreendpointStoreOrder (0 custom class methods, 29 custom properties)

#import "GTLStoreendpointStoreOrder.h"

// ----------------------------------------------------------------------------
//
//   GTLStoreendpointStoreOrder
//

@implementation GTLStoreendpointStoreOrder
@dynamic closeDate, createdDate, deliveryFee, discount, discountDescription,
         employeeName, employeePOSId, faxId, finalTotal, guestCount, identifier,
         modifiedDate, note, orderDetails, orderHTML, orderMode, orderStatus,
         orderTotal, paymentChargeId, paymentInvoice, paymentReceiptNumber,
         poscheckId, posintCheckId, serviceCharge, storeId, storeName, subTotal,
         tableNumber, tax;

+ (NSDictionary *)propertyToJSONKeyMap {
  NSDictionary *map =
    [NSDictionary dictionaryWithObject:@"id"
                                forKey:@"identifier"];
  return map;
}

@end
