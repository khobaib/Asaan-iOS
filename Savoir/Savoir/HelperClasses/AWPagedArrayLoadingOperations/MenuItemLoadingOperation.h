//
//  MenuItemLoadingOperation.h
//  Savoir
//
//  Created by Nirav Saraiya on 11/24/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import "DataLoadingOperation.h"

@interface MenuItemLoadingOperation : DataLoadingOperation

- (instancetype)initWithIndexes:(NSIndexSet *)indexes storeId:(long long)storeId menuPOSId:(int)menuPOSId;

@end
