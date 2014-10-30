//
//  DataCommunicator.h
//  Asaan
//
//  Created by MC MINI on 10/30/14.
//  Copyright (c) 2014 Tech Fiesta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTLStoreendpoint.h"

@interface DataCommunicator : NSObject

+(void)setSelectedStore:(id)store;
+(id)getSelectedStore;
@end
