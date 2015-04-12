//
//  DataProvider.m
//  FluentResourcePaging-example
//
//  Created by Alek Astrom on 2013-12-28.
//  Copyright (c) 2013 Alek Åström. All rights reserved.
//

#import "DataProvider.h"
#import "AWPagedArray.h"

//const NSUInteger DataProviderDefaultPageSize = 3;
//const NSUInteger DataProviderDataCount = 6;

@interface DataProvider () <AWPagedArrayDelegate> @end

@implementation DataProvider {
    AWPagedArray *_pagedArray;
    NSOperationQueue *_operationQueue;
    NSMutableDictionary *_dataLoadingOperations;
}

#pragma mark - Cleanup
- (void)dealloc {
    [_operationQueue.operations makeObjectsPerformSelector:@selector(cancel)];
}

#pragma mark - Initialization
- (instancetype)initWithPageSize:(NSUInteger)pageSize itemCount:(NSUInteger)itemCount {
    
    self = [super init];
    if (self) {
        _pagedArray = [[AWPagedArray alloc] initWithCount:itemCount objectsPerPage:pageSize];
        _pagedArray.delegate = self;
        _dataLoadingOperations = [NSMutableDictionary dictionary];
        _operationQueue = [NSOperationQueue new];
    }
    return self;
}

- (void) setInitialObjects:(NSArray*)objects ForPage:(int)page {
    if (objects.count > 0)
        [_pagedArray setObjects:objects forPage:page];
}

#pragma mark - Accessors
- (NSUInteger)loadedCount {
    return _pagedArray.pages.count*_pagedArray.objectsPerPage;
}
- (NSUInteger)pageSize {
    return _pagedArray.objectsPerPage;
}
- (NSArray *)dataObjects {
    return (NSArray *)_pagedArray;
}

#pragma mark - Other public methods
- (BOOL)isLoadingDataAtIndex:(NSUInteger)index {
    return _dataLoadingOperations[@([_pagedArray pageForIndex:index])] != nil;
}
- (void)loadDataForIndex:(NSUInteger)index {
    [self _setShouldLoadDataForPage:[_pagedArray pageForIndex:index]];
}

#pragma mark - Private methods
- (void)_setShouldLoadDataForPage:(NSUInteger)page {
    
    if (!_pagedArray.pages[@(page)] && !_dataLoadingOperations[@(page)]) {
        // Don't load data if there already is a loading operation in progress
        [self _loadDataForPage:page];
    }
}
- (void)_loadDataForPage:(NSUInteger)page {
    
    NSIndexSet *indexes = [_pagedArray indexSetForPage:page];
    
    NSOperation *loadingOperation = [self _loadingOperationForPage:page indexes:indexes];
    _dataLoadingOperations[@(page)] = loadingOperation;
    
    if ([self.delegate respondsToSelector:@selector(dataProvider:willLoadDataAtIndexes:)]) {
        [self.delegate dataProvider:self willLoadDataAtIndexes:indexes];
    }
    [_operationQueue addOperation:loadingOperation];
}
- (NSOperation *)_loadingOperationForPage:(NSUInteger)page indexes:(NSIndexSet *)indexes {
    
    DataLoadingOperation *operation = [self.delegate getDataLoadingOperationForPage:page indexes:indexes]; //[[StoreLoadingOperation alloc] initWithIndexes:indexes];
    if (operation == nil)
        return nil;
    
    // Remember to not retain self in block since we store the operation
    __weak typeof(self) weakSelf = self;
    __weak typeof(operation) weakOperation = operation;
    operation.completionBlock = ^{
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [weakSelf _dataOperation:weakOperation finishedLoadingForPage:page];
        }];
    };

    return operation;
}
- (void)_preloadNextPageIfNeededForIndex:(NSUInteger)index {
    
    if (!self.shouldLoadAutomatically) {
        return;
    }
    
    NSUInteger currentPage = [_pagedArray pageForIndex:index];
    NSUInteger preloadPage = [_pagedArray pageForIndex:index+self.automaticPreloadMargin];
    
    if (preloadPage > currentPage && preloadPage <= _pagedArray.numberOfPages) {
        [self _setShouldLoadDataForPage:preloadPage];
    }
}
- (void)_dataOperation:(DataLoadingOperation *)operation finishedLoadingForPage:(NSUInteger)page
{
    [_dataLoadingOperations removeObjectForKey:@(page)];
    
    if (operation.dataPage.count > 0)
    {
        [_pagedArray setObjects:operation.dataPage forPage:page];
        
        if ([self.delegate respondsToSelector:@selector(dataProvider:didLoadDataAtIndexes:)])
        {
            [self.delegate dataProvider:self didLoadDataAtIndexes:operation.indexes];
        }
    } //<--
}

#pragma mark - Paged array delegate
- (void)pagedArray:(AWPagedArray *)pagedArray willAccessIndex:(NSUInteger)index returnObject:(__autoreleasing id *)returnObject {

    if ([*returnObject isKindOfClass:[NSNull class]] && self.shouldLoadAutomatically) {
        [self _setShouldLoadDataForPage:[pagedArray pageForIndex:index]];
    } else {
        [self _preloadNextPageIfNeededForIndex:index];
    }
}

@end
