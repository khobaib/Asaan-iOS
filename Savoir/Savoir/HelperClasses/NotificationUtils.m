//
//  NotificationUtils.m
//  Savoir
//
//  Created by Nirav Saraiya on 2/2/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import "NotificationUtils.h"
#import "MainReviewViewController.h"
#import "ChatView.h"
#import "AppDelegate.h"
#import "GTLStoreendpointOrderAndReviews.h"
#import "UtilCalls.h"
#import "UIColor+SavoirGoldColor.h"
#import "StoreListTableViewController.h"
#import "BBBadgeBarButtonItem.h"
#import "InStoreUtils.h"

@interface NotificationUtils()

@property (strong, nonatomic) NSDictionary *notificationInfo;

@end

@implementation NotificationUtils

+ (void)registerForNotifications
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:[appDelegate.notificationUtils createNotificationCategories]];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

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
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
        localNotif.category = @"REVIEW_CATEGORY";

    NSArray *keys = [NSArray arrayWithObjects:@"REVIEW_ORDER", @"REVIEW_STORE_NAME", nil];
    NSArray *objects = [NSArray arrayWithObjects:order.identifier, order.storeName, nil];
    
    NSDictionary *infoDict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    localNotif.userInfo = infoDict;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
}


+ (void)scheduleNotificationForInStorePay:(NSInteger)status message:(NSString *)msg
{
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif == nil)
        return;
    localNotif.fireDate = [NSDate date];
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    
    localNotif.alertBody = msg;
    if (status == 1) // Everything is OK
        localNotif.alertAction = NSLocalizedString(@"Thank you!", nil);
    else
        localNotif.alertAction = NSLocalizedString(@"Your Order", nil);
    
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    
    NSArray *keys = [NSArray arrayWithObjects:@"INSTORE_ORDER_STATUS", nil];
    NSArray *objects = [NSArray arrayWithObjects:[NSNumber numberWithLong:status], nil];
    
    NSDictionary *infoDict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    localNotif.userInfo = infoDict;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
}


+ (void)scheduleLocalNotificationWithString:(NSString *)message At:(NSDate *)date
{
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif == nil)
        return;
//    localNotif.fireDate = [date dateByAddingTimeInterval:30]; // Fire initial review time after one hour.
    localNotif.fireDate = date; // Fire initial review time after one hour.
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    
    localNotif.alertBody = message;
    localNotif.alertAction = NSLocalizedString(@"Ok", nil);
    
    localNotif.soundName = UILocalNotificationDefaultSoundName;
//    
//    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
//        localNotif.category = @"REVIEW_CATEGORY";
    
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

- (void)application:(UIApplication *)app didReceiveLocalNotification:(NSDictionary *)userInfo OnStartup:(Boolean)bStartup
{
    NSNumber *orderId = [userInfo objectForKey:@"REVIEW_ORDER"];
    NSString *storeName = [userInfo objectForKey:@"REVIEW_STORE_NAME"];
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
        if (bStartup == true)
            [self alertView:alertView didDismissWithButtonIndex:1];
        else
            [alertView show];
        return;
    }
    NSNumber *status = [userInfo objectForKey:@"INSTORE_ORDER_STATUS"];
    if (status.longValue == 2)
    {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        InStoreUtils *utils = appDelegate.globalObjectHolder.beaconManager.inStoreUtils;
        [utils startInStoreMode:nil ForStore:nil InBeaconMode:false];
    }
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
                     [[UIViewController currentViewController] presentViewController:navigationController animated:YES completion:nil];
                 }
                 else
                 {
                     UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Review already completed." message:@"This review has already been completed. Sorry for our mistake!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                     
                     [alert show];
                 }
             }else{
                 NSString *msg = @"Failed to obtain review information for this order. Please retry in a few minutes. If this error persists please contact Savoir Customer Assistance team.";
                 [UtilCalls handleGAEServerError:error Message:msg Title:@"Savoir Error" Silent:false];
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
    [self application:application didReceiveLocalNotification:userInfo OnStartup:false];
}

- (void)application:(UIApplication *) application handleRemindActionWithNotification:(NSDictionary *) userInfo
{
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

- (void)application:(UIApplication *)app didReceiveRemoteNotification:(NSDictionary *)userInfo OnStartup:(Boolean)bStartup AndStatus:(UIApplicationState)status
{
    NSString *type = [userInfo objectForKey:@"TYPE"];
    if ([type isEqualToString:@"CHAT"] == false)
        return;
    
    long long roomId = [[userInfo objectForKey:@"CHAT_ROOMID"] longLongValue];
    long long storeId = [[userInfo objectForKey:@"CHAT_STOREID"] longLongValue];
    if (bStartup == true || status == UIApplicationStateInactive)
        [self showChatViewControllerWithRoomId:roomId AndStoreId:storeId];
    else
    {
        [UIApplication sharedApplication].applicationIconBadgeNumber++;
        
        if (self.chatView != nil)
            [self.chatView refreshMessageView];
        else
        {
            long badgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber;
            self.barButton.badgeValue = [NSString stringWithFormat:@"%ld", (long)badgeNumber];
        }
    }
}

- (void) showChatViewControllerWithRoomId:(long long)roomId AndStoreId:(long long)storeId
{
    ChatView *chatView = [[ChatView alloc] initWith:roomId isStore:false currentStoreId:storeId];
    chatView.presentedFromNotification = true;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:chatView];
    [navigationController setNavigationBarHidden:NO];
    [navigationController.navigationBar setBackgroundImage:[UIImage new]
                                             forBarMetrics:UIBarMetricsDefault];
    navigationController.navigationBar.shadowImage = [UIImage new];
    navigationController.navigationBar.translucent = NO;
    navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    [[UIViewController currentViewController] presentViewController:navigationController animated:YES completion:nil];
}


- (UIBarButtonItem *)getSlidingMenuBarButtonSetupWith:(UIViewController *)viewController
{
    SWRevealViewController *revealViewController = viewController.revealViewController;
    revealViewController.delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ( revealViewController && viewController )
    {
        // If you want your BarButtonItem to handle touch event and click, use a UIButton as customView
        UIButton *customButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        // Add your action to your button
        [customButton addTarget:viewController.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
        // Customize your button as you want, with an image if you have a pictogram to display for example
        [customButton setImage:[UIImage imageNamed:@"reveal-icon"] forState:UIControlStateNormal];
        
        // Then create and add our custom BBBadgeBarButtonItem
        self.barButton = [[BBBadgeBarButtonItem alloc] initWithCustomUIButton:customButton];
        self.barButton.shouldHideBadgeAtZero = YES;
        self.barButton.badgeOriginX = 13;
        self.barButton.badgeOriginY = -9;
        self.barButton.badgeValue = [NSString stringWithFormat:@"%ld", (long)[UIApplication sharedApplication].applicationIconBadgeNumber];
        
        viewController.navigationItem.leftBarButtonItem = self.barButton;
        
        [viewController.navigationController.navigationBar addGestureRecognizer: viewController.revealViewController.panGestureRecognizer];
        
        return self.barButton;
    }
    else {
        
        return nil;
    }
}

@end
