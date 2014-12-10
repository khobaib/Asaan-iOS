//
//  OnlineOrderSelectedModifierGroup.h
//  AsaanImprovedUI
//
//  Created by Nirav Saraiya on 12/8/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTLStoreendpointStoreMenuItemModifierGroup.h"
#import "GTLStoreendpointStoreMenuItemModifier.h"

@interface OnlineOrderSelectedModifierGroup : NSObject<NSCopying>
@property (strong, nonatomic) GTLStoreendpointStoreMenuItemModifierGroup *modifierGroup;
@property (strong, nonatomic) NSArray *modifiers;
@property (strong, nonatomic) NSMutableArray *selectedModifierIndexes;
@end
