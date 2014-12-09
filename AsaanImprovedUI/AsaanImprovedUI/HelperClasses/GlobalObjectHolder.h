//
//  GlobalObjectHolder.h
//  AsaanImprovedUI
//
//  Created by Nirav Saraiya on 12/7/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OnlineOrderDetails.h"

@interface GlobalObjectHolder : NSObject
@property (strong, nonatomic) OnlineOrderDetails *orderInProgress;

- (OnlineOrderDetails *)createOrderInProgress;
- (void) removeOrderInProgress;

@end
