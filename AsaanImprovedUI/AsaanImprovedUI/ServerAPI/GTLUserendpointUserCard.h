/* This file was generated by the ServiceGenerator.
 * The ServiceGenerator is Copyright (c) 2014 Google Inc.
 */

//
//  GTLUserendpointUserCard.h
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   userendpoint/v1
// Description:
//   This is an API
// Classes:
//   GTLUserendpointUserCard (0 custom class methods, 21 custom properties)

#if GTL_BUILT_AS_FRAMEWORK
  #import "GTL/GTLObject.h"
#else
  #import "GTLObject.h"
#endif

// ----------------------------------------------------------------------------
//
//   GTLUserendpointUserCard
//

@interface GTLUserendpointUserCard : GTLObject
@property (copy) NSString *accessToken;
@property (copy) NSString *address;
@property (copy) NSString *brand;
@property (copy) NSString *city;
@property (copy) NSString *country;
@property (retain) NSNumber *createdDate;  // longLongValue
@property (copy) NSString *currency;

// Remapped to 'defaultProperty' to avoid language reserved word 'default'.
@property (retain) NSNumber *defaultProperty;  // boolValue

@property (retain) NSNumber *expMonth;  // intValue
@property (retain) NSNumber *expYear;  // intValue
@property (copy) NSString *fundingType;

// identifier property maps to 'id' in JSON (to avoid Objective C's 'id').
@property (retain) NSNumber *identifier;  // longLongValue

@property (copy) NSString *last4;
@property (retain) NSNumber *modifiedDate;  // longLongValue
@property (copy) NSString *name;
@property (copy) NSString *provider;
@property (copy) NSString *providerCustomerId;
@property (copy) NSString *refreshToken;
@property (copy) NSString *state;
@property (retain) NSNumber *userId;  // longLongValue
@property (copy) NSString *zip;
@end
