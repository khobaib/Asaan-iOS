/* This file was generated by the ServiceGenerator.
 * The ServiceGenerator is Copyright (c) 2015 Google Inc.
 */

//
//  GTLStoreendpointStoreDiscountCollection.m
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   storeendpoint/v1
// Description:
//   This is an API
// Classes:
//   GTLStoreendpointStoreDiscountCollection (0 custom class methods, 1 custom properties)

#import "GTLStoreendpointStoreDiscountCollection.h"

#import "GTLStoreendpointStoreDiscount.h"

// ----------------------------------------------------------------------------
//
//   GTLStoreendpointStoreDiscountCollection
//

@implementation GTLStoreendpointStoreDiscountCollection
@dynamic items;

+ (NSDictionary *)arrayPropertyToClassMap {
  NSDictionary *map =
    [NSDictionary dictionaryWithObject:[GTLStoreendpointStoreDiscount class]
                                forKey:@"items"];
  return map;
}

@end