//
//  MenuSegmentHolder.h
//  Savoir
//
//  Created by Nirav Saraiya on 11/25/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//
#import "GTLStoreendpoint.h"
#import "DataProvider.h"

@interface MenuSegmentHolder : NSObject
@property (strong, nonatomic) GTLStoreendpointStoreMenuHierarchy *menu;
@property (strong, nonatomic) NSMutableArray *subMenus;
@property (strong, nonatomic) DataProvider *provider;
@property NSIndexPath *topRowIndex;
@end
