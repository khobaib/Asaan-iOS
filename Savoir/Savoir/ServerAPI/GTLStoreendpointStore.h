/* This file was generated by the ServiceGenerator.
 * The ServiceGenerator is Copyright (c) 2015 Google Inc.
 */

//
//  GTLStoreendpointStore.h
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   storeendpoint/v1
// Description:
//   This is an API
// Classes:
//   GTLStoreendpointStore (0 custom class methods, 44 custom properties)

#if GTL_BUILT_AS_FRAMEWORK
  #import "GTL/GTLObject.h"
#else
  #import "GTLObject.h"
#endif

// ----------------------------------------------------------------------------
//
//   GTLStoreendpointStore
//

@interface GTLStoreendpointStore : GTLObject
@property (copy) NSString *address;
@property (copy) NSString *backgroundImageUrl;
@property (copy) NSString *backgroundThumbnailUrl;
@property (retain) NSNumber *beaconId;  // longLongValue
@property (copy) NSString *bssid;
@property (copy) NSString *city;
@property (retain) NSNumber *claimed;  // boolValue
@property (retain) NSNumber *cosineLat;  // doubleValue
@property (retain) NSNumber *cosineLng;  // doubleValue
@property (retain) NSNumber *createdDate;  // longLongValue
@property (retain) NSNumber *deliveryDistance;  // intValue
@property (retain) NSNumber *deliveryFee;  // intValue

// Remapped to 'descriptionProperty' to avoid NSObject's 'description'.
@property (copy) NSString *descriptionProperty;

@property (copy) NSString *executiveChef;
@property (copy) NSString *fbUrl;
@property (copy) NSString *gplusUrl;
@property (copy) NSString *hours;

// identifier property maps to 'id' in JSON (to avoid Objective C's 'id').
@property (retain) NSNumber *identifier;  // longLongValue

@property (retain) NSNumber *isActive;  // boolValue
@property (retain) NSNumber *lat;  // doubleValue
@property (retain) NSNumber *lng;  // doubleValue
@property (retain) NSNumber *minOrderAmtForDelivery;  // intValue
@property (retain) NSNumber *modifiedDate;  // longLongValue
@property (copy) NSString *name;
@property (copy) NSString *phone;
@property (retain) NSNumber *priceRange;  // intValue
@property (retain) NSNumber *providesCarryout;  // boolValue
@property (retain) NSNumber *providesChat;  // boolValue
@property (retain) NSNumber *providesDelivery;  // boolValue
@property (retain) NSNumber *providesPreOrder;  // boolValue
@property (retain) NSNumber *providesReservation;  // boolValue
@property (retain) NSNumber *providesWaitlist;  // boolValue
@property (copy) NSString *rewardsDescription;
@property (retain) NSNumber *rewardsRate;  // intValue
@property (retain) NSNumber *sineLat;  // doubleValue
@property (retain) NSNumber *sineLng;  // doubleValue
@property (copy) NSString *ssid;
@property (copy) NSString *state;
@property (copy) NSString *subType;
@property (retain) NSArray *trophies;  // of NSString
@property (copy) NSString *twitterUrl;
@property (copy) NSString *type;
@property (copy) NSString *webSiteUrl;
@property (copy) NSString *zip;
@end
