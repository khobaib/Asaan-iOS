//
//  OnlineOrderSelectedMenuItem.h
//  AsaanImprovedUI
//
//  Created by Nirav Saraiya on 12/8/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTLStoreendpointStore.h"
#import "GTLStoreendpointStoreMenuItem.h"
#import "GTLStoreendpointMenuItemModifiersAndGroups.h"

@interface OnlineOrderSelectedMenuItem : NSObject
@property (strong, nonatomic) GTLStoreendpointStore *selectedStore;
@property (strong, nonatomic) GTLStoreendpointStoreMenuItem *selectedItem;
@property (strong, nonatomic) GTLStoreendpointMenuItemModifiersAndGroups *allModifiersAndGroups;
@property (strong, nonatomic) NSMutableArray *selectedModifierGroups; //Array of OnlineOrderSelectedModifierGroup
@property NSUInteger price;
@property NSUInteger amount;
@property NSUInteger qty;
@property NSString *specialInstructions;
@end
