/* This file was generated by the ServiceGenerator.
 * The ServiceGenerator is Copyright (c) 2015 Google Inc.
 */

//
//  GTLStoreendpointStoreTableGroupMemberCollection.m
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   storeendpoint/v1
// Description:
//   This is an API
// Classes:
//   GTLStoreendpointStoreTableGroupMemberCollection (0 custom class methods, 1 custom properties)

#import "GTLStoreendpointStoreTableGroupMemberCollection.h"

#import "GTLStoreendpointStoreTableGroupMember.h"

// ----------------------------------------------------------------------------
//
//   GTLStoreendpointStoreTableGroupMemberCollection
//

@implementation GTLStoreendpointStoreTableGroupMemberCollection
@dynamic items;

+ (NSDictionary *)arrayPropertyToClassMap {
  NSDictionary *map =
    [NSDictionary dictionaryWithObject:[GTLStoreendpointStoreTableGroupMember class]
                                forKey:@"items"];
  return map;
}

@end
