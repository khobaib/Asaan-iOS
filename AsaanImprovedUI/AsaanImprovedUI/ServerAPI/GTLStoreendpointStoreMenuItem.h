/* This file was generated by the ServiceGenerator.
 * The ServiceGenerator is Copyright (c) 2014 Google Inc.
 */

//
//  GTLStoreendpointStoreMenuItem.h
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   storeendpoint/v1
// Description:
//   This is an API
// Classes:
//   GTLStoreendpointStoreMenuItem (0 custom class methods, 26 custom properties)

#if GTL_BUILT_AS_FRAMEWORK
  #import "GTL/GTLObject.h"
#else
  #import "GTLObject.h"
#endif

// ----------------------------------------------------------------------------
//
//   GTLStoreendpointStoreMenuItem
//

@interface GTLStoreendpointStoreMenuItem : GTLObject
@property (retain) NSNumber *active;  // boolValue
@property (copy) NSString *allergyInfo;
@property (retain) NSNumber *calories;  // intValue
@property (retain) NSNumber *createdDate;  // longLongValue
@property (retain) NSNumber *glutenFree;  // boolValue
@property (retain) NSNumber *halal;  // boolValue
@property (retain) NSNumber *hasModifiers;  // boolValue
@property (retain) NSNumber *heatIndex;  // intValue

// identifier property maps to 'id' in JSON (to avoid Objective C's 'id').
@property (retain) NSNumber *identifier;  // longLongValue

@property (copy) NSString *imageUrl;
@property (retain) NSNumber *kosher;  // boolValue
@property (retain) NSNumber *level;  // intValue
@property (copy) NSString *longDescription;
@property (retain) NSNumber *menuItemPOSId;  // intValue
@property (retain) NSNumber *menuItemPosition;  // intValue
@property (copy) NSString *menuName;
@property (retain) NSNumber *menuPOSId;  // intValue
@property (retain) NSNumber *modifiedDate;  // longLongValue
@property (retain) NSNumber *price;  // intValue
@property (copy) NSString *shortDescription;
@property (retain) NSNumber *storeId;  // longLongValue
@property (retain) NSNumber *subMenuPOSId;  // intValue
@property (retain) NSNumber *tax;  // intValue
@property (copy) NSString *thumbnailUrl;
@property (retain) NSNumber *vegan;  // boolValue
@property (retain) NSNumber *vegetarian;  // boolValue
@end
