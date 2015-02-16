//
//  UtilCalls.m
//  Savoir
//
//  Created by Nirav Saraiya on 11/20/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UtilCalls.h"
#import "BBBadgeBarButtonItem.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"
#import "InlineCalls.h"

@interface UtilCalls()
@end

@implementation UtilCalls

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

+ (NSString *) amountToStringNoCurrency:(NSNumber*)number
{
    NSNumberFormatter * numberFormatter = [[NSNumberFormatter new] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
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

+ (NSString *) percentAmountToStringNoCurrency:(NSNumber*)number
{
    NSNumberFormatter * numberFormatter = [[NSNumberFormatter new] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
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

+ (UIBarButtonItem *)getSlidingMenuBarButtonSetupWith:(UIViewController *)viewController
{
    
    SWRevealViewController *revealViewController = viewController.revealViewController;
    revealViewController.delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    revealViewController.shouldUseFrontViewOverlay = YES;
    revealViewController.shouldUseDoubleAnimationOnVCChange = NO;
    
    if ( revealViewController && viewController )
    {
        // If you want your BarButtonItem to handle touch event and click, use a UIButton as customView
        UIButton *customButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        // Add your action to your button
        [customButton addTarget:viewController.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
        // Customize your button as you want, with an image if you have a pictogram to display for example
        [customButton setImage:[UIImage imageNamed:@"reveal-icon"] forState:UIControlStateNormal];
        
        // Then create and add our custom BBBadgeBarButtonItem
        BBBadgeBarButtonItem *barButton = [[BBBadgeBarButtonItem alloc] initWithCustomUIButton:customButton];
        barButton.shouldHideBadgeAtZero = YES;
        barButton.badgeOriginX = 13;
        barButton.badgeOriginY = -9;
//        barButton.badgeValue = [NSString stringWithFormat:@"%d", [UIApplication sharedApplication].applicationIconBadgeNumber];
        
        viewController.navigationItem.leftBarButtonItem = barButton;
        
        [viewController.navigationController.navigationBar addGestureRecognizer: viewController.revealViewController.panGestureRecognizer];
        
        return barButton;
    }
    else {
        
        return nil;
    }
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
    long foodCount = storeAndStats.stats.foodDislikes.longLongValue + storeAndStats.stats.foodLikes.longLongValue;
    long serviceCount = storeAndStats.stats.serviceDislikes.longLongValue + storeAndStats.stats.serviceLikes.longLongValue;
    if (foodCount + serviceCount > 0)
    {
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterPercentStyle];
        int iPercent = (int)((storeAndStats.stats.foodLikes.longLongValue + storeAndStats.stats.serviceLikes.longLongValue)*100/(foodCount + serviceCount));
        NSNumber *likePercent = [NSNumber numberWithInt:iPercent];
        NSString *strReviewCount = [UtilCalls formattedNumber:[NSNumber numberWithLong:(foodCount + serviceCount)/2]];
        NSString *strLikePercent = [UtilCalls formattedNumber:likePercent];
        return [NSString stringWithFormat:@"%@%% (%@)", strLikePercent, strReviewCount];
    }
    else
        return nil;
}

+ (NSString *) getFoodReviewStringFromStats:(GTLStoreendpointStoreAndStats *)storeAndStats
{
    long foodCount = storeAndStats.stats.foodDislikes.longLongValue + storeAndStats.stats.foodLikes.longLongValue;
    if (foodCount > 0)
    {
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterPercentStyle];
        int iPercent = (int)((storeAndStats.stats.foodLikes.longLongValue)*100/(foodCount));
        NSNumber *likePercent = [NSNumber numberWithInt:iPercent];
        NSString *strReviewCount = [UtilCalls formattedNumber:[NSNumber numberWithLong:(foodCount)/2]];
        NSString *strLikePercent = [UtilCalls formattedNumber:likePercent];
        return [NSString stringWithFormat:@"%@%% Like It (%@ Reviews)", strLikePercent, strReviewCount];
    }
    else
        return nil;
}

+ (NSString *) getServiceReviewStringFromStats:(GTLStoreendpointStoreAndStats *)storeAndStats
{
    long serviceCount = storeAndStats.stats.serviceDislikes.longLongValue + storeAndStats.stats.serviceLikes.longLongValue;
    if (serviceCount > 0)
    {
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterPercentStyle];
        int iPercent = (int)((storeAndStats.stats.serviceLikes.longLongValue)*100/(serviceCount));
        NSNumber *likePercent = [NSNumber numberWithInt:iPercent];
        NSString *strReviewCount = [UtilCalls formattedNumber:[NSNumber numberWithLong:(serviceCount)/2]];
        NSString *strLikePercent = [UtilCalls formattedNumber:likePercent];
        return [NSString stringWithFormat:@"%@%% Like It (%@ Reviews)", strLikePercent, strReviewCount];
    }
    else
        return nil;
}
@end