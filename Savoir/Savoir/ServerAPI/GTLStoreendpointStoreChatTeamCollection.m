/* This file was generated by the ServiceGenerator.
 * The ServiceGenerator is Copyright (c) 2015 Google Inc.
 */

//
//  GTLStoreendpointStoreChatTeamCollection.m
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   storeendpoint/v1
// Description:
//   This is an API
// Classes:
//   GTLStoreendpointStoreChatTeamCollection (0 custom class methods, 1 custom properties)

#import "GTLStoreendpointStoreChatTeamCollection.h"

#import "GTLStoreendpointStoreChatTeam.h"

// ----------------------------------------------------------------------------
//
//   GTLStoreendpointStoreChatTeamCollection
//

@implementation GTLStoreendpointStoreChatTeamCollection
@dynamic items;

+ (NSDictionary *)arrayPropertyToClassMap {
  NSDictionary *map =
    [NSDictionary dictionaryWithObject:[GTLStoreendpointStoreChatTeam class]
                                forKey:@"items"];
  return map;
}

@end