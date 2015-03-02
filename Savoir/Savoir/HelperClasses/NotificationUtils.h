//
//  NotificationUtils.h
//  Savoir
//
//  Created by Nirav Saraiya on 2/2/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTLStoreendpointStoreOrder.h"
#import "BBBadgeBarButtonItem.h"
#import "ChatView.h"

@interface NotificationUtils : NSObject <UIAlertViewDelegate>

@property (strong, nonatomic) BBBadgeBarButtonItem *barButton;
@property (strong, nonatomic) ChatView *chatView;

- (void)scheduleNotificationWithOrder:(GTLStoreendpointStoreOrder *)order;
- (void)cancelNotificationWithOrder:(NSNumber *)orderId;
- (void)application:(UIApplication *)app didReceiveLocalNotification:(NSDictionary *)userInfo OnStartup:(Boolean)bStartup;
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(NSDictionary *)notification completionHandler:(void (^)()) completionHandler;
- (void)application:(UIApplication *)application handleReviewActionWithNotification:(NSDictionary *) notification;
- (void)application:(UIApplication *)application handleRemindActionWithNotification:(NSDictionary *) notification;
- (NSSet *)createNotificationCategories;
- (UIMutableUserNotificationAction *)defineOrderReviewAction;
- (UIMutableUserNotificationAction *)defineOrderRemindLaterAction;
- (UIMutableUserNotificationAction *)defineDeclineAction;

- (void)application:(UIApplication *)app didReceiveRemoteNotification:(NSDictionary *)userInfo OnStartup:(Boolean)bStartup AndStatus:(UIApplicationState)status;
- (UIBarButtonItem *)getSlidingMenuBarButtonSetupWith:(UIViewController *)viewController;

@end
