/* This file was generated by the ServiceGenerator.
 * The ServiceGenerator is Copyright (c) 2014 Google Inc.
 */

//
//  GTLStoreendpointOrderCustomer.h
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   storeendpoint/v1
// Description:
//   This is an API
// Classes:
//   GTLStoreendpointOrderCustomer (0 custom class methods, 6 custom properties)

#if GTL_BUILT_AS_FRAMEWORK
  #import "GTL/GTLObject.h"
#else
  #import "GTLObject.h"
#endif

// ----------------------------------------------------------------------------
//
//   GTLStoreendpointOrderCustomer
//

@interface GTLStoreendpointOrderCustomer : GTLObject
@property (retain) NSNumber *createdDate;  // longLongValue

// identifier property maps to 'id' in JSON (to avoid Objective C's 'id').
@property (retain) NSNumber *identifier;  // longLongValue

@property (retain) NSNumber *modifiedDate;  // longLongValue
@property (retain) NSNumber *orderId;  // longLongValue
@property (retain) NSNumber *storeId;  // longLongValue
@property (retain) NSNumber *userId;  // longLongValue
@end
