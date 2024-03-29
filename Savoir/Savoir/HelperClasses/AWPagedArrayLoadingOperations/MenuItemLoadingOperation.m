//
//  MenuItemLoadingOperation.m
//  Savoir
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
#import "Constants.h"
#import "UtilCalls.h"

@interface MenuItemLoadingOperation()
@property (nonatomic) Boolean bDataLoaded;
@end

@implementation MenuItemLoadingOperation
@synthesize bDataLoaded = _bDataLoaded;

- (instancetype)initWithIndexes:(NSIndexSet *)indexes storeId:(long long)storeId menuPOSId:(int)menuPOSId{
    
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
            GTLQueryStoreendpoint *query=[GTLQueryStoreendpoint queryForGetMenuItemAndStatsForMenuWithFirstPosition:firstPosition maxResult:maxResult menuPOSId:menuPOSId storeId:storeId];
            [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket,GTLStoreendpointMenuItemAndStatsCollection *object,NSError *error){
                if(!error)
                    [weakSelf setDataPage:[object.items mutableCopy]];
                else
                {
                    NSString *msg = @"Failed to load menu. Please retry in a few minutes. If this error persists please contact Savoir Customer Assistance team.";
                    [UtilCalls handleGAEServerError:error Message:msg Title:@"Savoir Error" Silent:true];
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