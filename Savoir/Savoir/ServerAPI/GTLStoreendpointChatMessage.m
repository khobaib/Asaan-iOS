/* This file was generated by the ServiceGenerator.
 * The ServiceGenerator is Copyright (c) 2015 Google Inc.
 */

//
//  GTLStoreendpointChatMessage.m
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   storeendpoint/v1
// Description:
//   This is an API
// Classes:
//   GTLStoreendpointChatMessage (0 custom class methods, 7 custom properties)

#import "GTLStoreendpointChatMessage.h"

// ----------------------------------------------------------------------------
//
//   GTLStoreendpointChatMessage
//

@implementation GTLStoreendpointChatMessage
@dynamic createdDate, fileMessage, identifier, modifiedDate, roomId, txtMessage,
         userId;

+ (NSDictionary *)propertyToJSONKeyMap {
  NSDictionary *map =
    [NSDictionary dictionaryWithObject:@"id"
                                forKey:@"identifier"];
  return map;
}

@end