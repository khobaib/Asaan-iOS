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
#import "SelectPaymentTableViewController.h"
#import "UIView+Toast.h"
#import "StripePay.h"
#import "UIAlertView+Blocks.h"
#import "NotificationUtils.h"

@interface InStoreUtils()<UIAlertViewDelegate>
@property (strong, nonatomic) UIViewController *source;
@end

@implementation InStoreUtils

- (void) startInStoreModeForBeaconId:(long)beaconId
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
             [self startInStoreMode:nil ForStore:object InBeaconMode:true];
         }
         else
         {
             NSString *msg = @"Failed to obtain a matching store by beacon. Please retry in a few minutes. If this error persists please contact Savoir Customer Assistance team.";
             [UtilCalls handleGAEServerError:error Message:msg Title:@"Savoir Error" Silent:true];
         }
     }];
}

- (void) stopInStoreMode
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.order.subTotal.longLongValue == 0 ||
        appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.order.subTotal.longLongValue == appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.order.alreadyPaidSubtotal.longLongValue)
    {
        NSString *msg = [NSString stringWithFormat:@"Thank you for visiting %@! We look forward to seeing you again soon.", appDelegate.globalObjectHolder.inStoreOrderDetails.selectedStore.name];
        [NotificationUtils scheduleNotificationForInStorePay:1 message:msg];
        [appDelegate.globalObjectHolder.inStoreOrderDetails leaveGroup:nil];
    }
    else
    {
        NSString *msg = [NSString stringWithFormat:@"Thank you for visiting %@! Your Order is still open. Please pay and close the order at your earliest convenience.", appDelegate.globalObjectHolder.inStoreOrderDetails.selectedStore.name];
        [[[UIAlertView alloc]initWithTitle:@"Your Order" message:msg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        [self startInStoreMode:nil ForStore:appDelegate.globalObjectHolder.inStoreOrderDetails.selectedStore InBeaconMode:false]; // setting beaconmode to false so the payment screen shows.
    }
}

- (void) startInStoreMode:(UIViewController *)source ForStore:(GTLStoreendpointStore *)store InBeaconMode:(Boolean)isInBeaconMode
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([UtilCalls canStore:store fulfillOrderAt:[NSDate date]] == true)
    {
        appDelegate.globalObjectHolder.inStoreOrderDetails = [[InStoreOrderDetails alloc]init];
        appDelegate.globalObjectHolder.inStoreOrderDetails.selectedStore = store;
        if ([UtilCalls userBelongsToStoreChatTeamForStore:appDelegate.globalObjectHolder.inStoreOrderDetails.selectedStore])
        {
            [self startServerMode:source];
            return;
        }
        else
        {
            [self startInStoreConsumerMode:source InBeaconMode:isInBeaconMode];
            return;
        }
    }
}

- (void) startServerMode:(UIViewController *)source
{
    UIStoryboard *mainstoryboard = [UIStoryboard storyboardWithName:@"InStoreServer" bundle:nil];
    TablesViewController* pvc = [mainstoryboard instantiateViewControllerWithIdentifier:@"ServerTablesViewController"];
    [self displaySource:source Destination:pvc];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIStoryboard *mainstoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SelectPaymentTableViewController* pvc = [mainstoryboard instantiateViewControllerWithIdentifier:@"SelectPaymentTableViewController"];
    [self displaySource:self.source Destination:pvc];
}

- (void) startInStoreConsumerMode:(UIViewController *)source InBeaconMode:(Boolean)isInBeaconMode
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    if ([StripePay applePayEnabled] == NO && appDelegate.globalObjectHolder.defaultUserCard == nil)
    {
        [[[UIAlertView alloc]initWithTitle:@"Setup Mobile Pay" message:@"Savoir needs a Mobile Payment method set up before starting an order. Please add a credit/debit card to your profile." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        self.source = source;
        return;
    }

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
                         NSString *msg = [NSString stringWithFormat:@"Welcome to %@. You have an open order at %@. Please close this order before opening a new one.", appDelegate.globalObjectHolder.inStoreOrderDetails.selectedStore.name, object.store.name];
                         [appDelegate.window makeToast:msg];
                         
                         appDelegate.globalObjectHolder.inStoreOrderDetails.selectedStore = object.store;
                         if (isInBeaconMode == false)
                             [self displaySource:source Destination:pvc];
                         else
                             [NotificationUtils scheduleLocalNotificationWithString:msg At:[NSDate date]];
                     }
                     else
                     {
                         if (appDelegate.globalObjectHolder.inStoreOrderDetails.selectedStore == nil)
                         {
                             NSString *msg = [NSString stringWithFormat:@"Welcome Back."];
                             [appDelegate.window makeToast:msg];
                         }
                         else
                         {
                             NSString *msg = [NSString stringWithFormat:@"Welcome to %@.", appDelegate.globalObjectHolder.inStoreOrderDetails.selectedStore.name];
                             [appDelegate.window makeToast:msg];
                         }
                         
                         appDelegate.globalObjectHolder.inStoreOrderDetails.selectedStore = object.store;
                         if (isInBeaconMode == false)
                             [self displaySource:source Destination:pvc];
                     }
                 }
                 else
                 {
                     if (isInBeaconMode == false)
                     {
                         ExistingGroupsTableViewController* pvc = [mainstoryboard instantiateViewControllerWithIdentifier:@"ExistingGroupsTableViewController"];
                         [self displaySource:source Destination:pvc];
                     }
                     else
                     {
                         NSString *title = [NSString stringWithFormat:@"Welcome to %@", appDelegate.globalObjectHolder.inStoreOrderDetails.selectedStore.name];
                         [appDelegate.globalObjectHolder.inStoreOrderDetails createGroup:nil];
                         [[[UIAlertView alloc]initWithTitle:title message:@"Please let your server know you would like to pay with Savoir. Then sit back and have a great time!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
//                         [NotificationUtils scheduleLocalNotificationWithString:msg At:[NSDate date]];
                     }
                 }
             }else
             {
                 NSString *msg = @"Something went wrong. Please retry in a few minutes. If this error persists please contact Savoir Customer Assistance team.";
                 [UtilCalls handleGAEServerError:error Message:msg Title:@"Savoir Error" Silent:false];
             }
         }];
    }
}

- (void) displaySource:(UIViewController *)source Destination:(UIViewController *)destination
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    if (source == nil)
        source = appDelegate.topViewController;
    UIStoryboardSegue *segue = [UIStoryboardSegue segueWithIdentifier:@"segueStoreListToConsumerOrderView" source:source destination:destination performHandler:^(void) {
        //view transition/animation
        [source.navigationController pushViewController:destination animated:YES];
    }];
    
    [source shouldPerformSegueWithIdentifier:segue.identifier sender:source];//optional
    [source prepareForSegue:segue sender:source];
    
    [segue perform];
}

@end
