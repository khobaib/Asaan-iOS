/* This file was generated by the ServiceGenerator.
 * The ServiceGenerator is Copyright (c) 2014 Google Inc.
 */

//
//  GTLServicePersonendpoint.m
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   personendpoint/v1
// Description:
//   This is an API
// Classes:
//   GTLServicePersonendpoint (0 custom class methods, 0 custom properties)

#import "GTLPersonendpoint.h"

@implementation GTLServicePersonendpoint

#if DEBUG
// Method compiled in debug builds just to check that all the needed support
// classes are present at link time.
+ (NSArray *)checkClasses {
  NSArray *classes = [NSArray arrayWithObjects:
                      [GTLQueryPersonendpoint class],
                      [GTLPersonendpointDeviceInfo class],
                      [GTLPersonendpointPersonCards class],
                      [GTLPersonendpointPersonCardsListWrapper class],
                      [GTLPersonendpointPersonCredentials class],
                      [GTLPersonendpointPersonInfoWrapper class],
                      [GTLPersonendpointPersonProfile class],
                      [GTLPersonendpointSessionTokenWrapper class],
                      nil];
  return classes;
}
#endif  // DEBUG

- (id)init {
  self = [super init];
  if (self) {
    // Version from discovery.
    self.apiVersion = @"v1";

    // From discovery.  Where to send JSON-RPC.
    // Turn off prettyPrint for this service to save bandwidth (especially on
    // mobile). The fetcher logging will pretty print.
    self.rpcURL = [NSURL URLWithString:@"https://aqueous-camera-676.appspot.com/_ah/api/rpc?prettyPrint=false"];
  }
  return self;
}

@end
