//
//  NotificationUtils.h
//  AsaanImprovedUI
//
//  Created by Nirav Saraiya on 2/2/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTLStoreendpointStoreOrder.h"

@interface NotificationUtils : NSObject <UIAlertViewDelegate>

- (void)scheduleNotificationWithOrder:(GTLStoreendpointStoreOrder *)order;
- (void)cancelNotificationWithOrder:(NSNumber *)orderId;
- (void)application:(UIApplication *)application didReceiveLocalNotification:(NSDictionary *)userInfo;
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(NSDictionary *)notification completionHandler:(void (^)()) completionHandler;
- (void)application:(UIApplication *)application handleReviewActionWithNotification:(NSDictionary *) notification;
- (void)application:(UIApplication *)application handleRemindActionWithNotification:(NSDictionary *) notification;
- (NSSet *)createNotificationCategories;
- (UIMutableUserNotificationAction *)defineOrderReviewAction;
- (UIMutableUserNotificationAction *)defineOrderRemindLaterAction;
- (UIMutableUserNotificationAction *)defineDeclineAction;
@end
