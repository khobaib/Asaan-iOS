/* This file was generated by the ServiceGenerator.
 * The ServiceGenerator is Copyright (c) 2015 Google Inc.
 */

//
//  GTLStoreendpointStoreWaitListQueue.h
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   storeendpoint/v1
// Description:
//   This is an API
// Classes:
//   GTLStoreendpointStoreWaitListQueue (0 custom class methods, 17 custom properties)

#if GTL_BUILT_AS_FRAMEWORK
  #import "GTL/GTLObject.h"
#else
  #import "GTLObject.h"
#endif

// ----------------------------------------------------------------------------
//
//   GTLStoreendpointStoreWaitListQueue
//

@interface GTLStoreendpointStoreWaitListQueue : GTLObject
@property (retain) NSNumber *createdDate;  // longLongValue
@property (retain) NSNumber *dateNotifiedAcknowledged;  // longLongValue
@property (retain) NSNumber *dateNotifiedTableIsReady;  // longLongValue
@property (retain) NSNumber *estimateChangedByStore;  // boolValue
@property (retain) NSNumber *estTimeMax;  // intValue
@property (retain) NSNumber *estTimeMin;  // intValue

// identifier property maps to 'id' in JSON (to avoid Objective C's 'id').
@property (retain) NSNumber *identifier;  // longLongValue

@property (retain) NSNumber *modifiedDate;  // longLongValue
@property (retain) NSNumber *partySize;  // intValue
@property (retain) NSNumber *status;  // intValue
@property (retain) NSNumber *storeId;  // longLongValue
@property (copy) NSString *storeName;
@property (retain) NSNumber *userId;  // longLongValue
@property (copy) NSString *userName;
@property (copy) NSString *userObjectId;
@property (copy) NSString *userPhone;
@property (copy) NSString *userProfilePhotoUrl;
@end