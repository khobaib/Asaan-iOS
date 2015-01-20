/* This file was generated by the ServiceGenerator.
 * The ServiceGenerator is Copyright (c) 2015 Google Inc.
 */

//
//  GTLStoreendpointItemReview.m
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   storeendpoint/v1
// Description:
//   This is an API
// Classes:
//   GTLStoreendpointItemReview (0 custom class methods, 7 custom properties)

#import "GTLStoreendpointItemReview.h"

// ----------------------------------------------------------------------------
//
//   GTLStoreendpointItemReview
//

@implementation GTLStoreendpointItemReview
@dynamic createdDate, identifier, like, menuItemPOSId, modifiedDate,
         orderReviewId, storeId;

+ (NSDictionary *)propertyToJSONKeyMap {
  NSDictionary *map =
    [NSDictionary dictionaryWithObject:@"id"
                                forKey:@"identifier"];
  return map;
}

@end
