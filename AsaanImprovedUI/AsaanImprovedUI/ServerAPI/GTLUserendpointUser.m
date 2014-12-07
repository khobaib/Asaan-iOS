/* This file was generated by the ServiceGenerator.
 * The ServiceGenerator is Copyright (c) 2014 Google Inc.
 */

//
//  GTLUserendpointUser.m
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   userendpoint/v1
// Description:
//   This is an API
// Classes:
//   GTLUserendpointUser (0 custom class methods, 16 custom properties)

#import "GTLUserendpointUser.h"

// ----------------------------------------------------------------------------
//
//   GTLUserendpointUser
//

@implementation GTLUserendpointUser
@dynamic admin, authToken, createdDate, defaultTip, email, firstName,
         identifier, lastName, modifiedDate, parseAuthData, parseCreatedAt,
         parseObjectId, parseUpdatedAt, phone, profilePhotoUrl, userId;

+ (NSDictionary *)propertyToJSONKeyMap {
  NSDictionary *map =
    [NSDictionary dictionaryWithObject:@"id"
                                forKey:@"identifier"];
  return map;
}

@end
