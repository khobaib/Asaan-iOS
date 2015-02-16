//
//  OrderLoadingOperation.m
//  Savoir
//
//  Created by Nirav Saraiya on 1/20/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import "OrderLoadingOperation.h"
#import <Foundation/Foundation.h>
#import "GTMHTTPFetcher.h"
#import "AppDelegate.h"
#import "Constants.h"

@interface OrderLoadingOperation()
@property (nonatomic) Boolean bDataLoaded;
@end

@implementation OrderLoadingOperation
@synthesize bDataLoaded = _bDataLoaded;

- (instancetype)initWithIndexes:(NSIndexSet *)indexes{
    
    self = [super initWithIndexes:indexes];
    
    self.indexes = indexes;
    
    int firstPosition = (int)indexes.firstIndex;
    int maxResult = (int)indexes.count;
    
    if (self)
    {
        __weak __typeof(self) weakSelf = self;
        _bDataLoaded = false;
        [self addExecutionBlock:^{
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
            GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
            GTLQueryStoreendpoint *query=[GTLQueryStoreendpoint queryForGetStoreOrdersForCurrentUserWithFirstPosition:firstPosition maxResult:maxResult];
            
            [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLStoreendpointStoreOrderListAndCount *object,NSError *error){
                if(!error)
                    [weakSelf setDataPage:[object.orders mutableCopy]];
                else
                    NSLog(@"OrderLoadingOperation Error:%@",[error userInfo]);
                
                weakSelf.bDataLoaded = true;
            }];
            
            while (weakSelf.bDataLoaded == false)
                [NSThread sleepForTimeInterval:DataLoadingOperationDuration];
            
        }];
    }
    
    return self;
}

@end