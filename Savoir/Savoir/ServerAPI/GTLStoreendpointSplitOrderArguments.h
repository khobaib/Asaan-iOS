/* This file was generated by the ServiceGenerator.
 * The ServiceGenerator is Copyright (c) 2015 Google Inc.
 */

//
//  GTLStoreendpointSplitOrderArguments.h
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   storeendpoint/v1
// Description:
//   This is an API
// Classes:
//   GTLStoreendpointSplitOrderArguments (0 custom class methods, 10 custom properties)

#if GTL_BUILT_AS_FRAMEWORK
  #import "GTL/GTLObject.h"
#else
  #import "GTLObject.h"
#endif

@class GTLStoreendpointStoreOrder;
@class GTLStoreendpointStoreTableGroup;
@class GTLStoreendpointStoreTableGroupMember;

// ----------------------------------------------------------------------------
//
//   GTLStoreendpointSplitOrderArguments
//

@interface GTLStoreendpointSplitOrderArguments : GTLObject
@property (copy) NSString *cardid;
@property (copy) NSString *customerId;
@property (retain) NSNumber *gratuityPercent;  // longLongValue
@property (retain) GTLStoreendpointStoreTableGroupMember *memberMe;
@property (retain) GTLStoreendpointStoreOrder *order;
@property (retain) NSArray *paidMembers;  // of GTLStoreendpointStoreTableGroupMember
@property (retain) NSNumber *paymentType;  // intValue
@property (retain) GTLStoreendpointStoreTableGroup *storeTableGroup;
@property (retain) NSNumber *taxPercent;  // longLongValue
@property (copy) NSString *token;
@end
