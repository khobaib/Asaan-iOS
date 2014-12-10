//
//  OnlineOrderSelectedModifierGroup.m
//  AsaanImprovedUI
//
//  Created by Nirav Saraiya on 12/8/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import "OnlineOrderSelectedModifierGroup.h"

@implementation OnlineOrderSelectedModifierGroup

- (id)copyWithZone:(NSZone *)zone
{
    OnlineOrderSelectedModifierGroup *copy = [[[self class] alloc] init];
    
    if (copy)
    {
        // Copy NSObject subclasses
        copy.modifierGroup = self.modifierGroup;
        copy.modifiers = self.modifiers;
        copy.selectedModifierIndexes = [[NSMutableArray alloc]initWithArray:self.selectedModifierIndexes copyItems:YES];
    }
    
    return copy;
}
@end
