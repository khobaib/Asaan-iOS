//
//  DataCommunicator.m
//  Asaan
//
//  Created by MC MINI on 10/30/14.
//  Copyright (c) 2014 Tech Fiesta. All rights reserved.
//

#import "DataCommunicator.h"

@implementation DataCommunicator

static id selectedStore;

+(void)setSelectedStore:(id)store{
    selectedStore=store;
}
+(id)getSelectedStore{
    
    
    return selectedStore;
}
@end
