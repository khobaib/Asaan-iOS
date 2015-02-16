//
//  MenuModifierTableViewController.h
//  Savoir
//
//  Created by Nirav Saraiya on 12/7/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTLStoreendpointStoreMenuItemModifierGroup.h"
#import "GTLStoreendpointStoreMenuItemModifier.h"

@interface MenuModifierTableViewController : UITableViewController

@property (strong, nonatomic) NSMutableArray *allModifiers;
@property (strong, nonatomic) GTLStoreendpointStoreMenuItemModifierGroup *modifierGroup;
@property (strong, nonatomic) NSMutableArray *allSelections; // Array of NSNumber

@end
