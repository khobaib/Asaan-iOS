/* This file was generated by the ServiceGenerator.
 * The ServiceGenerator is Copyright (c) 2015 Google Inc.
 */

//
//  GTLStoreendpointMenusAndMenuItems.m
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   storeendpoint/v1
// Description:
//   This is an API
// Classes:
//   GTLStoreendpointMenusAndMenuItems (0 custom class methods, 2 custom properties)

#import "GTLStoreendpointMenusAndMenuItems.h"

#import "GTLStoreendpointMenuItemAndStats.h"
#import "GTLStoreendpointStoreMenuHierarchy.h"

// ----------------------------------------------------------------------------
//
//   GTLStoreendpointMenusAndMenuItems
//

@implementation GTLStoreendpointMenusAndMenuItems
@dynamic menuItems, menusAndSubmenus;

+ (NSDictionary *)arrayPropertyToClassMap {
  NSDictionary *map =
    [NSDictionary dictionaryWithObjectsAndKeys:
      [GTLStoreendpointMenuItemAndStats class], @"menuItems",
      [GTLStoreendpointStoreMenuHierarchy class], @"menusAndSubmenus",
      nil];
  return map;
}

@end
