//
//  NotificationUtils.m
//  AsaanImprovedUI
//
//  Created by Nirav Saraiya on 2/2/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import "NotificationUtils.h"
#import "MainReviewViewController.h"
#import "AppDelegate.h"
#import "GTLStoreendpointOrderAndReviews.h"
#import "UtilCalls.h"
#import "UIColor+AsaanGoldColor.h"

@interface NotificationUtils()

@property (strong, nonatomic) NSDictionary *notificationInfo;

@end

@implementation NotificationUtils

- (void)scheduleNotificationWithOrder:(GTLStoreendpointStoreOrder *)order
{
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif == nil)
        return;
    NSDate *date = [NSDate date];
    localNotif.fireDate = [date dateByAddingTimeInterval:30]; // Fire initial review time after one hour.
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    
    localNotif.alertBody = [NSString stringWithFormat:@"How was %@? We would appreciate your feedback.", order.storeName];
    localNotif.alertAction = NSLocalizedString(@"Review", nil);
    
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    localNotif.applicationIconBadgeNumber = 1;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
        localNotif.category = @"REVIEW_CATEGORY";

    NSArray *keys = [NSArray arrayWithObjects:@"REVIEW_ORDER", @"REVIEW_STORE_NAME", nil];
    NSArray *objects = [NSArray arrayWithObjects:order.identifier, order.storeName, nil];
    
    NSDictionary *infoDict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    localNotif.userInfo = infoDict;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
}

- (void)cancelNotificationWithOrder:(NSNumber *)orderId
{
    NSArray *arrayOfLocalNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications] ;
    
    for (UILocalNotification *localNotif in arrayOfLocalNotifications)
    {
        NSNumber *number = [localNotif.userInfo valueForKey:@"REVIEW_ORDER"];
        if (number.longLongValue == orderId.longLongValue)
        {
            //Cancelling local notification
            [[UIApplication sharedApplication] cancelLocalNotification:localNotif];
            break;
        }

    }
}

- (void)application:(UIApplication *)app didReceiveLocalNotification:(NSDictionary *)userInfo
{
    NSNumber *orderId = [userInfo objectForKey:@"REVIEW_ORDER"];
    NSString *storeName = [userInfo objectForKey:@"REVIEW_STORE_NAME"];
    NSLog(@"Inside didReceiveLocalNotification :%@", userInfo);
    if (orderId != nil && orderId.longLongValue > 0)
    {
        self.notificationInfo = userInfo;
        NSString *reviewTitle = [NSString stringWithFormat:@"Review %@", storeName];
        NSString *reviewText = [NSString stringWithFormat:@"How was %@? We would appreciate your feedback.", storeName];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:reviewTitle
                                                            message:reviewText
                                                           delegate:self
                                                  cancelButtonTitle:@"Skip"
                                                  otherButtonTitles:@"Review", nil];
        [alertView show];
    }
    //    [viewController displayItem:itemName];  // custom method
//    app.applicationIconBadgeNumber = notification.applicationIconBadgeNumber - 1;
    
//#warning QUERY : Should we increase badge value of sliding-icon on receiving Local Notification?
//    [[NSNotificationCenter defaultCenter] postNotificationName:BBBadgeIncreaseNotification object:self userInfo:@{BBUserInfoBadgeKey : [NSNumber numberWithInteger:app.applicationIconBadgeNumber]}];
}
#pragma mark - UIAlertViewDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    if (buttonIndex != alertView.cancelButtonIndex)
    {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        NSNumber *orderId = [self.notificationInfo objectForKey:@"REVIEW_ORDER"];
        GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
        GTLQueryStoreendpoint *query = [GTLQueryStoreendpoint queryForGetOrderAndReviewsByIdWithOrderId:orderId.longLongValue];
        NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
        dic[USER_AUTH_TOKEN_HEADER_NAME]=[UtilCalls getAuthTokenForCurrentUser];
        
        [query setAdditionalHTTPHeaders:dic];
        
        [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLStoreendpointOrderAndReviews *object,NSError *error)
         {
             if(!error)
             {
                 if ([UtilCalls orderHasAlreadyBeenReviewed:object.orderAndItemsReview] == false)
                 {
                     UIStoryboard *mainstoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                     MainReviewViewController* pvc = [mainstoryboard instantiateViewControllerWithIdentifier:@"ReviewMainViewController"];
                     pvc.selectedOrder = object.order;
                     pvc.reviewAndItems = object.orderAndItemsReview;
                     pvc.presentedFromNotification = true;
                     UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:pvc];
//                     [UINavigationBar appearance].barTintColor = [UIColor asaanBackgroundColor];
                     [[UIViewController currentViewController] presentViewController:navigationController animated:YES completion:nil];
                 }
                 else
                 {
                     UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Review already completed." message:@"This review has already been completed. Sorry for our mistake!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                     
                     [alert show];
                 }
             }else{
                 NSLog(@"getOrderReview Error:%@",[error userInfo]);
             }
         }];
    }
}

- (void)application:(UIApplication *) application handleActionWithIdentifier:(NSString *) identifier forLocalNotification:(NSDictionary *) notification completionHandler:(void (^)()) completionHandler
{
    if ([identifier isEqualToString: @"REVIEW_IDENTIFIER"])
        [self application:application handleReviewActionWithNotification:notification];
    else if ([identifier isEqualToString: @"REMIND_LATER_IDENTIFIER"])
        [self application:application handleRemindActionWithNotification:notification];
    
    // Must be called when finished
    completionHandler();
}

- (void)application:(UIApplication *) application handleReviewActionWithNotification:(NSDictionary *) userInfo
{
    NSLog(@"Inside handleReviewActionWithNotification %@", userInfo);
    [self application:application didReceiveLocalNotification:userInfo];
}

- (void)application:(UIApplication *) application handleRemindActionWithNotification:(NSDictionary *) userInfo
{
    NSLog(@"Inside handleRemindActionWithNotification %@", userInfo);
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif == nil)
        return;

    NSDateComponents *dc = [[NSDateComponents alloc] init];
    [dc setDay:1];
    
    NSDate *targetDate = [[NSCalendar currentCalendar] dateByAddingComponents:dc toDate:[NSDate date] options:0];
    NSDateComponents *newComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:targetDate];
    [newComponents setHour:9];
    NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:newComponents];

    localNotif.fireDate = date;
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    
    localNotif.alertBody = [NSString stringWithFormat:@"How was %@? We would appreciate your feedback.", [userInfo objectForKey:@"REVIEW_STORE_NAME"]];
    localNotif.alertAction = NSLocalizedString(@"Review", nil);
    
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    localNotif.applicationIconBadgeNumber = 1;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
        localNotif.category = @"REVIEW_CATEGORY";
    
    localNotif.userInfo = userInfo;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
    
}

- (NSSet *)createNotificationCategories
{
    // First create the category
    UIMutableUserNotificationCategory *reviewCategory = [[UIMutableUserNotificationCategory alloc] init];
    
    // Identifier to include in your push payload and local notification
    reviewCategory.identifier = @"REVIEW_CATEGORY";
    
    // Add the actions to the category and set the action context
    [reviewCategory setActions:@[[self defineOrderReviewAction], [self defineOrderRemindLaterAction], [self defineDeclineAction]]
                    forContext:UIUserNotificationActionContextDefault];
    
    // Set the actions to present in a minimal context
    [reviewCategory setActions:@[[self defineOrderReviewAction], [self defineDeclineAction]]
                    forContext:UIUserNotificationActionContextMinimal];
    NSSet *categories = [NSSet setWithObjects:reviewCategory, nil];
    return categories;
}

- (UIMutableUserNotificationAction *)defineOrderReviewAction
{
    UIMutableUserNotificationAction *reviewAction = [[UIMutableUserNotificationAction alloc] init];
    
    // Define an ID string to be passed back to your app when you handle the action
    reviewAction.identifier = @"REVIEW_IDENTIFIER";
    
    // Localized string displayed in the action button
    reviewAction.title = @"Review";
    
    // If you need to show UI, choose foreground
    reviewAction.activationMode = UIUserNotificationActivationModeForeground;
    
    // Destructive actions display in red
    reviewAction.destructive = NO;
    
    // Set whether the action requires the user to authenticate
    reviewAction.authenticationRequired = NO;
    return reviewAction;
}

- (UIMutableUserNotificationAction *)defineOrderRemindLaterAction
{
    UIMutableUserNotificationAction *remindLaterAction = [[UIMutableUserNotificationAction alloc] init];
    
    // Define an ID string to be passed back to your app when you handle the action
    remindLaterAction.identifier = @"REMIND_LATER_IDENTIFIER";
    
    // Localized string displayed in the action button
    remindLaterAction.title = @"Later";
    
    // If you need to show UI, choose foreground
    remindLaterAction.activationMode = UIUserNotificationActivationModeBackground;
    
    // Destructive actions display in red
    remindLaterAction.destructive = NO;
    
    // Set whether the action requires the user to authenticate
    remindLaterAction.authenticationRequired = NO;
    return remindLaterAction;
}

- (UIMutableUserNotificationAction *)defineDeclineAction
{
    UIMutableUserNotificationAction *declineAction = [[UIMutableUserNotificationAction alloc] init];
    
    // Define an ID string to be passed back to your app when you handle the action
    declineAction.identifier = @"DECLINE_IDENTIFIER";
    
    // Localized string displayed in the action button
    declineAction.title = @"Skip";
    
    // If you need to show UI, choose foreground
    declineAction.activationMode = UIUserNotificationActivationModeBackground;
    
    // Destructive actions display in red
    declineAction.destructive = NO;
    
    // Set whether the action requires the user to authenticate
    declineAction.authenticationRequired = NO;
    return declineAction;
}


@end
