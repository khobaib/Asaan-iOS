/* This file was generated by the ServiceGenerator.
 * The ServiceGenerator is Copyright (c) 2014 Google Inc.
 */

//
//  GTLQueryStoreendpoint.m
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   storeendpoint/v1
// Description:
//   This is an API
// Classes:
//   GTLQueryStoreendpoint (21 custom class methods, 7 custom properties)

#import "GTLQueryStoreendpoint.h"

#import "GTLStoreendpointMenuItemModifiersAndGroups.h"
#import "GTLStoreendpointMenusAndMenuItems.h"
#import "GTLStoreendpointOrderItemsAndCustomers.h"
#import "GTLStoreendpointStore.h"
#import "GTLStoreendpointStoreCollection.h"
#import "GTLStoreendpointStoreImage.h"
#import "GTLStoreendpointStoreImageCollection.h"
#import "GTLStoreendpointStoreMenuHierarchy.h"
#import "GTLStoreendpointStoreMenuHierarchyCollection.h"
#import "GTLStoreendpointStoreMenuItem.h"
#import "GTLStoreendpointStoreMenuItemCollection.h"
#import "GTLStoreendpointStoreMenuItemModifier.h"
#import "GTLStoreendpointStoreMenuItemModifierGroup.h"
#import "GTLStoreendpointStoreOwner.h"
#import "GTLStoreendpointStoreOwnerCollection.h"
#import "GTLStoreendpointStorePOSConnection.h"
#import "GTLStoreendpointStoreSummaryStats.h"
#import "GTLStoreendpointStoreSummaryStatsCollection.h"

@implementation GTLQueryStoreendpoint

@dynamic fields, firstPosition, maxResult, menuItemPOSId, menuPOSId, menuType,
         storeId;

#pragma mark -
#pragma mark Service level methods
// These create a GTLQueryStoreendpoint object.

+ (id)queryForGetStatsForAllStoresWithFirstPosition:(NSInteger)firstPosition
                                          maxResult:(NSInteger)maxResult {
  NSString *methodName = @"storeendpoint.getStatsForAllStores";
  GTLQueryStoreendpoint *query = [self queryWithMethodName:methodName];
  query.firstPosition = firstPosition;
  query.maxResult = maxResult;
  query.expectedObjectClass = [GTLStoreendpointStoreSummaryStatsCollection class];
  return query;
}

+ (id)queryForGetStoreImagesWithStoreId:(long long)storeId
                          firstPosition:(NSInteger)firstPosition
                              maxResult:(NSInteger)maxResult {
  NSString *methodName = @"storeendpoint.getStoreImages";
  GTLQueryStoreendpoint *query = [self queryWithMethodName:methodName];
  query.storeId = storeId;
  query.firstPosition = firstPosition;
  query.maxResult = maxResult;
  query.expectedObjectClass = [GTLStoreendpointStoreImageCollection class];
  return query;
}

+ (id)queryForGetStoreMenuHierarchyAndItemsWithStoreId:(long long)storeId
                                              menuType:(long long)menuType
                                             maxResult:(NSInteger)maxResult {
  NSString *methodName = @"storeendpoint.getStoreMenuHierarchyAndItems";
  GTLQueryStoreendpoint *query = [self queryWithMethodName:methodName];
  query.storeId = storeId;
  query.menuType = menuType;
  query.maxResult = maxResult;
  query.expectedObjectClass = [GTLStoreendpointMenusAndMenuItems class];
  return query;
}

+ (id)queryForGetStoreMenuItemModifiersWithStoreId:(long long)storeId
                                     menuItemPOSId:(long long)menuItemPOSId {
  NSString *methodName = @"storeendpoint.getStoreMenuItemModifiers";
  GTLQueryStoreendpoint *query = [self queryWithMethodName:methodName];
  query.storeId = storeId;
  query.menuItemPOSId = menuItemPOSId;
  query.expectedObjectClass = [GTLStoreendpointMenuItemModifiersAndGroups class];
  return query;
}

+ (id)queryForGetStoreMenuItemsWithStoreId:(long long)storeId
                             firstPosition:(NSInteger)firstPosition
                                 maxResult:(NSInteger)maxResult {
  NSString *methodName = @"storeendpoint.getStoreMenuItems";
  GTLQueryStoreendpoint *query = [self queryWithMethodName:methodName];
  query.storeId = storeId;
  query.firstPosition = firstPosition;
  query.maxResult = maxResult;
  query.expectedObjectClass = [GTLStoreendpointStoreMenuItemCollection class];
  return query;
}

+ (id)queryForGetStoreMenuItemsForMenuWithStoreId:(long long)storeId
                                        menuPOSId:(long long)menuPOSId
                                    firstPosition:(NSInteger)firstPosition
                                        maxResult:(NSInteger)maxResult {
  NSString *methodName = @"storeendpoint.getStoreMenuItemsForMenu";
  GTLQueryStoreendpoint *query = [self queryWithMethodName:methodName];
  query.storeId = storeId;
  query.menuPOSId = menuPOSId;
  query.firstPosition = firstPosition;
  query.maxResult = maxResult;
  query.expectedObjectClass = [GTLStoreendpointStoreMenuItemCollection class];
  return query;
}

+ (id)queryForGetStoreMenusWithStoreId:(long long)storeId
                         firstPosition:(NSInteger)firstPosition
                             maxResult:(NSInteger)maxResult {
  NSString *methodName = @"storeendpoint.getStoreMenus";
  GTLQueryStoreendpoint *query = [self queryWithMethodName:methodName];
  query.storeId = storeId;
  query.firstPosition = firstPosition;
  query.maxResult = maxResult;
  query.expectedObjectClass = [GTLStoreendpointStoreMenuHierarchyCollection class];
  return query;
}

+ (id)queryForGetStoreOwnersWithStoreId:(long long)storeId {
  NSString *methodName = @"storeendpoint.getStoreOwners";
  GTLQueryStoreendpoint *query = [self queryWithMethodName:methodName];
  query.storeId = storeId;
  query.expectedObjectClass = [GTLStoreendpointStoreOwnerCollection class];
  return query;
}

+ (id)queryForGetStoresWithFirstPosition:(NSInteger)firstPosition
                               maxResult:(NSInteger)maxResult {
  NSString *methodName = @"storeendpoint.getStores";
  GTLQueryStoreendpoint *query = [self queryWithMethodName:methodName];
  query.firstPosition = firstPosition;
  query.maxResult = maxResult;
  query.expectedObjectClass = [GTLStoreendpointStoreCollection class];
  return query;
}

+ (id)queryForGetStoreStatsWithStoreId:(long long)storeId {
  NSString *methodName = @"storeendpoint.getStoreStats";
  GTLQueryStoreendpoint *query = [self queryWithMethodName:methodName];
  query.storeId = storeId;
  query.expectedObjectClass = [GTLStoreendpointStoreSummaryStats class];
  return query;
}

+ (id)queryForPlaceOrderWithObject:(GTLStoreendpointOrderItemsAndCustomers *)object {
  if (object == nil) {
    GTL_DEBUG_ASSERT(object != nil, @"%@ got a nil object", NSStringFromSelector(_cmd));
    return nil;
  }
  NSString *methodName = @"storeendpoint.placeOrder";
  GTLQueryStoreendpoint *query = [self queryWithMethodName:methodName];
  query.bodyObject = object;
  query.expectedObjectClass = [GTLStoreendpointStoreMenuItem class];
  return query;
}

+ (id)queryForRemoveStoreImageWithObject:(GTLStoreendpointStoreImage *)object {
  if (object == nil) {
    GTL_DEBUG_ASSERT(object != nil, @"%@ got a nil object", NSStringFromSelector(_cmd));
    return nil;
  }
  NSString *methodName = @"storeendpoint.removeStoreImage";
  GTLQueryStoreendpoint *query = [self queryWithMethodName:methodName];
  query.bodyObject = object;
  return query;
}

+ (id)queryForRemoveStoreOwnerWithObject:(GTLStoreendpointStoreOwner *)object {
  if (object == nil) {
    GTL_DEBUG_ASSERT(object != nil, @"%@ got a nil object", NSStringFromSelector(_cmd));
    return nil;
  }
  NSString *methodName = @"storeendpoint.removeStoreOwner";
  GTLQueryStoreendpoint *query = [self queryWithMethodName:methodName];
  query.bodyObject = object;
  return query;
}

+ (id)queryForSaveStoreWithObject:(GTLStoreendpointStore *)object {
  if (object == nil) {
    GTL_DEBUG_ASSERT(object != nil, @"%@ got a nil object", NSStringFromSelector(_cmd));
    return nil;
  }
  NSString *methodName = @"storeendpoint.saveStore";
  GTLQueryStoreendpoint *query = [self queryWithMethodName:methodName];
  query.bodyObject = object;
  query.expectedObjectClass = [GTLStoreendpointStore class];
  return query;
}

+ (id)queryForSaveStoreImageWithObject:(GTLStoreendpointStoreImage *)object {
  if (object == nil) {
    GTL_DEBUG_ASSERT(object != nil, @"%@ got a nil object", NSStringFromSelector(_cmd));
    return nil;
  }
  NSString *methodName = @"storeendpoint.saveStoreImage";
  GTLQueryStoreendpoint *query = [self queryWithMethodName:methodName];
  query.bodyObject = object;
  query.expectedObjectClass = [GTLStoreendpointStoreImage class];
  return query;
}

+ (id)queryForSaveStoreMenuHierarchyWithObject:(GTLStoreendpointStoreMenuHierarchy *)object {
  if (object == nil) {
    GTL_DEBUG_ASSERT(object != nil, @"%@ got a nil object", NSStringFromSelector(_cmd));
    return nil;
  }
  NSString *methodName = @"storeendpoint.saveStoreMenuHierarchy";
  GTLQueryStoreendpoint *query = [self queryWithMethodName:methodName];
  query.bodyObject = object;
  query.expectedObjectClass = [GTLStoreendpointStoreMenuHierarchy class];
  return query;
}

+ (id)queryForSaveStoreMenuItemWithObject:(GTLStoreendpointStoreMenuItem *)object {
  if (object == nil) {
    GTL_DEBUG_ASSERT(object != nil, @"%@ got a nil object", NSStringFromSelector(_cmd));
    return nil;
  }
  NSString *methodName = @"storeendpoint.saveStoreMenuItem";
  GTLQueryStoreendpoint *query = [self queryWithMethodName:methodName];
  query.bodyObject = object;
  query.expectedObjectClass = [GTLStoreendpointStoreMenuItem class];
  return query;
}

+ (id)queryForSaveStoreMenuItemModifierWithObject:(GTLStoreendpointStoreMenuItemModifier *)object {
  if (object == nil) {
    GTL_DEBUG_ASSERT(object != nil, @"%@ got a nil object", NSStringFromSelector(_cmd));
    return nil;
  }
  NSString *methodName = @"storeendpoint.saveStoreMenuItemModifier";
  GTLQueryStoreendpoint *query = [self queryWithMethodName:methodName];
  query.bodyObject = object;
  query.expectedObjectClass = [GTLStoreendpointStoreMenuItemModifier class];
  return query;
}

+ (id)queryForSaveStoreMenuItemModifierGroupWithObject:(GTLStoreendpointStoreMenuItemModifierGroup *)object {
  if (object == nil) {
    GTL_DEBUG_ASSERT(object != nil, @"%@ got a nil object", NSStringFromSelector(_cmd));
    return nil;
  }
  NSString *methodName = @"storeendpoint.saveStoreMenuItemModifierGroup";
  GTLQueryStoreendpoint *query = [self queryWithMethodName:methodName];
  query.bodyObject = object;
  query.expectedObjectClass = [GTLStoreendpointStoreMenuItemModifierGroup class];
  return query;
}

+ (id)queryForSaveStoreOwnerWithObject:(GTLStoreendpointStoreOwner *)object {
  if (object == nil) {
    GTL_DEBUG_ASSERT(object != nil, @"%@ got a nil object", NSStringFromSelector(_cmd));
    return nil;
  }
  NSString *methodName = @"storeendpoint.saveStoreOwner";
  GTLQueryStoreendpoint *query = [self queryWithMethodName:methodName];
  query.bodyObject = object;
  query.expectedObjectClass = [GTLStoreendpointStoreOwner class];
  return query;
}

+ (id)queryForSaveStorePOSConnectionWithObject:(GTLStoreendpointStorePOSConnection *)object {
  if (object == nil) {
    GTL_DEBUG_ASSERT(object != nil, @"%@ got a nil object", NSStringFromSelector(_cmd));
    return nil;
  }
  NSString *methodName = @"storeendpoint.saveStorePOSConnection";
  GTLQueryStoreendpoint *query = [self queryWithMethodName:methodName];
  query.bodyObject = object;
  return query;
}

@end