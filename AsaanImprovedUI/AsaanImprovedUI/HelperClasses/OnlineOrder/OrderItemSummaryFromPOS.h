//
//  OrderItemSummaryFromPOS.h
//  AsaanImprovedUI
//
//  Created by Nirav Saraiya on 1/21/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderItemSummaryFromPOS : NSObject

@property long entryId;
@property long posMenuItemId;
@property long parentEntryId;
@property int position;
@property int qty;
@property double price;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *desc;

@end
