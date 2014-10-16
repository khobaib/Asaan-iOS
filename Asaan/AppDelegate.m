//
//  AppDelegate.m
//  Asaan
//
//  Created by MC MINI on 9/9/14.
//  Copyright (c) 2014 Tech Fiesta. All rights reserved.
//

#import "AppDelegate.h"
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <Parse/Parse.h>
#import <GooglePlus/GooglePlus.h>
#import "Stripe.h"
#import <QuartzCore/QuartzCore.h>
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
   
    [Parse setApplicationId:@"uX5Pxp1cPWJUbhl4qp5REJskOqDIp33tfMcSu1Ac"
                  clientKey:@"4cad0RAqv53bvlmgiTgnOScuJVk7IY28XeH4Mes5"];
     [PFFacebookUtils initializeFacebook];
     [Stripe setDefaultPublishableKey:@"pk_test_hlpADPUOWaxn6uN0aATgLivW"];
  
  
    return YES;
}



-(void)appiaranceChange{
    [[[UITextField appearance]layer] setBorderColor:[[UIColor colorWithRed:(187.0/255.0) green:(137.0/255.0) blue:(33.0/255.0) alpha:1.0f] CGColor]];
    [[[UITextField appearance]layer] setBorderWidth:2.0f];

}
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    // attempt to extract a token from the url
    
    
    BOOL b= [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
    
    if(b) return b;
    
   return [GPPURLHandler handleURL:url
                  sourceApplication:sourceApplication
                         annotation:annotation];
    
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[PFFacebookUtils session] close];
}
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}




@end
