//
//  Extension.m
//  generic-survey
//
//  Created by Hasan Ibna Akbar on 2/25/14.
//  Copyright (c) 2014 Hasan Ibna Akbar. All rights reserved.
//

#import "Extension.h"

#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonDigest.h>
//#import <objc/runtime.h>
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

#pragma mark - UIImage
@implementation UIImage (ImageUtilities)

+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end

#pragma mark - NSObject
@implementation NSObject (ObjectUtilities)

- (void)performSelectorOnMainThread:(SEL)selector waitUntilDone:(BOOL)wait withObjects:(NSObject *)firstObject, ... {
    // First attempt to create the method signature with the provided selector.
    NSMethodSignature *signature = [self methodSignatureForSelector:selector];
    
    if ( !signature ) {
        NSLog(@"NSObject: Method signature could not be created.");
        return;
    }
    
    // Next we create the invocation that will actually call the required selector.
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:self];
    [invocation setSelector:selector];
    
    // Now add arguments from the variable list of objects (nil terminated).
    va_list args;
    va_start(args, firstObject);
    int nextArgIndex = 2;
    
    for (NSObject *object = firstObject; object != nil; object = va_arg(args, NSObject*))
    {
        if ( object != [NSNull null] )
        {
            [invocation setArgument:&object atIndex:nextArgIndex];
        }
        
        nextArgIndex++;
    }
    
    va_end(args);
    
    [invocation retainArguments];
    [invocation performSelectorOnMainThread:@selector(invoke) withObject:nil waitUntilDone:wait];
}

@end

#pragma mark - NSData
@implementation NSData (DataUtilities)

- (NSString *)md5 {
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(self.bytes, (int)self.length, md5Buffer);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",md5Buffer[i]];
    
    return output;
}

@end

#pragma mark - NSString
@implementation NSString (StringUtilities)

+ (NSString *)stringFromDate:(NSDate *)date {
    return [self stringFromDate:date withFormat:@"yyyy-MM-dd HH:mm:ss" locale:nil];
}

+ (NSString *)stringFromDate:(NSDate *)date withFormat:(NSString *)format locale:(NSLocale *)locale {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    if (locale == nil) {
        locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    }
    [dateFormatter setLocale:locale];
    return [dateFormatter stringFromDate:date];
}

- (NSDate *)convertToDate {
    return [self convertToDateWithFormat:@"yyyy-MM-dd HH:mm:ss" locale:nil];
}

- (NSDate *)convertToDateWithFormat:(NSString *)format locale:(NSLocale *)locale {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    if (locale == nil) {
        locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    }
    [dateFormatter setLocale:locale];
    return  [dateFormatter dateFromString:self];
}

- (NSString *)stringByAppendingPathComponents:(NSString *)firstPath, ... {
    NSString *string = self;
    va_list args;
    va_start(args, firstPath);
    for (id arg = firstPath; arg != nil; arg = va_arg(args, id))
    {
        string = [string stringByAppendingPathComponent:arg];
    }
    va_end(args);
    
    return string;
}

- (NSString *)stringGroupByFirstInitial {
    if (!self.length || self.length == 1)
        return self;
    return [self substringToIndex:1];
}

- (NSString *)trim {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (NSString *)md5 {
    const char *ptr = [self UTF8String];
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(ptr, (int)strlen(ptr), md5Buffer);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",md5Buffer[i]];
    
    return output;
}

- (NSString *)queryString {
    return [[[self stringByReplacingOccurrencesOfString:@" +" withString:@"%" options:NSRegularExpressionSearch range:NSMakeRange(0, self.length)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] urlEncodeUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding {
    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)self, NULL, (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ", CFStringConvertNSStringEncodingToEncoding(encoding));
}

- (BOOL)isNotEmpty {
    return ([self length] != 0);
}

- (BOOL)isNotEmptyAndNotNull {
    if (self && [self isNotEmpty]) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)customContainsString:(NSString*)other {
    NSRange range = [self rangeOfString:other];
    return range.length != 0;
}

@end

#pragma mark - NSNumber
@implementation NSNumber (NumberUtilities)

- (NSString *)toString {
    return [NSString stringWithFormat:@"%@", self];
}

@end

#pragma mark - NSMutableDictionary
@implementation NSMutableDictionary (MutableDictionaryUtilities)

- (NSString *)convertToQueryString {
    if (self && ([self count] > 0)) {
        NSMutableArray *pairsArray = [NSMutableArray array];
        for (NSString *key in self) {
            id value = [self objectForKey:key];
            [pairsArray addObject:[NSString stringWithFormat:@"%@=%@", key, value]];
        }
        
        return [pairsArray componentsJoinedByString:@"&"];
    } else {
        return nil;
    }
}

@end

#pragma mark - NSURL
@implementation NSURL (URLUtilities)

+ (NSURL *)URLWithString:(NSString *)urlString pathComponents:(NSString *)firstPath, ... NS_REQUIRES_NIL_TERMINATION {
    NSURL *url = [NSURL URLWithString:urlString];
    
    va_list args;
    va_start(args, firstPath);
    for (id arg = firstPath; arg != nil; arg = va_arg(args, id))
    {
        url = [url URLByAppendingPathComponent:arg];
    }
    va_end(args);
    
    return url;
}

- (NSURL *)URLByAppendingPathComponents:(NSString *)firstPath, ... NS_REQUIRES_NIL_TERMINATION {
    NSURL *url = self;
    va_list args;
    va_start(args, firstPath);
    for (id arg = firstPath; arg != nil; arg = va_arg(args, id))
    {
        url = [url URLByAppendingPathComponent:arg];
    }
    va_end(args);
    
    return url;
}

@end

#pragma mark - NSDate
@implementation NSDate(DateUtilities)

+ (NSString *)currentDateString {
    return [[[NSDate alloc] init] convertToString];
}

+ (NSDate *)dateFromString:(NSString *)string {
    return [self dateFromString:string withFormat:@"yyyy-MM-dd HH:mm:ss" locale:nil];
}

+ (NSDate *)dateFromString:(NSString *)string withFormat:(NSString *)format locale:(NSLocale *)locale {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:format];
    if (locale == nil) {
        locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    }
    [dateFormat setLocale:locale];
    return [dateFormat dateFromString:string];
}

- (NSString *)convertToString {
    return [self convertToStringWithFormat:@"yyyy-MM-dd HH:mm:ss" locale:nil];
}

- (NSString *)convertToStringWithFormat:(NSString *)format locale:(NSLocale *)locale {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:format];
    if (locale == nil) {
        locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    }
    [dateFormat setLocale:locale];
    return [dateFormat stringFromDate:self];
}

@end

#pragma mark - UIColor
@implementation UIColor(ColorUtilities)

+ (UIColor *)colorWithRGBHex:(UInt32)hex {
	int r = (hex >> 16) & 0xFF;
	int g = (hex >> 8) & 0xFF;
	int b = (hex) & 0xFF;
    
	return [UIColor colorWithRed:r / 255.0f
                           green:g / 255.0f
                            blue:b / 255.0f
                           alpha:1.0f];
}

+ (UIColor *)colorWithHexString:(NSString *)stringToConvert {
	NSScanner *scanner = [NSScanner scannerWithString:stringToConvert];
	unsigned hexNum;
	if (![scanner scanHexInt:&hexNum]) return nil;
	return [UIColor colorWithRGBHex:hexNum];
}

@end

#pragma mark - UIDevice
@implementation UIDevice (DeviceUtility)

+ (NSString *)macAddress {
    
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        free(buf);
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                           *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    
    return outstring;
}

+ (CGFloat)OSVersion {
    
    static float osVersion_takeaway = -1;
    if (osVersion_takeaway <= 0) {
        osVersion_takeaway = [[[UIDevice currentDevice] systemVersion] floatValue];
    }
    return osVersion_takeaway;
}

+ (BOOL)isIPad {
    if ( [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)isIPhone {
    if ( [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone ) {
        return YES;
    } else {
        return NO;
    }
}

@end

#pragma mark - UIScreen
@implementation UIScreen (ScreenUtility)

+ (CGSize)actualSize {
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat screenScale = [[UIScreen mainScreen] scale];
    return CGSizeMake(screenBounds.size.width * screenScale, screenBounds.size.height * screenScale);
}

+ (CGFloat)width {
    return [[UIScreen mainScreen] bounds].size.width;
}

+ (CGFloat)height {
    return [[UIScreen mainScreen] bounds].size.height;
}

@end
