//
//  StoreOrderLoadingOperation.m
//  AsaanImprovedUI
//
//  Created by Nirav Saraiya on 1/20/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import "OrderForStoreLoadingOperation.h"
#import <Foundation/Foundation.h>
#import "GTMHTTPFetcher.h"
#import "AppDelegate.h"
#import "UtilCalls.h"

@interface OrderForStoreLoadingOperation()
@property (nonatomic) Boolean bDataLoaded;
@end

@implementation OrderForStoreLoadingOperation
@synthesize bDataLoaded = _bDataLoaded;

const NSTimeInterval DataLoadingOperationDuration2_1 = 0.3;

- (instancetype)initWithIndexes:(NSIndexSet *)indexes storeId:(long)storeId{
    
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
            GTLQueryStoreendpoint *query=[GTLQueryStoreendpoint queryForGetStoreOrdersForCurrentUserAndStoreWithStoreId:storeId firstPosition:firstPosition maxResult:maxResult];
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            dic[USER_AUTH_TOKEN_HEADER_NAME] = [UtilCalls getAuthTokenForCurrentUser];
            [query setAdditionalHTTPHeaders:dic];
            
            [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLStoreendpointStoreOrderListAndCount *object,NSError *error){
                if(!error)
                    [weakSelf setDataPage:[object.orders mutableCopy]];
                else
                    NSLog(@"OrderForStoreLoadingOperation Error:%@",[error userInfo]);
                
                weakSelf.bDataLoaded = true;
            }];
            
            while (weakSelf.bDataLoaded == false)
                [NSThread sleepForTimeInterval:DataLoadingOperationDuration2_1];
            
        }];
    }
    
    return self;
}

@end