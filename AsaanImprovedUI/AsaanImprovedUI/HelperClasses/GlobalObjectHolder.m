//
//  GlobalObjectHolder.m
//  AsaanImprovedUI
//
//  Created by Nirav Saraiya on 12/7/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import "GlobalObjectHolder.h"

@implementation GlobalObjectHolder
@synthesize orderInProgress = _orderInProgress;

- (OnlineOrderDetails *)createOrderInProgress {
    
    if(_orderInProgress == nil)
        _orderInProgress = [[OnlineOrderDetails alloc]init];
    return _orderInProgress;
}

- (void) removeOrderInProgress { _orderInProgress = nil; }

@end
