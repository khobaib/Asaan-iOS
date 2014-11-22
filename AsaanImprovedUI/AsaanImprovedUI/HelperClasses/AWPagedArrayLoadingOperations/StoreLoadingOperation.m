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

@implementation StoreLoadingOperation

Boolean bDataLoaded = false;

const NSTimeInterval DataLoadingOperationDuration = 0.3;

- (instancetype)initWithIndexes:(NSIndexSet *)indexes{
    
    self = [super initWithIndexes:indexes];
    
    self.indexes = indexes;

    if (self)
    {
        typeof(self) weakSelf = self;
        bDataLoaded = false;
        [self addExecutionBlock:^{
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
            GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
            int firstPosition = indexes.firstIndex;
            int maxResult = indexes.count;
            GTLQueryStoreendpoint *query=[GTLQueryStoreendpoint queryForGetStoresWithFirstPosition:firstPosition maxResult:maxResult];
            
            [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket,GTLStoreendpointStoreCollection *object,NSError *error){
                if(!error){
                    [weakSelf setDataPage:[object.items mutableCopy]];
                    PFQuery *query = [PFQuery queryWithClassName:@"PictureFiles"];
                    query.cachePolicy = kPFCachePolicyCacheThenNetwork;
                    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                        if (error)
                            NSLog(@"StoreLoadingOperation Error:%@",[error userInfo]);
                        else{
                            for (PFObject *object in objects) {
                                PFFile *backgroundImgFile = object[@"picture_file"];
                                [backgroundImgFile getDataInBackground];
                            }
                        }
                    }];
                }else{
                    NSLog(@"StoreLoadingOperation Error:%@",[error userInfo]);
                }
                bDataLoaded = true;
            }];
            
            while (bDataLoaded == false)
                [NSThread sleepForTimeInterval:DataLoadingOperationDuration];

        }];
    }
    
    return self;
}

@end