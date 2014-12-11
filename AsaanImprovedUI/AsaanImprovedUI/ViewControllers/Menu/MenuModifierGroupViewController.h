//
//  MenuModifierGroupViewController.h
//  AsaanImprovedUI
//
//  Created by Nirav Saraiya on 12/7/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTLStoreendpointStoreMenuItem.h"
#import "GTLStoreendpoint.h"
#import "GTLUserendpointUserAddress.h"
#import "GTLUserendpointUserCard.h"
#import "OnlineOrderSelectedMenuItem.h"

@interface MenuModifierGroupViewController : UIViewController
@property (strong, nonatomic) GTLStoreendpointStore *selectedStore;
@property (strong, nonatomic) GTLStoreendpointStoreMenuItem *selectedMenuItem;
@property (nonatomic) int orderType;
@property (nonatomic) NSInteger partySize;
@property (nonatomic) NSDate *orderTime;

@property (nonatomic) Boolean bInEditMode;
@property (nonatomic) NSUInteger selectedIndex;
@property (strong, nonatomic) NSMutableArray *allModifiersForSelectedGroup;

@end
