/* This file was generated by the ServiceGenerator.
 * The ServiceGenerator is Copyright (c) 2015 Google Inc.
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
                      [GTLStoreendpointAsaanLong class],
                      [GTLStoreendpointAsaanLongCollection class],
                      [GTLStoreendpointAsaanLongString class],
                      [GTLStoreendpointChatMessage class],
                      [GTLStoreendpointChatMessagesAndUsers class],
                      [GTLStoreendpointChatRoom class],
                      [GTLStoreendpointChatRoomsAndStoreChatMemberships class],
                      [GTLStoreendpointChatUser class],
                      [GTLStoreendpointChatUserArray class],
                      [GTLStoreendpointClientVersionMatch class],
                      [GTLStoreendpointItemReview class],
                      [GTLStoreendpointItemReviewsArray class],
                      [GTLStoreendpointMenuItemAndStats class],
                      [GTLStoreendpointMenuItemAndStatsCollection class],
                      [GTLStoreendpointMenuItemModifiersAndGroups class],
                      [GTLStoreendpointMenusAndMenuItems class],
                      [GTLStoreendpointOrderAndReviews class],
                      [GTLStoreendpointOrderReview class],
                      [GTLStoreendpointOrderReviewAndItemReviews class],
                      [GTLStoreendpointOrderReviewListAndCount class],
                      [GTLStoreendpointPlaceOrderArguments class],
                      [GTLStoreendpointSplitOrderArguments class],
                      [GTLStoreendpointStore class],
                      [GTLStoreendpointStoreAndStats class],
                      [GTLStoreendpointStoreAndStatsAndCount class],
                      [GTLStoreendpointStoreAndStatsCollection class],
                      [GTLStoreendpointStoreChatMemberArray class],
                      [GTLStoreendpointStoreChatTeam class],
                      [GTLStoreendpointStoreChatTeamCollection class],
                      [GTLStoreendpointStoreCollection class],
                      [GTLStoreendpointStoreDiscount class],
                      [GTLStoreendpointStoreDiscountArray class],
                      [GTLStoreendpointStoreDiscountCollection class],
                      [GTLStoreendpointStoreItemStats class],
                      [GTLStoreendpointStoreMenuCombined class],
                      [GTLStoreendpointStoreMenuHierarchy class],
                      [GTLStoreendpointStoreMenuHierarchyCollection class],
                      [GTLStoreendpointStoreMenuItem class],
                      [GTLStoreendpointStoreMenuItemCollection class],
                      [GTLStoreendpointStoreMenuItemModifier class],
                      [GTLStoreendpointStoreMenuItemModifierGroup class],
                      [GTLStoreendpointStoreMenuStats class],
                      [GTLStoreendpointStoreOrder class],
                      [GTLStoreendpointStoreOrderAndTeamDetails class],
                      [GTLStoreendpointStoreOrderListAndCount class],
                      [GTLStoreendpointStoreOwner class],
                      [GTLStoreendpointStoreOwnerCollection class],
                      [GTLStoreendpointStorePOSConnection class],
                      [GTLStoreendpointStoreStats class],
                      [GTLStoreendpointStoreStatsCollection class],
                      [GTLStoreendpointStoreTableGroup class],
                      [GTLStoreendpointStoreTableGroupCollection class],
                      [GTLStoreendpointStoreTableGroupMember class],
                      [GTLStoreendpointStoreTableGroupMemberArray class],
                      [GTLStoreendpointStoreTableGroupMemberCollection class],
                      [GTLStoreendpointStoreWaitListQueue class],
                      [GTLStoreendpointStoreWaitListQueueAndPosition class],
                      [GTLStoreendpointStoreWaitListQueueCollection class],
                      [GTLStoreendpointTableGroupsAndOrders class],
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
    self.rpcURL = [NSURL URLWithString:@"https://blissful-mantis-89513.appspot.com/_ah/api/rpc?prettyPrint=false"];
  }
  return self;
}

@end
