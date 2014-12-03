//
//  StoreLoadingOperation.m
//  AsaanImprovedUI
//
//  Created by Nirav Saraiya on 11/21/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StoreLoadingOperation.h"
#import "GTMHTTPFetcher.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "InlineCalls.h"

@interface StoreLoadingOperation()
@property (nonatomic) Boolean bDataLoaded;
@end

@implementation StoreLoadingOperation
@synthesize bDataLoaded = _bDataLoaded;

const NSTimeInterval DataLoadingOperationDuration2 = 0.3;

- (instancetype)initWithIndexes:(NSIndexSet *)indexes{
    
    self = [super initWithIndexes:indexes];
    
    self.indexes = indexes;

    if (self)
    {
        typeof(self) weakSelf = self;
        _bDataLoaded = false;
        [self addExecutionBlock:^{
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
            GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
            int firstPosition = indexes.firstIndex;
            int maxResult = indexes.count;
            GTLQueryStoreendpoint *query=[GTLQueryStoreendpoint queryForGetStoresWithFirstPosition:firstPosition maxResult:maxResult];
            
            [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket,GTLStoreendpointStoreCollection *object,NSError *error)
            {
                if(!error)
                    [weakSelf setDataPage:[object.items mutableCopy]];
                else
                    NSLog(@"StoreLoadingOperation Error:%@",[error userInfo]);
                
                weakSelf.bDataLoaded = true;
            }];
            
            while (weakSelf.bDataLoaded == false)
                [NSThread sleepForTimeInterval:DataLoadingOperationDuration2];

        }];
    }
    
    return self;
}

@end