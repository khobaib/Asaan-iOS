/* This file was generated by the ServiceGenerator.
 * The ServiceGenerator is Copyright (c) 2015 Google Inc.
 */

//
//  GTLStoreendpointStoreOrderAndTeamDetails.h
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   storeendpoint/v1
// Description:
//   This is an API
// Classes:
//   GTLStoreendpointStoreOrderAndTeamDetails (0 custom class methods, 5 custom properties)

#if GTL_BUILT_AS_FRAMEWORK
  #import "GTL/GTLObject.h"
#else
  #import "GTLObject.h"
#endif

@class GTLStoreendpointStore;
@class GTLStoreendpointStoreOrder;
@class GTLStoreendpointStoreTableGroup;
@class GTLStoreendpointStoreTableGroupMember;

// ----------------------------------------------------------------------------
//
//   GTLStoreendpointStoreOrderAndTeamDetails
//

@interface GTLStoreendpointStoreOrderAndTeamDetails : GTLObject
@property (retain) GTLStoreendpointStoreTableGroupMember *memberMe;
@property (retain) NSArray *members;  // of GTLStoreendpointStoreTableGroupMember
@property (retain) GTLStoreendpointStoreOrder *order;
@property (retain) GTLStoreendpointStore *store;
@property (retain) GTLStoreendpointStoreTableGroup *storeTableGroup;
@end
