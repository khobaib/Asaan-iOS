//
//  InStoreOrderReceiver.h
//  Savoir
//
//  Created by Nirav Saraiya on 4/16/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol InStoreOrderReceiver <NSObject>

- (void) orderChanged:(NSError *)error;
- (void) openGroupsChanged:(NSError *)error;
@end
