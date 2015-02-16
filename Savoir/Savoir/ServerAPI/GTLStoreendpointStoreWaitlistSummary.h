/* This file was generated by the ServiceGenerator.
 * The ServiceGenerator is Copyright (c) 2015 Google Inc.
 */

//
//  GTLStoreendpointStoreWaitlistSummary.h
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   storeendpoint/v1
// Description:
//   This is an API
// Classes:
//   GTLStoreendpointStoreWaitlistSummary (0 custom class methods, 9 custom properties)

#if GTL_BUILT_AS_FRAMEWORK
  #import "GTL/GTLObject.h"
#else
  #import "GTLObject.h"
#endif

// ----------------------------------------------------------------------------
//
//   GTLStoreendpointStoreWaitlistSummary
//

@interface GTLStoreendpointStoreWaitlistSummary : GTLObject
@property (retain) NSNumber *createdDate;  // longLongValue
@property (retain) NSNumber *modifiedDate;  // longLongValue
@property (retain) NSNumber *partiesOfSize12;  // intValue
@property (retain) NSNumber *partiesOfSize34;  // intValue
@property (retain) NSNumber *partiesOfSize5OrMore;  // intValue
@property (retain) NSNumber *storeId;  // longLongValue
@property (copy) NSString *waitTime12;
@property (copy) NSString *waitTime34;
@property (copy) NSString *waitTime5OrMore;
@end