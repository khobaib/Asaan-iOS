/* This file was generated by the ServiceGenerator.
 * The ServiceGenerator is Copyright (c) 2015 Google Inc.
 */

//
//  GTLStoreendpointStoreAndStats.h
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   storeendpoint/v1
// Description:
//   This is an API
// Classes:
//   GTLStoreendpointStoreAndStats (0 custom class methods, 2 custom properties)

#if GTL_BUILT_AS_FRAMEWORK
  #import "GTL/GTLObject.h"
#else
  #import "GTLObject.h"
#endif

@class GTLStoreendpointStore;
@class GTLStoreendpointStoreStats;

// ----------------------------------------------------------------------------
//
//   GTLStoreendpointStoreAndStats
//

@interface GTLStoreendpointStoreAndStats : GTLObject
@property (retain) GTLStoreendpointStoreStats *stats;
@property (retain) GTLStoreendpointStore *store;
@end
