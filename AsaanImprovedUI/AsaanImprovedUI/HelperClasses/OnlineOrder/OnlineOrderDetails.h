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
@property (strong, nonatomic) GTLUserendpointUserAddress *savedUserAddress;
@property (strong, nonatomic) GTLUserendpointUserCard *savedUserCard;
@property (strong, nonatomic) NSMutableArray *selectedMenuItems; //OnlineOrderSelectedMenuItem
@property (nonatomic) int orderType;
@property (nonatomic) NSInteger partySize;
@property (nonatomic) NSDate *orderTime;
@end
