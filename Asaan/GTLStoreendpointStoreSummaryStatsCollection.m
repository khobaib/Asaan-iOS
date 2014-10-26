/* This file was generated by the ServiceGenerator.
 * The ServiceGenerator is Copyright (c) 2014 Google Inc.
 */

//
//  GTLStoreendpointStoreSummaryStatsCollection.m
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   storeendpoint/v1
// Description:
//   This is an API
// Classes:
//   GTLStoreendpointStoreSummaryStatsCollection (0 custom class methods, 1 custom properties)

#import "GTLStoreendpointStoreSummaryStatsCollection.h"

#import "GTLStoreendpointStoreSummaryStats.h"

// ----------------------------------------------------------------------------
//
//   GTLStoreendpointStoreSummaryStatsCollection
//

@implementation GTLStoreendpointStoreSummaryStatsCollection
@dynamic items;

+ (NSDictionary *)arrayPropertyToClassMap {
  NSDictionary *map =
    [NSDictionary dictionaryWithObject:[GTLStoreendpointStoreSummaryStats class]
                                forKey:@"items"];
  return map;
}

@end