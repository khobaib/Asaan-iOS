//
//  StoreOrderLoadingOperation.h
//  Savoir
//
//  Created by Nirav Saraiya on 1/20/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import "DataLoadingOperation.h"

@interface OrderForStoreLoadingOperation : DataLoadingOperation

- (instancetype)initWithIndexes:(NSIndexSet *)indexes storeId:(long)storeId;

@end
