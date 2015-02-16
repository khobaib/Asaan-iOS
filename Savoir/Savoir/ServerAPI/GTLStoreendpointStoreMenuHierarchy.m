/* This file was generated by the ServiceGenerator.
 * The ServiceGenerator is Copyright (c) 2015 Google Inc.
 */

//
//  GTLStoreendpointStoreMenuHierarchy.m
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   storeendpoint/v1
// Description:
//   This is an API
// Classes:
//   GTLStoreendpointStoreMenuHierarchy (0 custom class methods, 13 custom properties)

#import "GTLStoreendpointStoreMenuHierarchy.h"

// ----------------------------------------------------------------------------
//
//   GTLStoreendpointStoreMenuHierarchy
//

@implementation GTLStoreendpointStoreMenuHierarchy
@dynamic active, createdDate, hours, identifier, level, menuItemCount,
         menuItemPosition, menuPOSId, menuType, modifiedDate, name, storeId,
         subMenuPOSId;

+ (NSDictionary *)propertyToJSONKeyMap {
  NSDictionary *map =
    [NSDictionary dictionaryWithObject:@"id"
                                forKey:@"identifier"];
  return map;
}

@end