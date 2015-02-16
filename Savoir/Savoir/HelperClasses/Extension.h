//
//  Extension.h
//  generic-survey
//
//  Created by Hasan Ibna Akbar on 2/25/14.
//  Copyright (c) 2014 Hasan Ibna Akbar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 *  Necessary macro
 */
#define RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
//detect iPhone 5
#define isIphone5 ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height == 568)

#if TARGET_OS_IPHONE
    #define iOS_Version [UIDevice OSVersion]
#endif

#pragma mark - UIImage
@interface UIImage (ImageUtilities)

+ (UIImage *)imageWithColor:(UIColor *)color;

@end

#pragma mark - NSObject
@interface NSObject (ObjectUtilities)

- (void)performSelectorOnMainThread:(SEL)selector waitUntilDone:(BOOL)wait withObjects:(NSObject *)object, ... NS_REQUIRES_NIL_TERMINATION;

@end

#pragma mark - NSData
@interface NSData (DataUtilities)

- (NSString *)md5;

@end

#pragma mark - NSString
@interface NSString (StringUtilities)

+ (NSString *)stringFromDate:(NSDate *)date;
+ (NSString *)stringFromDate:(NSDate *)date withFormat:(NSString *)format locale:(NSLocale *)locale;
- (NSDate *)convertToDate;
- (NSDate *)convertToDateWithFormat:(NSString *)format locale:(NSLocale *)locale;
- (NSString *)stringByAppendingPathComponents:(NSString *)firstPath, ... NS_REQUIRES_NIL_TERMINATION;
- (NSString *)stringGroupByFirstInitial;
- (NSString *)trim;
- (NSString *)md5;
- (NSString *)queryString;
- (NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding;
- (BOOL)isNotEmpty;
- (BOOL)isNotEmptyAndNotNull;
- (BOOL)customContainsString:(NSString*)other;

@end

#pragma mark - NSNumber
@interface NSNumber (NumberUtilities)

- (NSString *)toString;

@end

#pragma mark - NSMutableDictionary
@interface NSMutableDictionary (MutableDictionaryUtilities)

- (NSString *)convertToQueryString;

@end

#pragma mark - NSURL
@interface NSURL (URLUtilities)

+ (NSURL *)URLWithString:(NSString *)urlString pathComponents:(NSString *)firstPath, ... NS_REQUIRES_NIL_TERMINATION;

- (NSURL *)URLByAppendingPathComponents:(NSString *)firstPath, ... NS_REQUIRES_NIL_TERMINATION;

@end

#pragma mark - NSDate
@interface NSDate(DateUtilities)

+ (NSString *)currentDateString;
+ (NSDate *)dateFromString:(NSString *)string;
+ (NSDate *)dateFromString:(NSString *)string withFormat:(NSString *)format locale:(NSLocale *)locale;
- (NSString *)convertToString;
- (NSString *)convertToStringWithFormat:(NSString *)format locale:(NSLocale *)locale;

@end

#pragma mark - UIColor
@interface UIColor(ColorUtilities)

+ (UIColor *)colorWithRGBHex:(UInt32)hex;
+ (UIColor *)colorWithHexString:(NSString *)stringToConvert;

@end

#pragma mark - UIDevice
@interface UIDevice (DeviceUtility)

+ (NSString *)macAddress;
+ (CGFloat)OSVersion;
+ (BOOL)isIPad;
+ (BOOL)isIPhone;

@end

#pragma mark - UIScreen
@interface UIScreen (ScreenUtility)

+ (CGSize)actualSize;
+ (CGFloat)width;
+ (CGFloat)height;

@end