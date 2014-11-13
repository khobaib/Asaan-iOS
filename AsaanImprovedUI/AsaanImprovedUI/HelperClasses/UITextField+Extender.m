//
//  UITextField+Extender.m
//  AsaanImprovedUI
//
//  Created by Nirav Saraiya on 11/12/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import "UITextField+Extender.h"
#import <objc/runtime.h>

static char defaultHashKey;

@implementation UITextField (Extender)

- (UITextField*) nextTextField {
    return objc_getAssociatedObject(self, &defaultHashKey);
}

- (void) setNextTextField:(UITextField *)nextTextField{
    objc_setAssociatedObject(self, &defaultHashKey, nextTextField, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end
