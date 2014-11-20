/* This file was generated by the ServiceGenerator.
 * The ServiceGenerator is Copyright (c) 2014 Google Inc.
 */

//
//  GTLStoreendpointStoreStatsCollection.h
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   storeendpoint/v1
// Description:
//   This is an API
// Classes:
//   GTLStoreendpointStoreStatsCollection (0 custom class methods, 1 custom properties)

#if GTL_BUILT_AS_FRAMEWORK
  #import "GTL/GTLObject.h"
#else
  #import "GTLObject.h"
#endif

@class GTLStoreendpointStoreStats;

// ----------------------------------------------------------------------------
//
//   GTLStoreendpointStoreStatsCollection
//

// This class supports NSFastEnumeration over its "items" property. It also
// supports -itemAtIndex: to retrieve individual objects from "items".

@interface GTLStoreendpointStoreStatsCollection : GTLCollectionObject
@property (retain) NSArray *items;  // of GTLStoreendpointStoreStats
@end
