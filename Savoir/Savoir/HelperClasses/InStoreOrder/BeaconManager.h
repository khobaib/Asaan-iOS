//
//  BeaconManager.h
//  Savoir
//
//  Created by Nirav Saraiya on 4/24/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InStoreUtils.h"

@interface BeaconManager : NSObject

@property (strong, nonatomic) InStoreUtils *inStoreUtils;

- (void) startRegionMonitoring;

@end
