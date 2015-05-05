//
//  TableOrderReceiver.h
//  Savoir
//
//  Created by Nirav Saraiya on 4/10/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTLStoreendpointStoreOrder.h"

@protocol TableOrderReceiver <NSObject>

- (void) changedOrder:(GTLStoreendpointStoreOrder *)order error:(NSError *)error;

@end
