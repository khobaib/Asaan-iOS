//
//  OnlineOrderDetails.h
//  AsaanImprovedUI
//
//  Created by Nirav Saraiya on 12/8/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTLStoreendpoint.h"
#import "GTLUserendpointUserAddress.h"
#import "GTLUserendpointUserCard.h"

@interface OnlineOrderDetails : NSObject

@property (strong, nonatomic) GTLStoreendpointStore *selectedStore;
@property (strong, nonatomic) NSMutableArray *selectedMenuItems; //OnlineOrderSelectedMenuItem
@property (strong, nonatomic) GTLStoreendpointStoreDiscount *selectedDiscount;
@property (nonatomic) int orderType;
@property (nonatomic) int partySize;
@property (strong, nonatomic) NSDate *orderTime;
@property (strong, nonatomic) NSString *specialInstructions;
@end
