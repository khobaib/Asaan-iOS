/* This file was generated by the ServiceGenerator.
 * The ServiceGenerator is Copyright (c) 2015 Google Inc.
 */

//
//  GTLStoreendpointMenuItemAndStatsCollection.m
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   storeendpoint/v1
// Description:
//   This is an API
// Classes:
//   GTLStoreendpointMenuItemAndStatsCollection (0 custom class methods, 1 custom properties)

#import "GTLStoreendpointMenuItemAndStatsCollection.h"

#import "GTLStoreendpointMenuItemAndStats.h"

// ----------------------------------------------------------------------------
//
//   GTLStoreendpointMenuItemAndStatsCollection
//

@implementation GTLStoreendpointMenuItemAndStatsCollection
@dynamic items;

+ (NSDictionary *)arrayPropertyToClassMap {
  NSDictionary *map =
    [NSDictionary dictionaryWithObject:[GTLStoreendpointMenuItemAndStats class]
                                forKey:@"items"];
  return map;
}

@end
