/* This file was generated by the ServiceGenerator.
 * The ServiceGenerator is Copyright (c) 2015 Google Inc.
 */

//
//  GTLStoreendpointStoreMenuItemModifier.m
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   storeendpoint/v1
// Description:
//   This is an API
// Classes:
//   GTLStoreendpointStoreMenuItemModifier (0 custom class methods, 10 custom properties)

#import "GTLStoreendpointStoreMenuItemModifier.h"

// ----------------------------------------------------------------------------
//
//   GTLStoreendpointStoreMenuItemModifier
//

@implementation GTLStoreendpointStoreMenuItemModifier
@dynamic createdDate, identifier, longDescription, modifiedDate,
         modifierGroupPOSId, modifierPOSId, price, shortDescription, storeId,
         weighting;

+ (NSDictionary *)propertyToJSONKeyMap {
  NSDictionary *map =
    [NSDictionary dictionaryWithObject:@"id"
                                forKey:@"identifier"];
  return map;
}

@end
