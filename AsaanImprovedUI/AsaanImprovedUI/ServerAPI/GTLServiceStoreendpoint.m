/* This file was generated by the ServiceGenerator.
 * The ServiceGenerator is Copyright (c) 2014 Google Inc.
 */

//
//  GTLServiceStoreendpoint.m
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   storeendpoint/v1
// Description:
//   This is an API
// Classes:
//   GTLServiceStoreendpoint (0 custom class methods, 0 custom properties)

#import "GTLStoreendpoint.h"

@implementation GTLServiceStoreendpoint

#if DEBUG
// Method compiled in debug builds just to check that all the needed support
// classes are present at link time.
+ (NSArray *)checkClasses {
  NSArray *classes = [NSArray arrayWithObjects:
                      [GTLQueryStoreendpoint class],
                      [GTLStoreendpointMenuItemModifiersAndGroups class],
                      [GTLStoreendpointMenusAndMenuItems class],
                      [GTLStoreendpointStore class],
                      [GTLStoreendpointStoreCollection class],
                      [GTLStoreendpointStoreMenuCombined class],
                      [GTLStoreendpointStoreMenuHierarchy class],
                      [GTLStoreendpointStoreMenuHierarchyCollection class],
                      [GTLStoreendpointStoreMenuItem class],
                      [GTLStoreendpointStoreMenuItemCollection class],
                      [GTLStoreendpointStoreMenuItemModifier class],
                      [GTLStoreendpointStoreMenuItemModifierGroup class],
                      [GTLStoreendpointStoreOrder class],
                      [GTLStoreendpointStoreOwner class],
                      [GTLStoreendpointStoreOwnerCollection class],
                      [GTLStoreendpointStorePOSConnection class],
                      [GTLStoreendpointStoreStats class],
                      [GTLStoreendpointStoreStatsCollection class],
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
    self.rpcURL = [NSURL URLWithString:@"https://asaan-server.appspot.com/_ah/api/rpc?prettyPrint=false"];
  }
  return self;
}

@end
