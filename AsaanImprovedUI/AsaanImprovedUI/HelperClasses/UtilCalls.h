//
//  UtilCalls.h
//  AsaanImprovedUI
//
//  Created by Nirav Saraiya on 11/20/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//
@import CoreLocation;
#import <UIKit/UIKit.h>

@interface UtilCalls : NSObject

+ (NSString *) formattedNumber:(NSNumber*) number;
+ (NSString *) rawAmountToString:(NSNumber*)number;
+ (NSString *) amountToString:(NSNumber*)number;
+ (NSString *) percentAmountToString:(NSNumber*)number;
+ (Boolean)isDistanceBetweenPointA:(CLLocation*)first AndPointB:(CLLocation *)second withinRange:(NSUInteger)range;


+ (void)slidingMenuSetupWith:(UIViewController *)viewController withItem:(UIBarButtonItem *)revealButtonItem;

+ (NSNumber *) stringToNumber:(NSString*)string;

+ (NSString *) getAuthTokenForCurrentUser;

@end
