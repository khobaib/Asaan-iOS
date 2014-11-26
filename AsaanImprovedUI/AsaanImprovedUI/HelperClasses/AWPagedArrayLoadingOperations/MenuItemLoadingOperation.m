//
//  MenuItemLoadingOperation.m
//  AsaanImprovedUI
//
//  Created by Nirav Saraiya on 11/24/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MenuItemLoadingOperation.h"
#import "GTMHTTPFetcher.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "InlineCalls.h"

@interface MenuItemLoadingOperation()
@property (nonatomic) Boolean bDataLoaded;
@end

@implementation MenuItemLoadingOperation
@synthesize bDataLoaded = _bDataLoaded;

const NSTimeInterval DataLoadingOperationDuration = 0.3;

- (instancetype)initWithIndexes:(NSIndexSet *)indexes storeId:(long)storeId menuPOSId:(long)menuPOSId{
    
    self = [super initWithIndexes:indexes];
    
    self.indexes = indexes;

    int firstPosition = indexes.firstIndex;
    int maxResult = indexes.count;
    
    if (self)
    {
        typeof(self) weakSelf = self;
        _bDataLoaded = false;
        [self addExecutionBlock:^{
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
            GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
            GTLQueryStoreendpoint *query=[GTLQueryStoreendpoint queryForGetStoreMenuItemsForMenuWithStoreId:storeId menuPOSId:menuPOSId firstPosition:firstPosition maxResult:maxResult];
            
            [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket,GTLStoreendpointStoreMenuItemCollection *object,NSError *error){
                if(!error){
                    [weakSelf setDataPage:[object.items mutableCopy]];
                    PFQuery *query = [PFQuery queryWithClassName:@"PictureFiles"];
                    query.cachePolicy = kPFCachePolicyCacheThenNetwork;
                    NSMutableArray *pictureFiles = [[NSMutableArray alloc]init];
                    for (GTLStoreendpointStoreMenuItem *menuItem in object) {
                        if (IsEmpty(menuItem.imageUrl) == false)
                            [pictureFiles addObject:menuItem.imageUrl];
                    }
                    if (pictureFiles.count > 0) {
                        [query whereKey:@"objectId" containedIn:pictureFiles];
                        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                            if (error)
                                NSLog(@"StoreLoadingOperation Parse Error:%@",[error userInfo]);
                       }];
                    }
                }else{
                    NSLog(@"StoreLoadingOperation Error:%@",[error userInfo]);
                }
                weakSelf.bDataLoaded = true;
            }];
            
            while (weakSelf.bDataLoaded == false)
                [NSThread sleepForTimeInterval:DataLoadingOperationDuration];
            
        }];
    }
    
    return self;
}

@end