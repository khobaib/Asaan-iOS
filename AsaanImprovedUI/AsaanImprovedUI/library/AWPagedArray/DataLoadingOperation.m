//
//  DataLoadingOperation.m
//  FluentResourcePaging-example
//
//  Created by Alek Astrom on 2014-04-11.
//  Copyright (c) 2014 Alek Åström. All rights reserved.
//

#import "DataLoadingOperation.h"

const NSTimeInterval DataLoadingOperationDuration = 0.3;

@implementation DataLoadingOperation
@synthesize dataPage = _dataPage;
@synthesize indexes = _indexes;

- (instancetype)initWithIndexes:(NSIndexSet *)indexes{

    self = [super init];
    
    return self;
}
@end
