//
//  UtilCalls.m
//  AsaanImprovedUI
//
//  Created by Nirav Saraiya on 11/20/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UtilCalls.h"

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
@end