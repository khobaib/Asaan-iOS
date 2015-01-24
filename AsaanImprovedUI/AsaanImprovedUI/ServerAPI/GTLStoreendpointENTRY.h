/* This file was generated by the ServiceGenerator.
 * The ServiceGenerator is Copyright (c) 2015 Google Inc.
 */

//
//  GTLStoreendpointENTRY.h
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   storeendpoint/v1
// Description:
//   This is an API
// Classes:
//   GTLStoreendpointENTRY (0 custom class methods, 9 custom properties)

#if GTL_BUILT_AS_FRAMEWORK
  #import "GTL/GTLObject.h"
#else
  #import "GTLObject.h"
#endif

// ----------------------------------------------------------------------------
//
//   GTLStoreendpointENTRY
//

@interface GTLStoreendpointENTRY : GTLObject
@property (copy) NSString *dispname;
@property (retain) NSNumber *entrytype;  // intValue

// identifier property maps to 'id' in JSON (to avoid Objective C's 'id').
@property (retain) NSNumber *identifier;  // intValue

@property (retain) NSNumber *itemid;  // intValue
@property (retain) NSNumber *ordermode;  // intValue
@property (retain) NSNumber *parententry;  // intValue
@property (retain) NSNumber *price;  // floatValue
@property (retain) NSNumber *quantity;  // intValue
@property (copy) NSString *value;
@end