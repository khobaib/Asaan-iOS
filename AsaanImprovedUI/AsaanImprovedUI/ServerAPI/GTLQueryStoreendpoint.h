/* This file was generated by the ServiceGenerator.
 * The ServiceGenerator is Copyright (c) 2014 Google Inc.
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
//   GTLQueryStoreendpoint (21 custom class methods, 9 custom properties)

#if GTL_BUILT_AS_FRAMEWORK
  #import "GTL/GTLQuery.h"
#else
  #import "GTLQuery.h"
#endif

@class GTLStoreendpointStore;
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
@property (assign) NSInteger maxResult;
@property (assign) NSInteger menuItemPOSId;
@property (assign) NSInteger menuPOSId;
@property (assign) NSInteger menuType;
@property (copy) NSString *order;
@property (assign) NSInteger orderMode;
@property (assign) long long storeId;

#pragma mark -
#pragma mark Service level methods
// These create a GTLQueryStoreendpoint object.

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

// Method: storeendpoint.getStoreMenuItemsForMenu
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
// Fetches a GTLStoreendpointStoreMenuItemCollection.
+ (id)queryForGetStoreMenuItemsForMenuWithStoreId:(long long)storeId
                                        menuPOSId:(NSInteger)menuPOSId
                                    firstPosition:(NSInteger)firstPosition
                                        maxResult:(NSInteger)maxResult;

// Method: storeendpoint.getStoreMenus
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
// Fetches a GTLStoreendpointStoreMenuHierarchyCollection.
+ (id)queryForGetStoreMenusWithStoreId:(long long)storeId
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

// Method: storeendpoint.placeOrder
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
// Fetches a GTLStoreendpointStoreOrder.
+ (id)queryForPlaceOrderWithStoreId:(long long)storeId
                          orderMode:(NSInteger)orderMode
                              order:(NSString *)order;

// Method: storeendpoint.removeStoreOwner
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
+ (id)queryForRemoveStoreOwnerWithObject:(GTLStoreendpointStoreOwner *)object;

// Method: storeendpoint.saveStore
//  Authorization scope(s):
//   kGTLAuthScopeStoreendpointUserinfoEmail
// Fetches a GTLStoreendpointStore.
+ (id)queryForSaveStoreWithObject:(GTLStoreendpointStore *)object;

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