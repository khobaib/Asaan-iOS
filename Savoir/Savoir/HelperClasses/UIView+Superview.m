//
//  UIView+Superview.m
//  Savoir
//
//  Created by Nirav Saraiya on 2/23/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import "UIView+Superview.h"

@implementation UIView (Superview)

- (UIView *)findSuperViewWithClass:(Class)superViewClass
{
    UIView *superView = self.superview;
    
    while (nil != superView)
    {
        if ([superView isKindOfClass:superViewClass])
            return superView;
        else
            superView = superView.superview;
    }
    return nil;
}

@end
