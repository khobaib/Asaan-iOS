//
//  Constants.m
//  Savoir
//
//  Created by Nirav Saraiya on 1/20/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import <Foundation/Foundation.h>

const NSUInteger FluentPagingTablePreloadMargin = 5;
const NSUInteger FluentPagingTablePageSize = 20;
const NSTimeInterval DataLoadingOperationDuration = 0.3;

const int WAITING = 0;
const int TABLE_IS_READY = 1;
const int CLOSED_SEATED = 2;
const int CLOSED_CANCELLED_BY_CUSTOMER = 3;
const int CLOSED_CANCELLED_BY_STORE = 4;