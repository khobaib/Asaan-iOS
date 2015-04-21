/* This file was generated by the ServiceGenerator.
 * The ServiceGenerator is Copyright (c) 2015 Google Inc.
 */

//
//  GTLQueryStoreendpoint.h
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   storeendpoint/v1
// Description:
//   This is an API
// Classes:
//   GTLQueryStoreendpoint (65 custom class methods, 18 custom properties)

#if GTL_BUILT_AS_FRAMEWORK
  #import "GTL/GTLQuery.h"
#else
  #import "GTLQuery.h"
#endif

@class GTLStoreendpointAsaanLongString;
@class GTLStoreendpointChatMessage;
@class GTLStoreendpointChatRoom;
@class GTLStoreendpointItemReviewsArray;
@class GTLStoreendpointOrderReview;
@class GTLStoreendpointPlaceOrderArguments;
@class GTLStoreendpointSplitOrderArguments;
@class GTLStoreendpointStore;
@class GTLStoreendpointStoreChatMemberArray;
@class GTLStoreendpointStoreDiscount;
@class GTLStoreendpointStoreDiscountArray;
@class GTLStoreendpointStoreMenuCombined;
@class GTLStoreendpointStoreMenuHierarchy;
@class GTLStoreendpointStoreMenuItem;
@class GTLStoreendpointStoreMenuItemModifier;
@class GTLStoreendpointStoreMenuItemModifierGroup;
@class GTLStoreendpointStoreOrder;
@class GTLStoreendpointStoreOwner;
@class GTLStoreendpointStorePOSConnection;
@class GTLStoreendpointStoreTableGroupMemberArray;
@class GTLStoreendpointStoreWaitListQueue;
@class GTLStoreendpointStoreWaitlistSummary;

@interface GTLQueryStoreendpoint : GTLQuery

//
// Parameters valid on all methods.
//

// Selector specifying which fields to include in a partial response.
@property (copy) NSString *fields;

//
// Method-specific parameters; see the comments below for more information.
//
@property (assign) long long beaconId;
@property (assign) NSInteger firstPosition;
@property (assign) BOOL isStore;
@property (assign) double lat;
@property (assign) double lng;
@property (assign) NSInteger maxResult;
@property (assign) NSInteger menuItemPOSId;
@property (assign) NSInteger menuPOSId;
@property (assign) NSInteger menuType;
@property (assign) long long modifiedDate;
@property (assign) long long orderId;
@property (assign) NSInteger queuePosition;
@property (assign) long long roomId;
@property (assign) long long roomOrStoreId;
@property (assign) long long storeId;
@property (copy) NSString *storeName;
@property (assign) long long storeTableGroupId;

#pragma mark -
#pragma mark Service level methods
// These create a GTLQueryStoreendpoint object.

// Method: storeendpoint.addMemberToStoreTableGroup
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
+ (id)queryForAddMemberToStoreTableGroupWithOrderId:(long long)orderId
                                  storeTableGroupId:(long long)storeTableGroupId;

// Method: storeendpoint.createStoreTableGroup
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
+ (id)queryForCreateStoreTableGroupWithStoreId:(long long)storeId;

// Method: storeendpoint.getChatMessagesForStoreOrRoom
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
// Fetches a GTLStoreendpointChatMessagesAndUsers.
+ (id)queryForGetChatMessagesForStoreOrRoomWithFirstPosition:(NSInteger)firstPosition
                                                     isStore:(BOOL)isStore
                                                   maxResult:(NSInteger)maxResult
                                                modifiedDate:(long long)modifiedDate
                                               roomOrStoreId:(long long)roomOrStoreId;

// Method: storeendpoint.getChatRoomsAndMembershipsForUser
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
// Fetches a GTLStoreendpointChatRoomsAndStoreChatMemberships.
+ (id)queryForGetChatRoomsAndMembershipsForUser;

// Method: storeendpoint.getChatUsersForRoom
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
// Fetches a GTLStoreendpointChatUserArray.
+ (id)queryForGetChatUsersForRoomWithRoomId:(long long)roomId;

// Method: storeendpoint.getClientVersion
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
// Fetches a GTLStoreendpointClientVersionMatch.
+ (id)queryForGetClientVersion;

// Method: storeendpoint.getMembersForStoreTableGroup
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
// Fetches a GTLStoreendpointStoreTableGroupMemberCollection.
+ (id)queryForGetMembersForStoreTableGroupWithStoreTableGroupId:(long long)storeTableGroupId;

// Method: storeendpoint.getMenuItemAndStatsForMenu
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
// Fetches a GTLStoreendpointMenuItemAndStatsCollection.
+ (id)queryForGetMenuItemAndStatsForMenuWithFirstPosition:(NSInteger)firstPosition
                                                maxResult:(NSInteger)maxResult
                                                menuPOSId:(NSInteger)menuPOSId
                                                  storeId:(long long)storeId;

// Method: storeendpoint.getOpenAndUnassignedGroupsForStore
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
// Fetches a GTLStoreendpointStoreTableGroupCollection.
+ (id)queryForGetOpenAndUnassignedGroupsForStoreWithStoreId:(long long)storeId;

// Method: storeendpoint.getOpenGroupForMember
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
// Fetches a GTLStoreendpointStoreTableGroupMember.
+ (id)queryForGetOpenGroupForMember;

// Method: storeendpoint.getOrderAndReviewsById
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
// Fetches a GTLStoreendpointOrderAndReviews.
+ (id)queryForGetOrderAndReviewsByIdWithOrderId:(long long)orderId;

// Method: storeendpoint.getOrderReviewsForStore
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
// Fetches a GTLStoreendpointOrderReviewListAndCount.
+ (id)queryForGetOrderReviewsForStoreWithFirstPosition:(NSInteger)firstPosition
                                             maxResult:(NSInteger)maxResult
                                               storeId:(long long)storeId;

// Method: storeendpoint.getReviewForCurrentUserAndOrder
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
// Fetches a GTLStoreendpointOrderReviewAndItemReviews.
+ (id)queryForGetReviewForCurrentUserAndOrderWithOrderId:(long long)orderId;

// Method: storeendpoint.getStatsForAllStores
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
// Fetches a GTLStoreendpointStoreStatsCollection.
+ (id)queryForGetStatsForAllStoresWithFirstPosition:(NSInteger)firstPosition
                                          maxResult:(NSInteger)maxResult;

// Method: storeendpoint.getStore
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
// Fetches a GTLStoreendpointStore.
+ (id)queryForGetStoreWithStoreId:(long long)storeId;

// Method: storeendpoint.getStoreByBeaconId
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
// Fetches a GTLStoreendpointStore.
+ (id)queryForGetStoreByBeaconIdWithBeaconId:(long long)beaconId;

// Method: storeendpoint.getStoreChatMembers
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
// Fetches a GTLStoreendpointStoreChatTeamCollection.
+ (id)queryForGetStoreChatMembersWithStoreId:(long long)storeId;

// Method: storeendpoint.getStoreChatTeamsForUser
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
// Fetches a GTLStoreendpointStoreChatTeamCollection.
+ (id)queryForGetStoreChatTeamsForUser;

// Method: storeendpoint.getStoreCount
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
// Fetches a GTLStoreendpointAsaanLong.
+ (id)queryForGetStoreCount;

// Method: storeendpoint.getStoreDiscounts
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
// Fetches a GTLStoreendpointStoreDiscountCollection.
+ (id)queryForGetStoreDiscountsWithStoreId:(long long)storeId;

// Method: storeendpoint.getStoreMenuHierarchyAndItems
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
// Fetches a GTLStoreendpointMenusAndMenuItems.
+ (id)queryForGetStoreMenuHierarchyAndItemsWithMaxResult:(NSInteger)maxResult
                                                menuType:(NSInteger)menuType
                                                 storeId:(long long)storeId;

// Method: storeendpoint.getStoreMenuItemModifiers
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
// Fetches a GTLStoreendpointMenuItemModifiersAndGroups.
+ (id)queryForGetStoreMenuItemModifiersWithMenuItemPOSId:(NSInteger)menuItemPOSId
                                                 storeId:(long long)storeId;

// Method: storeendpoint.getStoreMenuItems
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
// Fetches a GTLStoreendpointStoreMenuItemCollection.
+ (id)queryForGetStoreMenuItemsWithFirstPosition:(NSInteger)firstPosition
                                       maxResult:(NSInteger)maxResult
                                         storeId:(long long)storeId;

// Method: storeendpoint.getStoreMenus
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
// Fetches a GTLStoreendpointStoreMenuHierarchyCollection.
+ (id)queryForGetStoreMenusWithFirstPosition:(NSInteger)firstPosition
                                   maxResult:(NSInteger)maxResult
                                     storeId:(long long)storeId;

// Method: storeendpoint.getStoreOrderById
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
// Fetches a GTLStoreendpointStoreOrder.
+ (id)queryForGetStoreOrderByIdWithOrderId:(long long)orderId;

// Method: storeendpoint.getStoreOrdersAndGroupsForEmployee
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
// Fetches a GTLStoreendpointTableGroupsAndOrders.
+ (id)queryForGetStoreOrdersAndGroupsForEmployeeWithStoreId:(long long)storeId;

// Method: storeendpoint.getStoreOrdersForCurrentUser
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
// Fetches a GTLStoreendpointStoreOrderListAndCount.
+ (id)queryForGetStoreOrdersForCurrentUserWithFirstPosition:(NSInteger)firstPosition
                                                  maxResult:(NSInteger)maxResult;

// Method: storeendpoint.getStoreOrdersForCurrentUserAndStore
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
// Fetches a GTLStoreendpointStoreOrderListAndCount.
+ (id)queryForGetStoreOrdersForCurrentUserAndStoreWithFirstPosition:(NSInteger)firstPosition
                                                          maxResult:(NSInteger)maxResult
                                                            storeId:(long long)storeId;

// Method: storeendpoint.getStoreOwners
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
// Fetches a GTLStoreendpointStoreOwnerCollection.
+ (id)queryForGetStoreOwnersWithStoreId:(long long)storeId;

// Method: storeendpoint.getStorePOSConnection
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
// Fetches a GTLStoreendpointStorePOSConnection.
+ (id)queryForGetStorePOSConnectionWithStoreId:(long long)storeId;

// Method: storeendpoint.getStores
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
// Fetches a GTLStoreendpointStoreCollection.
+ (id)queryForGetStoresWithFirstPosition:(NSInteger)firstPosition
                               maxResult:(NSInteger)maxResult;

// Method: storeendpoint.getStoresOrderedByDistanceWithStats
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
// Fetches a GTLStoreendpointStoreAndStatsCollection.
+ (id)queryForGetStoresOrderedByDistanceWithStatsWithFirstPosition:(NSInteger)firstPosition
                                                               lat:(double)lat
                                                               lng:(double)lng
                                                         maxResult:(NSInteger)maxResult;

// Method: storeendpoint.getStoresOrderedByDistanceWithStatsByOwner
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
// Fetches a GTLStoreendpointStoreAndStatsCollection.
+ (id)queryForGetStoresOrderedByDistanceWithStatsByOwnerWithFirstPosition:(NSInteger)firstPosition
                                                                      lat:(double)lat
                                                                      lng:(double)lng
                                                                maxResult:(NSInteger)maxResult;

// Method: storeendpoint.getStoresOwnedByUser
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
// Fetches a GTLStoreendpointAsaanLongCollection.
+ (id)queryForGetStoresOwnedByUser;

// Method: storeendpoint.getStoreStats
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
// Fetches a GTLStoreendpointStoreStats.
+ (id)queryForGetStoreStatsWithStoreId:(long long)storeId;

// Method: storeendpoint.getStoresWithStats
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
// Fetches a GTLStoreendpointStoreAndStatsCollection.
+ (id)queryForGetStoresWithStatsWithFirstPosition:(NSInteger)firstPosition
                                        maxResult:(NSInteger)maxResult;

// Method: storeendpoint.getStoreTableGroupDetailsForCurrentUser
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
// Fetches a GTLStoreendpointStoreOrderAndTeamDetails.
+ (id)queryForGetStoreTableGroupDetailsForCurrentUser;

// Method: storeendpoint.getStoreTableGroupsForStore
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
// Fetches a GTLStoreendpointStoreTableGroupCollection.
+ (id)queryForGetStoreTableGroupsForStoreWithStoreId:(long long)storeId;

// Method: storeendpoint.getStoreWaitListQueue
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
// Fetches a GTLStoreendpointStoreWaitListQueueCollection.
+ (id)queryForGetStoreWaitListQueueWithStoreId:(long long)storeId;

// Method: storeendpoint.getStoreWaitListQueueEntryForCurrentUser
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
// Fetches a GTLStoreendpointStoreWaitListQueueAndPosition.
+ (id)queryForGetStoreWaitListQueueEntryForCurrentUser;

// Method: storeendpoint.payForMember
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
+ (id)queryForPayForMemberWithObject:(GTLStoreendpointSplitOrderArguments *)object;

// Method: storeendpoint.placeOrder
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
// Fetches a GTLStoreendpointStoreOrder.
+ (id)queryForPlaceOrderWithObject:(GTLStoreendpointPlaceOrderArguments *)object;

// Method: storeendpoint.removeStoreOwner
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
+ (id)queryForRemoveStoreOwnerWithObject:(GTLStoreendpointStoreOwner *)object;

// Method: storeendpoint.replaceStoreChatGroup
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
+ (id)queryForReplaceStoreChatGroupWithObject:(GTLStoreendpointStoreChatMemberArray *)object;

// Method: storeendpoint.replaceStoreDiscounts
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
+ (id)queryForReplaceStoreDiscountsWithObject:(GTLStoreendpointStoreDiscountArray *)object;

// Method: storeendpoint.saveChatMessage
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
// Fetches a GTLStoreendpointChatMessage.
+ (id)queryForSaveChatMessageWithObject:(GTLStoreendpointChatMessage *)object;

// Method: storeendpoint.saveChatRoom
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
// Fetches a GTLStoreendpointChatRoom.
+ (id)queryForSaveChatRoomWithObject:(GTLStoreendpointChatRoom *)object;

// Method: storeendpoint.saveOrUpdateOrdersFromPOS
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
+ (id)queryForSaveOrUpdateOrdersFromPOSWithObject:(GTLStoreendpointAsaanLongString *)object
                                          storeId:(long long)storeId
                                        storeName:(NSString *)storeName;

// Method: storeendpoint.saveStore
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
// Fetches a GTLStoreendpointStore.
+ (id)queryForSaveStoreWithObject:(GTLStoreendpointStore *)object;

// Method: storeendpoint.saveStoreDiscount
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
// Fetches a GTLStoreendpointStoreDiscount.
+ (id)queryForSaveStoreDiscountWithObject:(GTLStoreendpointStoreDiscount *)object;

// Method: storeendpoint.saveStoreItemReviews
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
+ (id)queryForSaveStoreItemReviewsWithObject:(GTLStoreendpointItemReviewsArray *)object;

// Method: storeendpoint.saveStoreMenuCombined
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
+ (id)queryForSaveStoreMenuCombinedWithObject:(GTLStoreendpointStoreMenuCombined *)object;

// Method: storeendpoint.saveStoreMenuHierarchy
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
// Fetches a GTLStoreendpointStoreMenuHierarchy.
+ (id)queryForSaveStoreMenuHierarchyWithObject:(GTLStoreendpointStoreMenuHierarchy *)object;

// Method: storeendpoint.saveStoreMenuItem
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
// Fetches a GTLStoreendpointStoreMenuItem.
+ (id)queryForSaveStoreMenuItemWithObject:(GTLStoreendpointStoreMenuItem *)object;

// Method: storeendpoint.saveStoreMenuItemModifier
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
// Fetches a GTLStoreendpointStoreMenuItemModifier.
+ (id)queryForSaveStoreMenuItemModifierWithObject:(GTLStoreendpointStoreMenuItemModifier *)object;

// Method: storeendpoint.saveStoreMenuItemModifierGroup
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
// Fetches a GTLStoreendpointStoreMenuItemModifierGroup.
+ (id)queryForSaveStoreMenuItemModifierGroupWithObject:(GTLStoreendpointStoreMenuItemModifierGroup *)object;

// Method: storeendpoint.saveStoreOrderReview
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
// Fetches a GTLStoreendpointOrderReview.
+ (id)queryForSaveStoreOrderReviewWithObject:(GTLStoreendpointOrderReview *)object;

// Method: storeendpoint.saveStoreOwner
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
// Fetches a GTLStoreendpointStoreOwner.
+ (id)queryForSaveStoreOwnerWithObject:(GTLStoreendpointStoreOwner *)object;

// Method: storeendpoint.saveStorePOSConnection
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
+ (id)queryForSaveStorePOSConnectionWithObject:(GTLStoreendpointStorePOSConnection *)object;

// Method: storeendpoint.saveStoreWaitlistQueueEntry
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
// Fetches a GTLStoreendpointStoreWaitListQueue.
+ (id)queryForSaveStoreWaitlistQueueEntryWithObject:(GTLStoreendpointStoreWaitListQueue *)object;

// Method: storeendpoint.saveStoreWaitlistQueueEntryByStoreEmployee
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
// Fetches a GTLStoreendpointStoreWaitListQueue.
+ (id)queryForSaveStoreWaitlistQueueEntryByStoreEmployeeWithObject:(GTLStoreendpointStoreWaitListQueue *)object
                                                     queuePosition:(NSInteger)queuePosition;

// Method: storeendpoint.saveStoreWaitlistSummary
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
+ (id)queryForSaveStoreWaitlistSummaryWithObject:(GTLStoreendpointStoreWaitlistSummary *)object;

// Method: storeendpoint.updateOrderFromServer
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
// Fetches a GTLStoreendpointStoreOrder.
+ (id)queryForUpdateOrderFromServerWithObject:(GTLStoreendpointStoreOrder *)object;

// Method: storeendpoint.updateStoreCoordinates
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
+ (id)queryForUpdateStoreCoordinates;

// Method: storeendpoint.updateStoreTableGroupMembers
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
+ (id)queryForUpdateStoreTableGroupMembersWithObject:(GTLStoreendpointStoreTableGroupMemberArray *)object;

@end
