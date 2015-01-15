/* This file was generated by the ServiceGenerator.
 * The ServiceGenerator is Copyright (c) 2015 Google Inc.
 */

//
//  GTLQueryUserendpoint.h
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   userendpoint/v1
// Description:
//   This is an API
// Classes:
//   GTLQueryUserendpoint (7 custom class methods, 2 custom properties)

#if GTL_BUILT_AS_FRAMEWORK
  #import "GTL/GTLQuery.h"
#else
  #import "GTLQuery.h"
#endif

@class GTLUserendpointUser;
@class GTLUserendpointUserAddress;
@class GTLUserendpointUserCard;

@interface GTLQueryUserendpoint : GTLQuery

//
// Parameters valid on all methods.
//

// Selector specifying which fields to include in a partial response.
@property (copy) NSString *fields;

//
// Method-specific parameters; see the comments below for more information.
//
@property (copy) NSString *email;

#pragma mark -
#pragma mark Service level methods
// These create a GTLQueryUserendpoint object.

// Method: userendpoint.getUserAddresses
//  Authorization scope(s):
//   kGTLAuthScopeUserendpointUserinfoEmail
// Fetches a GTLUserendpointUserAddressCollection.
+ (id)queryForGetUserAddresses;

// Method: userendpoint.getUserByEmail
//  Authorization scope(s):
//   kGTLAuthScopeUserendpointUserinfoEmail
// Fetches a GTLUserendpointUser.
+ (id)queryForGetUserByEmailWithEmail:(NSString *)email;

// Method: userendpoint.getUserCards
//  Authorization scope(s):
//   kGTLAuthScopeUserendpointUserinfoEmail
// Fetches a GTLUserendpointUserCardCollection.
+ (id)queryForGetUserCards;

// Method: userendpoint.saveUser
//  Authorization scope(s):
//   kGTLAuthScopeUserendpointUserinfoEmail
+ (id)queryForSaveUserWithObject:(GTLUserendpointUser *)object;

// Method: userendpoint.saveUserAddress
//  Authorization scope(s):
//   kGTLAuthScopeUserendpointUserinfoEmail
// Fetches a GTLUserendpointUserAddress.
+ (id)queryForSaveUserAddressWithObject:(GTLUserendpointUserAddress *)object;

// Method: userendpoint.saveUserCard
//  Authorization scope(s):
//   kGTLAuthScopeUserendpointUserinfoEmail
// Fetches a GTLUserendpointUserCard.
+ (id)queryForSaveUserCardWithObject:(GTLUserendpointUserCard *)object;

// Method: userendpoint.saveUserProfile
//  Authorization scope(s):
//   kGTLAuthScopeUserendpointUserinfoEmail
// Fetches a GTLUserendpointUser.
+ (id)queryForSaveUserProfileWithObject:(GTLUserendpointUser *)object;

@end
