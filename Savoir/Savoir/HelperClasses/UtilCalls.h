//
//  UtilCalls.h
//  Savoir
//
//  Created by Nirav Saraiya on 11/20/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//
@import CoreLocation;
#import <UIKit/UIKit.h>
#import "GTLStoreendpointOrderReviewAndItemReviews.h"
#import "GTLStoreendpointStoreAndStats.h"
#import "GTLStoreendpointStoreWaitListQueue.h"

@interface UtilCalls : NSObject

+ (NSString *) formattedNumber:(NSNumber*) number;
+ (NSString *) rawAmountToString:(NSNumber*)number;
+ (NSString *) amountToString:(NSNumber*)number;
+ (NSString *) amountToStringNoCurrency:(NSNumber*)number;
+ (NSString *) percentAmountToString:(NSNumber*)number;
+ (NSString *) percentAmountToStringNoCurrency:(NSNumber*)number;
+ (Boolean)isDistanceBetweenPointA:(CLLocation*)first AndPointB:(CLLocation *)second withinRange:(NSUInteger)range;

+ (void)slidingMenuSetupWith:(UIViewController *)viewController withItem:(UIBarButtonItem *)revealButtonItem;

+ (void) popFrom:(UIViewController *)childController ToViewController:(Class)parentControllerClass Animated:(BOOL)animated;
+ (void) popFrom:(UIViewController *)childController index:(int)index Animated:(BOOL)animated;

+ (void) setupHeaderView:(UIView *)headerView WithTitle:(NSString *)title AndSubTitle:(NSString *)subTitle;
+ (UIView *)setupStaticHeaderViewForTable:(UITableView*)tableView WithTitle:(NSString *)title AndSubTitle:(NSString *)subTitle;

+ (NSNumber *) stringToNumber:(NSString*)string;

+ (NSString *) getAuthTokenForCurrentUser;
+ (Boolean) orderHasAlreadyBeenReviewed:(GTLStoreendpointOrderReviewAndItemReviews *)reviewAndItems;
+ (NSString *) getOverallReviewStringFromStats:(GTLStoreendpointStoreAndStats *)storeAndStats;
+ (NSString *) getFoodReviewStringFromStats:(GTLStoreendpointStoreAndStats *)storeAndStats;
+ (NSString *) getServiceReviewStringFromStats:(GTLStoreendpointStoreAndStats *)storeAndStats;
+ (void) removeWaitListQueueEntry:(GTLStoreendpointStoreWaitListQueue *)queueEntry;

@end
