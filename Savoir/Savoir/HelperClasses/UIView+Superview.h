//
//  UIView+Superview.h
//  Savoir
//
//  Created by Nirav Saraiya on 2/23/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Superview)

- (UIView *)findSuperViewWithClass:(Class)superViewClass;

@end
