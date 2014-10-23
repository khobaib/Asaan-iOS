/* This file was generated by the ServiceGenerator.
 * The ServiceGenerator is Copyright (c) 2014 Google Inc.
 */

//
//  GTLStoreendpointStoreMenuItemModifier.h
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   storeendpoint/v1
// Description:
//   This is an API
// Classes:
//   GTLStoreendpointStoreMenuItemModifier (0 custom class methods, 14 custom properties)

#if GTL_BUILT_AS_FRAMEWORK
  #import "GTL/GTLObject.h"
#else
  #import "GTLObject.h"
#endif

// ----------------------------------------------------------------------------
//
//   GTLStoreendpointStoreMenuItemModifier
//

@interface GTLStoreendpointStoreMenuItemModifier : GTLObject
@property (retain) NSNumber *createdDate;  // longLongValue

// identifier property maps to 'id' in JSON (to avoid Objective C's 'id').
@property (retain) NSNumber *identifier;  // longLongValue

@property (copy) NSString *longDescription;
@property (retain) NSNumber *modifiedDate;  // longLongValue
@property (copy) NSString *modifierGroupLongDescription;
@property (retain) NSNumber *modifierGroupMaximum;  // longLongValue
@property (retain) NSNumber *modifierGroupMinimum;  // longLongValue
@property (retain) NSNumber *modifierGroupPOSId;  // longLongValue
@property (copy) NSString *modifierGroupShortDescription;
@property (retain) NSNumber *modifierPOSId;  // longLongValue
@property (retain) NSNumber *price;  // longLongValue
@property (copy) NSString *shortDescription;
@property (retain) NSNumber *storeId;  // longLongValue
@property (retain) NSNumber *weighting;  // longLongValue
@end
