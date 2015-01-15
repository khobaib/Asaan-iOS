/* This file was generated by the ServiceGenerator.
 * The ServiceGenerator is Copyright (c) 2015 Google Inc.
 */

//
//  GTLStoreendpointStoreDiscount.h
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   storeendpoint/v1
// Description:
//   This is an API
// Classes:
//   GTLStoreendpointStoreDiscount (0 custom class methods, 10 custom properties)

#if GTL_BUILT_AS_FRAMEWORK
  #import "GTL/GTLObject.h"
#else
  #import "GTLObject.h"
#endif

// ----------------------------------------------------------------------------
//
//   GTLStoreendpointStoreDiscount
//

@interface GTLStoreendpointStoreDiscount : GTLObject
@property (copy) NSString *code;
@property (copy) NSString *dates;
@property (copy) NSString *daysOfWeek;

// identifier property maps to 'id' in JSON (to avoid Objective C's 'id').
@property (retain) NSNumber *identifier;  // longLongValue

@property (retain) NSNumber *percentOrAmount;  // boolValue
@property (retain) NSNumber *posDiscountId;  // longLongValue
@property (retain) NSNumber *storeId;  // longLongValue
@property (copy) NSString *times;
@property (copy) NSString *title;
@property (retain) NSNumber *value;  // longLongValue
@end
