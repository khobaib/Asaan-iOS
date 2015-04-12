//
//  AppDelegate.m
//  Savoir
//
//  Created by Nirav Saraiya on 11/6/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import "AppDelegate.h"
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <Parse/Parse.h>
#import "Stripe.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreData/CoreData.h>
#import <ParseCrashReporting/ParseCrashReporting.h>

#import "UIColor+SavoirBackgroundColor.h"
#import "UIColor+SavoirGoldColor.h"
#import "SWRevealViewController.h"
#import "BBBadgeBarButtonItem.h"
#import "StripePay.h"

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

#import <DBChooser/DBChooser.h>
#import "AFNetworkReachabilityManager.h" //<--


NSString *const BFTaskMultipleExceptionsException = @"BFMultipleExceptionsException";

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)crash {
    [NSException raise:NSGenericException format:@"Everything is ok. This is just a test crash."];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    // Enable Crash Reporting
    [Fabric with:@[CrashlyticsKit]];
    [self globalObjectHolder];
    [_globalObjectHolder findStoreCountFromServer];
    
    // ****************************************************************************
    // Uncomment and fill in with your Parse credentials:
    // [Parse setApplicationId:@"your_application_id" clientKey:@"your_client_key"];
    //
    // If you are using Facebook, uncomment and add your FacebookAppID to your bundle's plist as
    // described here: https://developers.facebook.com/docs/getting-started/facebook-sdk-for-ios/
    // [PFFacebookUtils initializeFacebook];
    // ****************************************************************************
    [ParseCrashReporting enable];
    // Test
    [Parse setApplicationId:@"GXtJ9wg7fm1oMLt36zD5GvbsXyXJW6atbQjQKnin"
                  clientKey:@"1MXmqCsvaOKWs2ilTGOL2wvugGrasbZMwukIvn1Q"];
    
    // Production
//    [Parse setApplicationId:@"uX5Pxp1cPWJUbhl4qp5REJskOqDIp33tfMcSu1Ac"
//                  clientKey:@"4cad0RAqv53bvlmgiTgnOScuJVk7IY28XeH4Mes5"];
    [PFFacebookUtils initializeFacebook];
    [Stripe setDefaultPublishableKey:StripePublishableKey];
    
    //    [PFUser enableAutomaticUser];
    
    PFACL *defaultACL = [PFACL ACL];
    
    // If you would like all objects to be private by default, remove this line.
    [defaultACL setPublicReadAccess:YES];
    
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    
    if (application.applicationState != UIApplicationStateBackground) {
        // Track an app open here if we launch with a push, unless
        // "content_available" was used to trigger a background push (introduced in iOS 7).
        // In that case, we skip tracking here to avoid double counting the app-open.
        BOOL preBackgroundPush = ![application respondsToSelector:@selector(backgroundRefreshStatus)];
        BOOL oldPushHandlerOnly = ![self respondsToSelector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)];
        BOOL noPushPayload = ![launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (preBackgroundPush || oldPushHandlerOnly || noPushPayload) {
            [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
        }
    }
    
    self.notificationUtils = [[NotificationUtils alloc]init];
    [_globalObjectHolder loadSupportedClientVersionFromServer];
    [_globalObjectHolder loadAllUserObjects];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                 categories:[self.notificationUtils createNotificationCategories]];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    } else
#endif
    {
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                         UIRemoteNotificationTypeAlert |
                                                         UIRemoteNotificationTypeSound)];
    }
    
    if (SYSTEM_VERSION_GREATER_THAN(@"8.0")) {
        [[UINavigationBar appearance] setHidden:NO];
        [UINavigationBar appearance].translucent = NO;
    }
    
//    [self.navigationController setNavigationBarHidden:NO];
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
//                                                  forBarMetrics:UIBarMetricsDefault];
//    self.navigationController.navigationBar.shadowImage = [UIImage new];
//    self.navigationController.navigationBar.translucent = YES;
//    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    
    [[UINavigationBar appearance] setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    [UINavigationBar appearance].barTintColor = [UIColor asaanBackgroundColor];
    [UINavigationBar appearance].shadowImage = [UIImage new];
    [UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    
    self.window.tintColor = [UIColor goldColor];
    
    if (launchOptions != nil)
    {
        NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (userInfo != nil)
        {
            [self.notificationUtils application:application didReceiveRemoteNotification:userInfo OnStartup:true AndStatus:application.applicationState];
        }
    }
    
    UILocalNotification *localNotif =
    [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotif)
    {
//        [viewController displayItem:itemName];  // custom method
        [self.notificationUtils application:application didReceiveLocalNotification:localNotif.userInfo OnStartup:true];
    }
//    [window addSubview:viewController.view];
//    [window makeKeyAndVisible];

//    [self performSelector:@selector(crash) withObject:nil afterDelay:10.0];
    
    /*
    [[NSNotificationCenter defaultCenter] addObserver:self
            selector:@selector(handleReachabilityChange:)
                        name:AFNetworkingReachabilityDidChangeNotification object:nil];
    */ //<--
    
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:
    ^(AFNetworkReachabilityStatus status)
    {
        NSLog(@"Reachability: %@", AFStringFromNetworkReachabilityStatus(status));
        
        if (status == AFNetworkReachabilityStatusNotReachable ||
            status == AFNetworkReachabilityStatusUnknown)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Connection Error"
                                                                message:
                                      @"Internet connection appears to be offline"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        }
    }]; //<--
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring]; //<--
    
    return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    if ([[DBChooser defaultChooser] handleOpenURL:url]) {
        // This was a Chooser response and handleOpenURL automatically ran the
        // completion block
        return YES;
    }
    
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}

#pragma mark - Handle Local Notification
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    [self.notificationUtils application:application didReceiveLocalNotification:notification.userInfo OnStartup:false];
}

- (void)application:(UIApplication *) application handleActionWithIdentifier:(NSString *) identifier forLocalNotification:(NSDictionary *) notification completionHandler:(void (^)()) completionHandler
{
    [self.notificationUtils application:application handleActionWithIdentifier:identifier forLocalNotification:notification completionHandler:completionHandler];
}

#pragma mark - Push Notification
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken {
    [PFPush storeDeviceToken:newDeviceToken];
    [PFPush subscribeToChannelInBackground:@"" target:self selector:@selector(subscribeFinished:error:)];
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:newDeviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    if (error.code == 3010) {
        NSLog(@"Push notifications are not supported in the iOS Simulator.");
    } else {
        // show some alert or otherwise handle the failure to register.
        NSLog(@"application:didFailToRegisterForRemoteNotificationsWithError: %@", error);
    }
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    [PFPush handlePush:userInfo];
    
    if (application.applicationState == UIApplicationStateInactive)
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    [self.notificationUtils application:application didReceiveRemoteNotification:userInfo OnStartup:false AndStatus:application.applicationState];
}

///////////////////////////////////////////////////////////
// Uncomment this method if you want to use Push Notifications with Background App Refresh
///////////////////////////////////////////////////////////
 - (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandle
{
     if (application.applicationState == UIApplicationStateInactive) {
         [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
     }
    [self.notificationUtils application:application didReceiveRemoteNotification:userInfo OnStartup:false AndStatus:application.applicationState];
}

#pragma mark - 
- (void)subscribeFinished:(NSNumber *)result error:(NSError *)error {
    if ([result boolValue]) {
        NSLog(@"Savoir successfully subscribed to push notifications on the broadcast channel.");
    } else {
        NSLog(@"Savoir failed to subscribe to push notifications on the broadcast channel.");
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize gtlStoreService = _gtlStoreService;
@synthesize gtlUserService = _gtlUserService;
@synthesize globalObjectHolder = _globalObjectHolder;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.asaan.Savoir" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Savoir" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Savoir.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo][@"error"]);
//        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (GTLServiceStoreendpoint *)gtlStoreService {
    
    if(_gtlStoreService == nil){
        _gtlStoreService = [[GTLServiceStoreendpoint alloc]init];
        _gtlStoreService.retryEnabled = YES;
    }
    return _gtlStoreService;
}

- (GlobalObjectHolder *)globalObjectHolder {
    
    if(_globalObjectHolder == nil)
        _globalObjectHolder = [[GlobalObjectHolder alloc]init];
    return _globalObjectHolder;
}

- (GTLServiceUserendpoint *)gtlUserService {
    
    if(_gtlUserService == nil){
        _gtlUserService = [[GTLServiceUserendpoint alloc]init];
        _gtlUserService.retryEnabled = YES;
    }
    return _gtlUserService;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo][@"error"]);
//            abort();
        }
    }
}

#pragma mark - SWRevealViewControllerDelegate
- (void)revealController:(SWRevealViewController *)revealController didMoveToPosition:(FrontViewPosition)position {

    [[NSNotificationCenter defaultCenter] postNotificationName:BBBadgeResetItemNotification object:self];
}

#pragma mark

- (void)handleReachabilityChange:(NSNotification *)notification
{
    
} //<--

- (BOOL)isNetworkReachable
{
    return [AFNetworkReachabilityManager sharedManager].isReachable;
} //<--

@end
