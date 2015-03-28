//
//  UtilCalls.m
//  Savoir
//
//  Created by Nirav Saraiya on 11/20/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UtilCalls.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"
#import "InlineCalls.h"

@interface UtilCalls()
@end

@implementation UtilCalls

+ (int) ORDER_PREP_TIME { return 3600; }

+ (NSString *) formattedNumber:(NSNumber*) number
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    if (number.longLongValue >= 1000000){
        number = [NSNumber numberWithFloat:ceil(number.longLongValue/1000000)];
        NSString *strNumber = [numberFormatter stringFromNumber:number];
        return [strNumber stringByAppendingString:@"M+"];
    }
    else if (number.longLongValue >= 10000){
        number = [NSNumber numberWithFloat:ceil(number.longLongValue/1000)];
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
    [numberFormatter setRoundingMode:NSNumberFormatterRoundUp];
    float fVal = [number floatValue];
    return [numberFormatter stringFromNumber:[NSNumber numberWithFloat:fVal]];
}

+ (NSString *) amountToString:(NSNumber*)number
{
    NSNumberFormatter * numberFormatter = [[NSNumberFormatter new] init];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setMaximumFractionDigits:2];
    [numberFormatter setRoundingMode:NSNumberFormatterRoundUp];
    float fVal = [number floatValue]/100;
    return [numberFormatter stringFromNumber:[NSNumber numberWithFloat:fVal]];
}

+ (NSString *) amountToStringNoCurrency:(NSNumber*)number
{
    NSNumberFormatter * numberFormatter = [[NSNumberFormatter new] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [numberFormatter setMaximumFractionDigits:2];
    [numberFormatter setRoundingMode:NSNumberFormatterRoundUp];
    float fVal = [number floatValue]/100;
    return [numberFormatter stringFromNumber:[NSNumber numberWithFloat:fVal]];
}

+ (NSString *) percentAmountToString:(NSNumber*)number
{
    NSNumberFormatter * numberFormatter = [[NSNumberFormatter new] init];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setMaximumFractionDigits:2];
    [numberFormatter setRoundingMode:NSNumberFormatterRoundUp];
    float fVal = [number floatValue]/1000000;
    return [numberFormatter stringFromNumber:[NSNumber numberWithFloat:fVal]];
}

+ (NSString *) doubleAmountToString:(NSNumber*)number
{
    NSNumberFormatter * numberFormatter = [[NSNumberFormatter new] init];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setMaximumFractionDigits:2];
    [numberFormatter setRoundingMode:NSNumberFormatterRoundUp];
    return [numberFormatter stringFromNumber:number];
}

+ (NSNumber *) doubleAmountToLong:(double)doubleNumber
{
    NSNumberFormatter * numberFormatter = [[NSNumberFormatter new] init];
    [numberFormatter setNumberStyle:NSNumberFormatterNoStyle];
    [numberFormatter setMaximumFractionDigits:0];
    [numberFormatter setRoundingMode:NSNumberFormatterRoundUp];
    NSNumber *number = [NSNumber numberWithDouble:doubleNumber * 100];
    NSString *numberStr = [numberFormatter stringFromNumber:number];
    return [self stringToNumber:numberStr];
}

+ (NSString *) percentAmountToStringNoCurrency:(NSNumber*)number
{
    NSNumberFormatter * numberFormatter = [[NSNumberFormatter new] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [numberFormatter setMaximumFractionDigits:2];
    [numberFormatter setRoundingMode:NSNumberFormatterRoundUp];
    float fVal = [number floatValue]/1000000;
    return [numberFormatter stringFromNumber:[NSNumber numberWithFloat:fVal]];
}

+ (NSString *) doubleAmountToStringNoCurrency:(NSNumber*)number
{
    NSNumberFormatter * numberFormatter = [[NSNumberFormatter new] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [numberFormatter setMaximumFractionDigits:2];
    [numberFormatter setRoundingMode:NSNumberFormatterRoundUp];
    return [numberFormatter stringFromNumber:number];
}

+ (NSNumber *) stringToNumber:(NSString*)string
{
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterRoundCeiling;
    return [f numberFromString:string];
}


+ (Boolean)isDistanceBetweenPointA:(CLLocation*)first AndStore:(GTLStoreendpointStore *)store withinRange:(NSUInteger)range;
{
    double storeLat = RAD2DEG(store.lat.doubleValue);
    double storeLng = RAD2DEG(store.lng.doubleValue);
    CLLocation* second = [[CLLocation alloc] initWithLatitude:storeLat longitude:storeLng];
    
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

+ (void) popFrom:(UIViewController *)childController ToViewController:(Class)parentControllerClass Animated:(BOOL)animated
{
    NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[childController.navigationController viewControllers]];
    for (UIViewController *aViewController in allViewControllers) {
        if ([aViewController isKindOfClass:parentControllerClass]) {
            [childController.navigationController popToViewController:aViewController animated:animated];
        }
    }
}

+ (void) popFrom:(UIViewController *)childController index:(int)index Animated:(BOOL)animated
{
    NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[childController.navigationController viewControllers]];
    long count = allViewControllers.count;
    
    if (index > count - 1)
        return;
    
    UIViewController *parentViewController = [allViewControllers objectAtIndex:(count -1 -index)];
    
    if (parentViewController != nil)
        [childController.navigationController popToViewController:parentViewController animated:animated];
}

+ (void) setupHeaderView:(UIView *)headerView WithTitle:(NSString *)title AndSubTitle:(NSString *)subTitle
{
    if (headerView)
    {
        UILabel *txtTitle = (UILabel *)[headerView viewWithTag:501];
        UILabel *txtSubtitle = (UILabel *)[headerView viewWithTag:502];
        
        txtTitle.text = title;
        txtSubtitle.text = subTitle;
    }
}

+ (UIView *)setupStaticHeaderViewForTable:(UITableView*)tableView WithTitle:(NSString *)title AndSubTitle:(NSString *)subTitle
{
//    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
//    if (sectionTitle == nil)
//    {
//        return nil;
//    }
    
    // Create label with section title
    UILabel *labelTitle = [[UILabel alloc] init];
    labelTitle.frame = CGRectMake(16, 16, 300, 30);
    labelTitle.backgroundColor = [UIColor clearColor];
    labelTitle.textColor = [UIColor whiteColor];
    //    label.shadowColor = [UIColor whiteColor];
    //    label.shadowOffset = CGSizeMake(0.0, 1.0);
    labelTitle.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    labelTitle.text = title;
    
    // Create header view and add label as a subview
    
    // you could also just return the label (instead of making a new view and adding the label as subview. With the view you have more flexibility to make a background color or different paddings
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, tableView.sectionHeaderHeight)];
    [view addSubview:labelTitle];
    
    if (IsEmpty(subTitle) == false)
    {
        UILabel *labelSubTitle = [[UILabel alloc] init];
        labelSubTitle.frame = CGRectMake(16, 16+30+8, 300, 30);
        labelSubTitle.backgroundColor = [UIColor clearColor];
        labelSubTitle.textColor = [UIColor whiteColor];
        //    label.shadowColor = [UIColor whiteColor];
        //    label.shadowOffset = CGSizeMake(0.0, 1.0);
        labelSubTitle.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        labelSubTitle.text = subTitle;
        [view addSubview:labelSubTitle];
    }
    UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(0, tableView.sectionHeaderHeight-1, tableView.bounds.size.width, 1)];
    view2.backgroundColor = [UIColor whiteColor];
    [view addSubview:view2];
    
    return view;

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

+ (Boolean) orderHasAlreadyBeenReviewed:(GTLStoreendpointOrderReviewAndItemReviews *)reviewAndItems
{
    if (reviewAndItems == nil || reviewAndItems.orderReview == nil)
        return false;
    
    if ((reviewAndItems.itemReviews == nil || reviewAndItems.itemReviews.count == 0) &&
        (reviewAndItems.orderReview.foodLike.shortValue == 0 && reviewAndItems.orderReview.serviceLike.shortValue == 0 &&
         IsEmpty(reviewAndItems.orderReview.comments) == true))
        return false;
    
    return true;
}

+ (NSString *) getOverallReviewStringFromStats:(GTLStoreendpointStoreAndStats *)storeAndStats
{
    long long foodCount = storeAndStats.stats.foodDislikes.longLongValue + storeAndStats.stats.foodLikes.longLongValue;
    long long serviceCount = storeAndStats.stats.serviceDislikes.longLongValue + storeAndStats.stats.serviceLikes.longLongValue;
    if (foodCount + serviceCount > 0)
    {
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterPercentStyle];
        int iPercent = (int)((storeAndStats.stats.foodLikes.longLongValue + storeAndStats.stats.serviceLikes.longLongValue)*100/(foodCount + serviceCount));
        NSNumber *likePercent = [NSNumber numberWithInt:iPercent];
        NSString *strReviewCount = [UtilCalls formattedNumber:[NSNumber numberWithLongLong:(foodCount + serviceCount)/2]];
        NSString *strLikePercent = [UtilCalls formattedNumber:likePercent];
        return [NSString stringWithFormat:@"%@%% (%@)", strLikePercent, strReviewCount];
    }
    else
        return nil;
}

+ (NSString *) getFoodReviewStringFromStats:(GTLStoreendpointStoreAndStats *)storeAndStats
{
    long long foodCount = storeAndStats.stats.foodDislikes.longLongValue + storeAndStats.stats.foodLikes.longLongValue;
    if (foodCount > 0)
    {
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterPercentStyle];
        int iPercent = (int)((storeAndStats.stats.foodLikes.longLongValue)*100/(foodCount));
        NSNumber *likePercent = [NSNumber numberWithInt:iPercent];
        NSString *strReviewCount = [UtilCalls formattedNumber:[NSNumber numberWithLongLong:(foodCount)/2]];
        NSString *strLikePercent = [UtilCalls formattedNumber:likePercent];
        return [NSString stringWithFormat:@"%@%% Like It (%@ Reviews)", strLikePercent, strReviewCount];
    }
    else
        return nil;
}

+ (void) removeWaitListQueueEntry:(GTLStoreendpointStoreWaitListQueue *)queueEntry
{
    queueEntry.status = [NSNumber numberWithInt:CLOSED_CANCELLED_BY_CUSTOMER];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
    GTLQueryStoreendpoint *query = [GTLQueryStoreendpoint queryForSaveStoreWaitlistQueueEntryWithObject:queueEntry];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    dic[USER_AUTH_TOKEN_HEADER_NAME] = [UtilCalls getAuthTokenForCurrentUser];
    [query setAdditionalHTTPHeaders:dic];
    
    [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket,GTLStoreendpointStoreWaitListQueue *queueEntry, NSError *error)
     {
         if (error)
         {
             NSLog(@"%@",[error userInfo][@"error"]);
         }
     }];
}

+ (NSString *) getServiceReviewStringFromStats:(GTLStoreendpointStoreAndStats *)storeAndStats
{
    long long serviceCount = storeAndStats.stats.serviceDislikes.longLongValue + storeAndStats.stats.serviceLikes.longLongValue;
    if (serviceCount > 0)
    {
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterPercentStyle];
        int iPercent = (int)((storeAndStats.stats.serviceLikes.longLongValue)*100/(serviceCount));
        NSNumber *likePercent = [NSNumber numberWithInt:iPercent];
        NSString *strReviewCount = [UtilCalls formattedNumber:[NSNumber numberWithLongLong:(serviceCount)/2]];
        NSString *strLikePercent = [UtilCalls formattedNumber:likePercent];
        return [NSString stringWithFormat:@"%@%% Like It (%@ Reviews)", strLikePercent, strReviewCount];
    }
    else
        return nil;
}

+ (Boolean) canStore:(GTLStoreendpointStore *)store fulfillOrderAt:(NSDate *)date
{
    return [UtilCalls isDate:date InAllowedGivenDates:store.hours];
}

+ (Boolean) canPlaceOrderFromMenu:(GTLStoreendpointStoreMenuHierarchy *)menu atDate:(NSDate *)date
{
    NSDate *minOrderDate = [date dateByAddingTimeInterval:[UtilCalls ORDER_PREP_TIME]];
    return [UtilCalls isDate:minOrderDate InAllowedGivenDates:menu.hours];
}

//
// date format
// MONDAY CLOSED,TUESDAY 1130 1430;1700 2130,WEDNESDAY 1130 2130,THURSDAY 1130 2130,FRIDAY 1130 2230,SATURDAY 1200 2230,SUNDAY 1600 2100
//

+ (Boolean) isDate:(NSDate *)date InAllowedGivenDates:(NSString *)strDates
{
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *weekdayComponents = [gregorian components:(NSDayCalendarUnit | NSTimeZoneCalendarUnit | NSWeekdayCalendarUnit) fromDate:date];
    
    NSString *weekDay = [UtilCalls getStringDayOfWeekFromInt:weekdayComponents.weekday];
    
    if (IsEmpty(weekDay) == true)
        return NO;
    
    NSString *requiredDayAndTimeStr = [UtilCalls findRequiredDay:weekDay FromGivenDatesString:strDates];
    
    if (IsEmpty(requiredDayAndTimeStr) == true)
        return NO;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"HHmm";
    NSString *time24Str = [dateFormatter stringFromDate:date];
    int time24 = [time24Str intValue];
    
    NSArray* allTimes = [requiredDayAndTimeStr componentsSeparatedByString: @";"];
    for (NSString *timeString in allTimes)
    {
        NSArray* allComponents = [timeString componentsSeparatedByString: @" "];
        NSString *startTimeStr = [allComponents objectAtIndex:0];
        NSString *endTimeStr = [allComponents objectAtIndex:1];
        int startTime = [startTimeStr intValue];
        int endTime = [endTimeStr intValue];
        
        if (startTime <= time24 && time24 < endTime)
            return YES;
    }
    
    return NO;
}

+ (NSString *)findRequiredDay:(NSString *)requiredDay FromGivenDatesString:(NSString *)strDates
{
    NSArray* allDays = [strDates componentsSeparatedByString: @","];
    for (NSString *dayString in allDays)
    {
        NSArray* allComponents = [dayString componentsSeparatedByString: @" "];
        NSString *day = [allComponents objectAtIndex:0];
        if ([day compare:requiredDay] == NSOrderedSame)
        {
            // remove day part and return everything else
            NSRange start = [dayString rangeOfString:@" "];
            NSString *timeString = [dayString substringWithRange:NSMakeRange(start.location+1, dayString.length - (start.location+1))];
            if ([timeString containsString:@"CLOSED"])
                return nil;
            return timeString;
        }
    }
    return nil;
}

+ (NSString *)getStringDayOfWeekFromInt:(NSUInteger)index
{
    switch (index)
    {
        case 1:
            return @"SUNDAY";
        case 2:
            return @"MONDAY";
        case 3:
            return @"TUESDAY";
        case 4:
            return @"WEDNESDAY";
        case 5:
            return @"THURSDAY";
        case 6:
            return @"FRIDAY";
        case 7:
            return @"SATURDAY";
        default:
            return nil;
    }
}
@end