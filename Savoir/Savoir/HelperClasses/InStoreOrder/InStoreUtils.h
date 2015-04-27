//
//  InStoreUtils.h
//  Savoir
//
//  Created by Nirav Saraiya on 4/24/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InStoreUtils : NSObject

+ (void) getStoreForBeaconId:(long)beaconId;
+ (void) startInStoreMode;
+ (void) startServerMode;

@end
