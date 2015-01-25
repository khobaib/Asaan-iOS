//
//  UtilCalls.m
//  AsaanImprovedUI
//
//  Created by Nirav Saraiya on 11/20/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UtilCalls.h"
#import <Parse/Parse.h>

@interface UtilCalls()
@end

@implementation UtilCalls

+ (NSString *) formattedNumber:(NSNumber*) number
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    if (number.longValue >= 1000000){
        number = [NSNumber numberWithFloat:ceil(number.longValue/1000000)];
        NSString *strNumber = [numberFormatter stringFromNumber:number];
        return [strNumber stringByAppendingString:@"M+"];
    }
    else if (number.longValue >= 10000){
        number = [NSNumber numberWithFloat:ceil(number.longValue/1000)];
        NSString *strNumber = [numberFormatter stringFromNumber:number];
        return [strNumber stringByAppendingString:@"K+"];
    }
    else
        return [numberFormatter stringFromNumber:number];
}

+ (NSString *) rawAmountToString:(NSNumber*)number
{
    NSNumberFormatter * numberFormatter = [[NSNumberFormatter new] init];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setMaximumFractionDigits:2];
    [numberFormatter setRoundingMode:NSNumberFormatterRoundFloor];
    float fVal = [number floatValue];
    return [numberFormatter stringFromNumber:[NSNumber numberWithFloat:fVal]];
}

+ (NSString *) amountToString:(NSNumber*)number
{
    NSNumberFormatter * numberFormatter = [[NSNumberFormatter new] init];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setMaximumFractionDigits:2];
    [numberFormatter setRoundingMode:NSNumberFormatterRoundFloor];
    float fVal = [number floatValue]/100;
    return [numberFormatter stringFromNumber:[NSNumber numberWithFloat:fVal]];
}

+ (NSString *) percentAmountToString:(NSNumber*)number
{
    NSNumberFormatter * numberFormatter = [[NSNumberFormatter new] init];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setMaximumFractionDigits:2];
    [numberFormatter setRoundingMode:NSNumberFormatterRoundFloor];
    float fVal = [number floatValue]/1000000;
    return [numberFormatter stringFromNumber:[NSNumber numberWithFloat:fVal]];
}

+ (NSNumber *) stringToNumber:(NSString*)string
{
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterRoundCeiling;
    return [f numberFromString:string];
}


+ (Boolean)isDistanceBetweenPointA:(CLLocation*)first AndPointB:(CLLocation *)second withinRange:(NSUInteger)range
{
    float meterToMile = 0.000621371;
    CGFloat distance = [first distanceFromLocation:second];
    NSInteger maxDistance = floorf(distance * meterToMile);
    
    if (maxDistance > range)
        return NO;
    else
        return YES;
}

+ (void)slidingMenuSetupWith:(UIViewController *)viewController withItem:(UIBarButtonItem *)revealButtonItem
{
    SWRevealViewController *revealViewController = viewController.revealViewController;
    revealViewController.shouldUseFrontViewOverlay = YES;
    revealViewController.shouldUseDoubleAnimationOnVCChange = NO;
    
    if ( revealViewController && viewController && revealButtonItem )
    {
        [revealButtonItem setTarget: viewController.revealViewController];
        [revealButtonItem setAction: @selector( revealToggle: )];
        [viewController.navigationController.navigationBar addGestureRecognizer: viewController.revealViewController.panGestureRecognizer];
    }
}

+ (NSString *) getAuthTokenForCurrentUser
{
    PFUser *user = [PFUser currentUser];
    
    if (user != nil)
    {
        NSString *authToken = user [@"authToken"];
        NSString *email = user [@"email"];
        NSLog(@"Auth token = %@ for user %@", authToken, email);
        return authToken;
    }
    return nil;
}

@end