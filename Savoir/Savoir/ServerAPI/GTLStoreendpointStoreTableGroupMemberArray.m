/* This file was generated by the ServiceGenerator.
 * The ServiceGenerator is Copyright (c) 2015 Google Inc.
 */

//
//  GTLStoreendpointStoreTableGroupMemberArray.m
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   storeendpoint/v1
// Description:
//   This is an API
// Classes:
//   GTLStoreendpointStoreTableGroupMemberArray (0 custom class methods, 1 custom properties)

#import "GTLStoreendpointStoreTableGroupMemberArray.h"

#import "GTLStoreendpointStoreTableGroupMember.h"

// ----------------------------------------------------------------------------
//
//   GTLStoreendpointStoreTableGroupMemberArray
//

@implementation GTLStoreendpointStoreTableGroupMemberArray
@dynamic members;

+ (NSDictionary *)arrayPropertyToClassMap {
  NSDictionary *map =
    [NSDictionary dictionaryWithObject:[GTLStoreendpointStoreTableGroupMember class]
                                forKey:@"members"];
  return map;
}

@end