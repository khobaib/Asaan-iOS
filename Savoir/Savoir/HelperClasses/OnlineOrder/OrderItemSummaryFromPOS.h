//
//  OrderItemSummaryFromPOS.h
//  Savoir
//
//  Created by Nirav Saraiya on 1/21/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderItemSummaryFromPOS : NSObject

@property int entryId;
@property int posMenuItemId;
@property int parentEntryId;
@property int position;
@property int qty;
@property float price;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *desc;
@property short like;

@end
