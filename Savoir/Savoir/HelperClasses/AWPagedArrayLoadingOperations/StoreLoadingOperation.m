//
//  StoreLoadingOperation.m
//  Savoir
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
#import "Constants.h"

@interface StoreLoadingOperation()
@property (nonatomic) Boolean bDataLoaded;
@end

@implementation StoreLoadingOperation
@synthesize bDataLoaded = _bDataLoaded;

- (instancetype)initWithIndexes:(NSIndexSet *)indexes{
    
    self = [super initWithIndexes:indexes];
    
    self.indexes = indexes;

    if (self)
    {
        __weak __typeof(self) weakSelf = self;
        _bDataLoaded = false;
        [self addExecutionBlock:^{
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
            GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
            NSUInteger firstPosition = indexes.firstIndex;
            NSUInteger maxResult = indexes.count;
            double latInRads = DEG2RAD(appDelegate.globalObjectHolder.location.coordinate.latitude);
            double lngInRads = DEG2RAD(appDelegate.globalObjectHolder.location.coordinate.longitude);
            GTLQueryStoreendpoint *query=[GTLQueryStoreendpoint queryForGetStoresOrderedByDistanceWithStatsWithLat:latInRads lng:lngInRads firstPosition:firstPosition maxResult:maxResult];
            [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket,GTLStoreendpointStoreAndStatsCollection *object,NSError *error)
            {
                if(!error)
                    [weakSelf setDataPage:[object.items mutableCopy]];
                else
                    NSLog(@"StoreLoadingOperation Error:%@",[error userInfo][@"error"]);
                
                weakSelf.bDataLoaded = true;
            }];
            
            while (weakSelf.bDataLoaded == false)
                [NSThread sleepForTimeInterval:DataLoadingOperationDuration];

        }];
    }
    
    return self;
}

@end