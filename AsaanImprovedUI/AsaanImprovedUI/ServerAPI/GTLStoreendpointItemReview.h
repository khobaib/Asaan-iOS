/* This file was generated by the ServiceGenerator.
 * The ServiceGenerator is Copyright (c) 2015 Google Inc.
 */

//
//  GTLStoreendpointItemReview.h
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   storeendpoint/v1
// Description:
//   This is an API
// Classes:
//   GTLStoreendpointItemReview (0 custom class methods, 7 custom properties)

#if GTL_BUILT_AS_FRAMEWORK
  #import "GTL/GTLObject.h"
#else
  #import "GTLObject.h"
#endif

// ----------------------------------------------------------------------------
//
//   GTLStoreendpointItemReview
//

@interface GTLStoreendpointItemReview : GTLObject
@property (retain) NSNumber *createdDate;  // longLongValue

// identifier property maps to 'id' in JSON (to avoid Objective C's 'id').
@property (retain) NSNumber *identifier;  // longLongValue

@property (retain) NSNumber *like;  // intValue
@property (retain) NSNumber *menuItemPOSId;  // intValue
@property (retain) NSNumber *modifiedDate;  // longLongValue
@property (retain) NSNumber *orderReviewId;  // longLongValue
@property (retain) NSNumber *storeId;  // longLongValue
@end
