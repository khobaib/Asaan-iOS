//
//  InStoreOrderDetails.m
//  Savoir
//
//  Created by Nirav Saraiya on 4/6/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import "InStoreOrderDetails.h"

@implementation InStoreOrderDetails

+ (int)PAYMENT_TYPE_PAYINFULL { return 1; }
+ (int)PAYMENT_TYPE_SPLITEVENLY { return 2; }
+ (int)PAYMENT_TYPE_SPLITBYITEM  { return 3; }

@end
