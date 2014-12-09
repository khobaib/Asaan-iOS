/* This file was generated by the ServiceGenerator.
 * The ServiceGenerator is Copyright (c) 2014 Google Inc.
 */

//
//  GTLStoreendpointStoreMenuItemModifierGroup.m
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   storeendpoint/v1
// Description:
//   This is an API
// Classes:
//   GTLStoreendpointStoreMenuItemModifierGroup (0 custom class methods, 10 custom properties)

#import "GTLStoreendpointStoreMenuItemModifierGroup.h"

// ----------------------------------------------------------------------------
//
//   GTLStoreendpointStoreMenuItemModifierGroup
//

@implementation GTLStoreendpointStoreMenuItemModifierGroup
@dynamic createdDate, identifier, menuItemPOSId, modifiedDate,
         modifierGroupLongDescription, modifierGroupMaximum,
         modifierGroupMinimum, modifierGroupPOSId,
         modifierGroupShortDescription, storeId;

+ (NSDictionary *)propertyToJSONKeyMap {
  NSDictionary *map =
    [NSDictionary dictionaryWithObject:@"id"
                                forKey:@"identifier"];
  return map;
}

@end
