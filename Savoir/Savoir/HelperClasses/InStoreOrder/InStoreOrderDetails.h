//
//  InStoreOrderDetails.h
//  Savoir
//
//  Created by Nirav Saraiya on 4/6/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTLStoreendpoint.h"
#import "InStoreOrderReceiver.h"

@interface InStoreOrderDetails : NSObject

@property (strong, nonatomic) GTLStoreendpointStore *selectedStore;
@property (strong, nonatomic) GTLStoreendpointStoreOrderAndTeamDetails *teamAndOrderDetails;
@property (strong, nonatomic) GTLStoreendpointStoreDiscount *selectedDiscount;
@property (strong, nonatomic) GTLStoreendpointStoreTableGroupCollection *openGroups;
@property (nonatomic) int partySize;
@property (nonatomic) int paymentType; // 1 = PayInFull, 2 = SplitEvenly, 3 = SplitByItem

+ (int)PAYMENT_TYPE_PAYINFULL;
+ (int)PAYMENT_TYPE_SPLITEVENLY;
+ (int)PAYMENT_TYPE_SPLITBYITEM;

- (void) createGroup:(id <InStoreOrderReceiver>)receiver;
- (void) joinGroup:(GTLStoreendpointStoreTableGroup *)tableGroup receiver:(id <InStoreOrderReceiver>)receiver;
- (void) getStoreOrderDetails:(id <InStoreOrderReceiver>)receiver;
- (void) getOpenGroups:(id <InStoreOrderReceiver>)receiver;
- (void) updateStoreTableGroupMembers:(NSMutableDictionary *)changedMembers receiver:(id <InStoreOrderReceiver>)receiver;
- (void) clearCurrentOrder;

@end
