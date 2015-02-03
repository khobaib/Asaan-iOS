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
//   GTLQueryStoreendpoint (40 custom class methods, 15 custom properties)

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
@class GTLStoreendpointStore;
@class GTLStoreendpointStoreChatMemberArray;
@class GTLStoreendpointStoreDiscount;
@class GTLStoreendpointStoreDiscountArray;
@class GTLStoreendpointStoreMenuCombined;
@class GTLStoreendpointStoreMenuHierarchy;
@class GTLStoreendpointStoreMenuItem;
@class GTLStoreendpointStoreMenuItemModifier;
@class GTLStoreendpointStoreMenuItemModifierGroup;
@class GTLStoreendpointStoreOwner;
@class GTLStoreendpointStorePOSConnection;

@interface GTLQueryStoreendpoint : GTLQuery

//
// Parameters valid on all methods.
//

// Selector specifying which fields to include in a partial response.
@property (copy) NSString *fields;

//
// Method-specific parameters; see the comments below for more information.
//
@property (assign) NSInteger firstPosition;
@property (assign) NSInteger guestCount;
@property (assign) BOOL isStore;
@property (assign) NSInteger maxResult;
@property (assign) NSInteger menuItemPOSId;
@property (assign) NSInteger menuPOSId;
@property (assign) NSInteger menuType;
@property (assign) long long modifiedDate;
@property (assign) long long orderId;
@property (assign) NSInteger orderMode;
@property (assign) long long roomId;
@property (assign) long long roomOrStoreId;
@property (assign) long long storeId;
@property (copy) NSString *storeName;

#pragma mark -
#pragma mark Service level methods
// These create a GTLQueryStoreendpoint object.

// Method: storeendpoint.getChatMessagesForStoreOrRoom
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
// Fetches a GTLStoreendpointChatMessagesAndUsers.
+ (id)queryForGetChatMessagesForStoreOrRoomWithRoomOrStoreId:(long long)roomOrStoreId
                                                modifiedDate:(long long)modifiedDate
                                                     isStore:(BOOL)isStore
                                               firstPosition:(NSInteger)firstPosition
                                                   maxResult:(NSInteger)maxResult;

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

// Method: storeendpoint.getMenuItemAndStatsForMenu
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
// Fetches a GTLStoreendpointMenuItemAndStatsCollection.
+ (id)queryForGetMenuItemAndStatsForMenuWithStoreId:(long long)storeId
                                          menuPOSId:(NSInteger)menuPOSId
                                      firstPosition:(NSInteger)firstPosition
                                          maxResult:(NSInteger)maxResult;

// Method: storeendpoint.getOrderAndReviewsById
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
// Fetches a GTLStoreendpointOrderAndReviews.
+ (id)queryForGetOrderAndReviewsByIdWithOrderId:(long long)orderId;

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

// Method: storeendpoint.getStoreChatMembers
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
// Fetches a GTLStoreendpointStoreChatTeamCollection.
+ (id)queryForGetStoreChatMembersWithStoreId:(long long)storeId;

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
+ (id)queryForGetStoreMenuHierarchyAndItemsWithStoreId:(long long)storeId
                                              menuType:(NSInteger)menuType
                                             maxResult:(NSInteger)maxResult;

// Method: storeendpoint.getStoreMenuItemModifiers
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
// Fetches a GTLStoreendpointMenuItemModifiersAndGroups.
+ (id)queryForGetStoreMenuItemModifiersWithStoreId:(long long)storeId
                                     menuItemPOSId:(NSInteger)menuItemPOSId;

// Method: storeendpoint.getStoreMenuItems
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
// Fetches a GTLStoreendpointStoreMenuItemCollection.
+ (id)queryForGetStoreMenuItemsWithStoreId:(long long)storeId
                             firstPosition:(NSInteger)firstPosition
                                 maxResult:(NSInteger)maxResult;

// Method: storeendpoint.getStoreMenus
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
// Fetches a GTLStoreendpointStoreMenuHierarchyCollection.
+ (id)queryForGetStoreMenusWithStoreId:(long long)storeId
                         firstPosition:(NSInteger)firstPosition
                             maxResult:(NSInteger)maxResult;

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
+ (id)queryForGetStoreOrdersForCurrentUserAndStoreWithStoreId:(long long)storeId
                                                firstPosition:(NSInteger)firstPosition
                                                    maxResult:(NSInteger)maxResult;

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

// Method: storeendpoint.placeOrder
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
// Fetches a GTLStoreendpointStoreOrder.
+ (id)queryForPlaceOrderWithObject:(GTLStoreendpointAsaanLongString *)object
                           storeId:(long long)storeId
                         orderMode:(NSInteger)orderMode
                        guestCount:(NSInteger)guestCount
                         storeName:(NSString *)storeName;

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

@end
