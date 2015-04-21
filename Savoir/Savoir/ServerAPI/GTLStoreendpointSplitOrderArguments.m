/* This file was generated by the ServiceGenerator.
 * The ServiceGenerator is Copyright (c) 2015 Google Inc.
 */

//
//  GTLStoreendpointSplitOrderArguments.m
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   storeendpoint/v1
// Description:
//   This is an API
// Classes:
//   GTLStoreendpointSplitOrderArguments (0 custom class methods, 4 custom properties)

#import "GTLStoreendpointSplitOrderArguments.h"

#import "GTLStoreendpointStoreTableGroupMember.h"

// ----------------------------------------------------------------------------
//
//   GTLStoreendpointSplitOrderArguments
//

@implementation GTLStoreendpointSplitOrderArguments
@dynamic cardid, customerId, stgms, token;

+ (NSDictionary *)arrayPropertyToClassMap {
  NSDictionary *map =
    [NSDictionary dictionaryWithObject:[GTLStoreendpointStoreTableGroupMember class]
                                forKey:@"stgms"];
  return map;
}

@end
