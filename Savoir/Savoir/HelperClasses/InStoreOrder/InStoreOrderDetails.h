//
//  InStoreOrderDetails.h
//  Savoir
//
//  Created by Nirav Saraiya on 4/6/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTLStoreendpoint.h"

@interface InStoreOrderDetails : NSObject

@property (strong, nonatomic) GTLStoreendpointStoreTableGroup *selectedTableGroup;
@property (strong, nonatomic) GTLStoreendpointStoreTableGroupMemberCollection *tableGroupMembers;
@property (strong, nonatomic) GTLStoreendpointStoreTableGroupMember *memberMe;
@property (nonatomic) int partySize;
@property (nonatomic) int paymentType; // 1 = PayInFull, 2 = SplitEvenly, 3 = SplitByItem

+ (int)PAYMENT_TYPE_PAYINFULL;
+ (int)PAYMENT_TYPE_SPLITEVENLY;
+ (int)PAYMENT_TYPE_SPLITBYITEM;

@end
