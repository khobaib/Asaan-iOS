//
//  ReviewLoadingOperation.m
//  Savoir
//
//  Created by Nirav Saraiya on 2/5/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import "ReviewLoadingOperation.h"

#import <Foundation/Foundation.h>
#import "GTMHTTPFetcher.h"
#import "AppDelegate.h"
#import "InlineCalls.h"
#import "UtilCalls.h"
#import "Constants.h"

@interface ReviewLoadingOperation()
@property (nonatomic) Boolean bDataLoaded;
@end

@implementation ReviewLoadingOperation
@synthesize bDataLoaded = _bDataLoaded;

- (instancetype)initWithIndexes:(NSIndexSet *)indexes storeId:(long long)storeId
{
    
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
            GTLQueryStoreendpoint *query=[GTLQueryStoreendpoint queryForGetOrderReviewsForStoreWithStoreId:storeId firstPosition:firstPosition maxResult:maxResult];
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            dic[USER_AUTH_TOKEN_HEADER_NAME] = [UtilCalls getAuthTokenForCurrentUser];
            [query setAdditionalHTTPHeaders:dic];
            
            [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLStoreendpointOrderReviewListAndCount *object,NSError *error){
                if(!error)
                    [weakSelf setDataPage:[object.reviews mutableCopy]];
                else
                    NSLog(@"OrderForStoreLoadingOperation Error:%@",[error userInfo][@"error"]);
                
                weakSelf.bDataLoaded = true;
            }];
            
            while (weakSelf.bDataLoaded == false)
                [NSThread sleepForTimeInterval:DataLoadingOperationDuration];
            
        }];
    }
    
    return self;
}

@end