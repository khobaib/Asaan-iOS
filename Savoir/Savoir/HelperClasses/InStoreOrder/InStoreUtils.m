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
#import "InStoreOrderSummaryTableViewController.h"

@implementation InStoreUtils

+ (void) getStoreForBeaconId:(long)beaconId
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
             if ([UtilCalls canStore:object fulfillOrderAt:[NSDate date]] == true)
             {
                 appDelegate.globalObjectHolder.inStoreOrderDetails = [[InStoreOrderDetails alloc]init];
                 appDelegate.globalObjectHolder.inStoreOrderDetails.selectedStore = object;
                 if ([UtilCalls userBelongsToStoreChatTeamForStore:appDelegate.globalObjectHolder.inStoreOrderDetails.selectedStore])
                 {
                     [InStoreUtils startServerMode];
                     return;
                 }
                 else
                 {
                     [InStoreUtils startInStoreMode];
                     return;
                 }
             }
         }
         else
             NSLog(@"Savoir Server Call Failed: queryForGetStoreByBeaconId - error:%@", error.userInfo);
     }];
}

+ (void) startServerMode
{
    UIStoryboard *mainstoryboard = [UIStoryboard storyboardWithName:@"InStoreServer" bundle:nil];
    TablesViewController* pvc = [mainstoryboard instantiateViewControllerWithIdentifier:@"ServerTablesViewController"];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:pvc];
    [[UIViewController currentViewController] presentViewController:navigationController animated:YES completion:nil];
}

+ (void) startInStoreMode
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    [appDelegate.globalObjectHolder.inStoreOrderDetails clearCurrentOrder];
    
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
                 AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
                 appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails = object;
                 NSLog(@"startInStoreMode tableGroupMemberId = %lld orderId = %lld", object.memberMe.identifier.longLongValue, object.order.identifier.longLongValue);
                 NSLog(@"startInStoreMode member status = %d orderId = %d", object.memberMe.status.intValue, object.order.orderStatus.intValue);
                 if (object.memberMe.identifier.longLongValue > 0 && object.order.identifier.longLongValue > 0)
                 {
                     UIStoryboard *mainstoryboard = [UIStoryboard storyboardWithName:@"InStorePay" bundle:nil];
                     InStoreOrderSummaryTableViewController* pvc = [mainstoryboard instantiateViewControllerWithIdentifier:@"InstoreOrderSummaryViewController"];
                     UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:pvc];
                     [[UIViewController currentViewController] presentViewController:navigationController animated:YES completion:nil];
                 }
                 else
                 {
                     UIStoryboard *mainstoryboard = [UIStoryboard storyboardWithName:@"InStorePay" bundle:nil];
                     ExistingGroupsTableViewController* pvc = [mainstoryboard instantiateViewControllerWithIdentifier:@"ExistingGroupsTableViewController"];
                     UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:pvc];
                     [[UIViewController currentViewController] presentViewController:navigationController animated:YES completion:nil];
                 }
             }else{
                 NSLog(@"queryForAddMemberToStoreTableGroup Error:%@",[error userInfo][@"error"]);
             }
         }];
    }
}

@end
