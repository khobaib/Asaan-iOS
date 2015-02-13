//
//  AddToWaitListReceiver.h
//  AsaanImprovedUI
//
//  Created by Nirav Saraiya on 2/12/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTLStoreendpointStoreWaitListQueue.h"

@protocol AddToWaitListReceiver <NSObject>

- (void) setQueueEntry:(GTLStoreendpointStoreWaitListQueue *)waitListQueueEntry;

@end
