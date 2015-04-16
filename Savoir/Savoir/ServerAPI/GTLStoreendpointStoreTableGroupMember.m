/* This file was generated by the ServiceGenerator.
 * The ServiceGenerator is Copyright (c) 2015 Google Inc.
 */

//
//  GTLStoreendpointStoreTableGroupMember.m
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   storeendpoint/v1
// Description:
//   This is an API
// Classes:
//   GTLStoreendpointStoreTableGroupMember (0 custom class methods, 21 custom properties)

#import "GTLStoreendpointStoreTableGroupMember.h"

// ----------------------------------------------------------------------------
//
//   GTLStoreendpointStoreTableGroupMember
//

@implementation GTLStoreendpointStoreTableGroupMember
@dynamic createdDate, finalTotal, firstName, identifier, lastName, modifiedDate,
         orderId, paidItems, payingFor, payingUserId, paymentChargeId,
         paymentInvoice, paymentReceiptNumber, paymentType, profilePhotoUrl,
         status, storeTableGroupId, subtotal, tax, tip, userId;

+ (NSDictionary *)propertyToJSONKeyMap {
  NSDictionary *map =
    [NSDictionary dictionaryWithObject:@"id"
                                forKey:@"identifier"];
  return map;
}

@end
