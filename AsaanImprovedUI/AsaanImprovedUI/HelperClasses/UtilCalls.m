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

+ (NSString *) formattedNumber:(NSNumber*) number{
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

@end