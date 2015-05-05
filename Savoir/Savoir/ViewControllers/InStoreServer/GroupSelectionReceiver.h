//
//  GroupSelectionReceiver.h
//  Savoir
//
//  Created by Nirav Saraiya on 4/20/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTLStoreendpointStoreTableGroup.h"

@protocol GroupSelectionReceiver <NSObject>

- (void) changedGroupSelection:(GTLStoreendpointStoreTableGroup *)tableGroup error:(NSError *)error;

@end
