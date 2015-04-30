//
//  InStoreUtils.m
//  Savoir
//
//  Created by Nirav Saraiya on 4/24/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import "InStoreUtils.h"
#import "AppDelegate.h"
#import "UtilCalls.h"
#import "TablesViewController.h"
#import "ExistingGroupsTableViewController.h"
#import "InStoreOrderSummaryViewController.h"
#import "UIView+Toast.h"

@interface InStoreUtils()

@end

@implementation InStoreUtils

+ (void) startInStoreModeForBeaconId:(long)beaconId
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
    GTLQueryStoreendpoint *query=[GTLQueryStoreendpoint queryForGetStoreByBeaconIdWithBeaconId:beaconId];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    dic[USER_AUTH_TOKEN_HEADER_NAME] = [UtilCalls getAuthTokenForCurrentUser];
    [query setAdditionalHTTPHeaders:dic];
    [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLStoreendpointStore *object, NSError *error)
     {
         if (!error)
         {
             [InStoreUtils startInStoreMode:nil ForStore:object InBeaconMode:true];
         }
         else
             NSLog(@"Savoir Server Call Failed: queryForGetStoreByBeaconId - error:%@", error.userInfo);
     }];
}

+ (void) stopInStoreMode
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.order.subTotal.longLongValue == 0 ||
        appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.order.subTotal.longLongValue == appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.order.alreadyPaidSubtotal.longLongValue)
        [appDelegate.globalObjectHolder.inStoreOrderDetails leaveGroup:nil];
}

+ (void) startInStoreMode:(UIViewController *)source ForStore:(GTLStoreendpointStore *)store InBeaconMode:(Boolean)isInBeaconMode
{
    source = nil;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([UtilCalls canStore:store fulfillOrderAt:[NSDate date]] == true)
    {
        appDelegate.globalObjectHolder.inStoreOrderDetails = [[InStoreOrderDetails alloc]init];
        appDelegate.globalObjectHolder.inStoreOrderDetails.selectedStore = store;
        if ([UtilCalls userBelongsToStoreChatTeamForStore:appDelegate.globalObjectHolder.inStoreOrderDetails.selectedStore])
        {
            [InStoreUtils startServerMode:source];
            return;
        }
        else
        {
            [InStoreUtils startInStoreConsumerMode:source InBeaconMode:isInBeaconMode];
            return;
        }
    }
}

+ (void) startServerMode:(UIViewController *)source
{
    UIStoryboard *mainstoryboard = [UIStoryboard storyboardWithName:@"InStoreServer" bundle:nil];
    TablesViewController* pvc = [mainstoryboard instantiateViewControllerWithIdentifier:@"ServerTablesViewController"];
    [InStoreUtils displaySource:source Destination:pvc];
}

+ (void) startInStoreConsumerMode:(UIViewController *)source InBeaconMode:(Boolean)isInBeaconMode
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];

    if (self)
    {
        GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
        GTLQueryStoreendpoint *query = [GTLQueryStoreendpoint queryForGetStoreTableGroupDetailsForCurrentUser];
        
        NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
        dic[USER_AUTH_TOKEN_HEADER_NAME]=[UtilCalls getAuthTokenForCurrentUser];
        
        [query setAdditionalHTTPHeaders:dic];
        
        [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLStoreendpointStoreOrderAndTeamDetails *object,NSError *error)
         {
             if(!error)
             {
                 appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails = object;
                 
                 UIStoryboard *mainstoryboard = [UIStoryboard storyboardWithName:@"InStorePay" bundle:nil];
                 if (object.memberMe.identifier.longLongValue > 0)
                 {
                     InStoreOrderSummaryViewController* pvc = [mainstoryboard instantiateViewControllerWithIdentifier:@"InstoreOrderSummaryViewController"];
                     if (appDelegate.globalObjectHolder.inStoreOrderDetails.selectedStore != nil &&
                         appDelegate.globalObjectHolder.inStoreOrderDetails.selectedStore.identifier.longLongValue != object.store.identifier.longLongValue)
                     {
                         appDelegate.globalObjectHolder.inStoreOrderDetails.selectedStore = object.store;
                         [InStoreUtils displaySource:source Destination:pvc];
                         NSString *msg = [NSString stringWithFormat:@"You have an open order at %@. Please close this order before opening a new one.", object.store.name];
                         [pvc.view makeToast:msg];
                     }
                     else
                     {
                         appDelegate.globalObjectHolder.inStoreOrderDetails.selectedStore = object.store;
                         [InStoreUtils displaySource:source Destination:pvc];
                     }
                 }
                 else
                 {
                     if (isInBeaconMode == false)
                     {
                         ExistingGroupsTableViewController* pvc = [mainstoryboard instantiateViewControllerWithIdentifier:@"ExistingGroupsTableViewController"];
                         [InStoreUtils displaySource:source Destination:pvc];
                     }
                     else
                     {
                         [appDelegate.globalObjectHolder.inStoreOrderDetails createGroup:nil];
                     }
                 }
             }else{
                 NSLog(@"queryForAddMemberToStoreTableGroup Error:%@",[error userInfo][@"error"]);
             }
         }];
    }
}

+ (void) displaySource:(UIViewController *)source Destination:(UIViewController *)destination
{
    if (source == nil)
    {
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:destination];
        [[UIViewController currentViewController] presentViewController:navigationController animated:YES completion:nil];
    }
    else
    {
        UIStoryboardSegue *segue = [UIStoryboardSegue segueWithIdentifier:@"segueStoreListToConsumerOrderView" source:source destination:destination performHandler:^(void) {
            //view transition/animation
            [source.navigationController pushViewController:destination animated:YES];
        }];
        
        [source shouldPerformSegueWithIdentifier:segue.identifier sender:source];//optional
        [source prepareForSegue:segue sender:source];
        
        [segue perform];
    }
}

@end
