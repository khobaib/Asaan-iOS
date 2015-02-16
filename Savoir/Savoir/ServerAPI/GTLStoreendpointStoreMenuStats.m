/* This file was generated by the ServiceGenerator.
 * The ServiceGenerator is Copyright (c) 2015 Google Inc.
 */

//
//  GTLStoreendpointStoreMenuStats.m
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   storeendpoint/v1
// Description:
//   This is an API
// Classes:
//   GTLStoreendpointStoreMenuStats (0 custom class methods, 7 custom properties)

#import "GTLStoreendpointStoreMenuStats.h"

// ----------------------------------------------------------------------------
//
//   GTLStoreendpointStoreMenuStats
//

@implementation GTLStoreendpointStoreMenuStats
@dynamic identifier, menuPOSId, mostFrequentlyOrderedMenuItemPOSId,
         mostLikedMenuItemPOSId, mostRecommendedMenuItemPOSId, storeId,
         subMenuPOSId;

+ (NSDictionary *)propertyToJSONKeyMap {
  NSDictionary *map =
    [NSDictionary dictionaryWithObject:@"id"
                                forKey:@"identifier"];
  return map;
}

@end