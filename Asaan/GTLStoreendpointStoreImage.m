/* This file was generated by the ServiceGenerator.
 * The ServiceGenerator is Copyright (c) 2014 Google Inc.
 */

//
//  GTLStoreendpointStoreImage.m
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   storeendpoint/v1
// Description:
//   This is an API
// Classes:
//   GTLStoreendpointStoreImage (0 custom class methods, 6 custom properties)

#import "GTLStoreendpointStoreImage.h"

// ----------------------------------------------------------------------------
//
//   GTLStoreendpointStoreImage
//

@implementation GTLStoreendpointStoreImage
@dynamic createdDate, identifier, imageUrl, modifiedDate, storeId, thumbnailUrl;

+ (NSDictionary *)propertyToJSONKeyMap {
  NSDictionary *map =
    [NSDictionary dictionaryWithObject:@"id"
                                forKey:@"identifier"];
  return map;
}

@end