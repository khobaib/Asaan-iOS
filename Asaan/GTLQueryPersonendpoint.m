/* This file was generated by the ServiceGenerator.
 * The ServiceGenerator is Copyright (c) 2014 Google Inc.
 */

//
//  GTLQueryPersonendpoint.m
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   personendpoint/v1
// Description:
//   This is an API
// Classes:
//   GTLQueryPersonendpoint (8 custom class methods, 6 custom properties)

#import "GTLQueryPersonendpoint.h"

#import "GTLPersonendpointDeviceInfo.h"
#import "GTLPersonendpointPersonCardsListWrapper.h"
#import "GTLPersonendpointPersonInfoWrapper.h"
#import "GTLPersonendpointSessionTokenWrapper.h"

@implementation GTLQueryPersonendpoint

@dynamic deviceinfo, email, fields, password, personinfowrapper, sessionId;

#pragma mark -
#pragma mark Service level methods
// These create a GTLQueryPersonendpoint object.

+ (id)queryForNativeLoginWithObject:(GTLPersonendpointDeviceInfo *)object
                              email:(NSString *)email
                           password:(NSString *)password {
  if (object == nil) {
    GTL_DEBUG_ASSERT(object != nil, @"%@ got a nil object", NSStringFromSelector(_cmd));
    return nil;
  }
  NSString *methodName = @"personendpoint.nativeLogin";
  GTLQueryPersonendpoint *query = [self queryWithMethodName:methodName];
  query.bodyObject = object;
  query.email = email;
  query.password = password;
  query.expectedObjectClass = [GTLPersonendpointSessionTokenWrapper class];
  return query;
}

+ (id)queryForNativeLoginRPCWithEmail:(NSString *)email
                             password:(NSString *)password
                           deviceinfo:(NSString *)deviceinfo {
  NSString *methodName = @"personendpoint.nativeLoginRPC";
  GTLQueryPersonendpoint *query = [self queryWithMethodName:methodName];
  query.email = email;
  query.password = password;
  query.deviceinfo = deviceinfo;
  query.expectedObjectClass = [GTLPersonendpointSessionTokenWrapper class];
  return query;
}

+ (id)queryForNativeSignupWithObject:(GTLPersonendpointPersonInfoWrapper *)object {
  if (object == nil) {
    GTL_DEBUG_ASSERT(object != nil, @"%@ got a nil object", NSStringFromSelector(_cmd));
    return nil;
  }
  NSString *methodName = @"personendpoint.nativeSignup";
  GTLQueryPersonendpoint *query = [self queryWithMethodName:methodName];
  query.bodyObject = object;
  query.expectedObjectClass = [GTLPersonendpointSessionTokenWrapper class];
  return query;
}

+ (id)queryForNativeSignupRPCWithPersoninfowrapper:(NSString *)personinfowrapper {
  NSString *methodName = @"personendpoint.nativeSignupRPC";
  GTLQueryPersonendpoint *query = [self queryWithMethodName:methodName];
  query.personinfowrapper = personinfowrapper;
  query.expectedObjectClass = [GTLPersonendpointSessionTokenWrapper class];
  return query;
}

+ (id)queryForReplacePersonCardsWithObject:(GTLPersonendpointPersonCardsListWrapper *)object
                                 sessionId:(NSString *)sessionId {
  if (object == nil) {
    GTL_DEBUG_ASSERT(object != nil, @"%@ got a nil object", NSStringFromSelector(_cmd));
    return nil;
  }
  NSString *methodName = @"personendpoint.replacePersonCards";
  GTLQueryPersonendpoint *query = [self queryWithMethodName:methodName];
  query.bodyObject = object;
  query.sessionId = sessionId;
  return query;
}

+ (id)queryForResetPasswordWithEmail:(NSString *)email {
  NSString *methodName = @"personendpoint.resetPassword";
  GTLQueryPersonendpoint *query = [self queryWithMethodName:methodName];
  query.email = email;
  return query;
}

+ (id)queryForSocialSignupWithObject:(GTLPersonendpointPersonInfoWrapper *)object {
  if (object == nil) {
    GTL_DEBUG_ASSERT(object != nil, @"%@ got a nil object", NSStringFromSelector(_cmd));
    return nil;
  }
  NSString *methodName = @"personendpoint.socialSignup";
  GTLQueryPersonendpoint *query = [self queryWithMethodName:methodName];
  query.bodyObject = object;
  query.expectedObjectClass = [GTLPersonendpointSessionTokenWrapper class];
  return query;
}

+ (id)queryForSocialSignupRPCWithPersoninfowrapper:(NSString *)personinfowrapper {
  NSString *methodName = @"personendpoint.socialSignupRPC";
  GTLQueryPersonendpoint *query = [self queryWithMethodName:methodName];
  query.personinfowrapper = personinfowrapper;
  query.expectedObjectClass = [GTLPersonendpointSessionTokenWrapper class];
  return query;
}

@end
