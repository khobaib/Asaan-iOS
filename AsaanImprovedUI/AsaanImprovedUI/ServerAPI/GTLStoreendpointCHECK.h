/* This file was generated by the ServiceGenerator.
 * The ServiceGenerator is Copyright (c) 2015 Google Inc.
 */

//
//  GTLStoreendpointCHECK.h
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   storeendpoint/v1
// Description:
//   This is an API
// Classes:
//   GTLStoreendpointCHECK (0 custom class methods, 12 custom properties)

#if GTL_BUILT_AS_FRAMEWORK
  #import "GTL/GTLObject.h"
#else
  #import "GTLObject.h"
#endif

@class GTLStoreendpointDISCOUNTS;
@class GTLStoreendpointENTRIES;

// ----------------------------------------------------------------------------
//
//   GTLStoreendpointCHECK
//

@interface GTLStoreendpointCHECK : GTLObject
@property (retain) NSNumber *completetotal;  // floatValue
@property (retain) GTLStoreendpointDISCOUNTS *discounts;
@property (retain) NSNumber *employee;  // intValue
@property (copy) NSString *employeecheckname;
@property (retain) GTLStoreendpointENTRIES *entries;
@property (retain) NSNumber *guestcount;  // intValue

// identifier property maps to 'id' in JSON (to avoid Objective C's 'id').
@property (retain) NSNumber *identifier;  // intValue

@property (copy) NSString *payments;
@property (retain) NSNumber *servicecharges;  // floatValue
@property (retain) NSNumber *subtotal;  // floatValue
@property (retain) NSNumber *tablenumber;  // intValue
@property (retain) NSNumber *tax;  // floatValue
@end
