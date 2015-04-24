//
//  InStoreOrderDetails.m
//  Savoir
//
//  Created by Nirav Saraiya on 4/6/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import "InStoreOrderDetails.h"
#import "AppDelegate.h"
#import "UtilCalls.h"
#import "OrderItemSummaryFromPOS.h"
#import "RXMLElement.h"
#import "OrderedDictionary.h"
#import "InlineCalls.h"
#import "XMLPOSOrder.h"

@implementation InStoreOrderDetails

+ (int)PAYMENT_TYPE_PAYINFULL { return 0; }
+ (int)PAYMENT_TYPE_SPLITEVENLY { return 1; }
+ (int)PAYMENT_TYPE_SPLITBYITEM  { return 2; }

- (void)createGroup:(id <InStoreOrderReceiver>)receiver
{
    if (self)
    {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
        long long storeId = self.selectedStore.identifier.longLongValue;
        GTLQueryStoreendpoint *query = [GTLQueryStoreendpoint queryForCreateStoreTableGroupWithStoreId:storeId];
        
        NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
        dic[USER_AUTH_TOKEN_HEADER_NAME]=[UtilCalls getAuthTokenForCurrentUser];
        
        [query setAdditionalHTTPHeaders:dic];
        
        [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLStoreendpointStoreOrderAndTeamDetails *object, NSError *error)
         {
             if(error)
                 NSLog(@"setupExistingGroupsData Error:%@",[error userInfo][@"error"]);
             else
             {
                 self.teamAndOrderDetails = object;
                 [receiver orderChanged];
             }
         }];
    }
}

- (void) joinGroup:(GTLStoreendpointStoreTableGroup *)tableGroup receiver:(id <InStoreOrderReceiver>)receiver
{
    if (self)
    {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
        GTLQueryStoreendpoint *query = [GTLQueryStoreendpoint queryForAddMemberToStoreTableGroupWithStoreTableGroupId:tableGroup.identifier.longLongValue];
        
        NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
        dic[USER_AUTH_TOKEN_HEADER_NAME]=[UtilCalls getAuthTokenForCurrentUser];
        
        [query setAdditionalHTTPHeaders:dic];
        
        [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLStoreendpointStoreOrderAndTeamDetails *object,NSError *error)
         {
             if(error)
                 NSLog(@"queryForAddMemberToStoreTableGroup Error:%@",[error userInfo][@"error"]);
             {
                 self.teamAndOrderDetails = object;
                 [receiver orderChanged];
             }
         }];
    }
}

- (void) getOpenGroups:(id <InStoreOrderReceiver>)receiver
{
    if (self)
    {
        __weak __typeof(self) weakSelf = self;
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
        long long storeId = self.selectedStore.identifier.longLongValue;
        GTLQueryStoreendpoint *query = [GTLQueryStoreendpoint queryForGetOpenAndUnassignedGroupsForStoreWithStoreId:storeId];
        
        NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
        dic[USER_AUTH_TOKEN_HEADER_NAME]=[UtilCalls getAuthTokenForCurrentUser];
        
        [query setAdditionalHTTPHeaders:dic];
        
        [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLStoreendpointStoreTableGroupCollection *object,NSError *error)
         {
             if(!error)
             {
                 weakSelf.openGroups = object;
                 [receiver openGroupsChanged];
             }else{
                 NSLog(@"getOpenGroups Error:%@",[error userInfo][@"error"]);
             }
         }];
    }
}

- (void) getStoreOrderDetails:(id <InStoreOrderReceiver>)receiver
{
    if (self)
    {
        __weak __typeof(self) weakSelf = self;
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
        
        GTLQueryStoreendpoint *query = [GTLQueryStoreendpoint queryForGetStoreTableGroupDetailsForCurrentUser];
        
        NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
        dic[USER_AUTH_TOKEN_HEADER_NAME]=[UtilCalls getAuthTokenForCurrentUser];
        
        [query setAdditionalHTTPHeaders:dic];
        
        [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLStoreendpointStoreOrderAndTeamDetails *object,NSError *error)
         {
             if(!error)
             {
                 weakSelf.teamAndOrderDetails = object;
                 weakSelf.selectedDiscount = [XMLPOSOrder getDiscountFromXML:appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.order.orderDetails];
                 [receiver orderChanged];
             }else{
                 NSLog(@"getStoreOrderDetails Error:%@",[error userInfo][@"error"]);
             }
         }];
    }
}

- (void) updateStoreTableGroupMembers:(NSMutableDictionary *)changedMembers receiver:(id <InStoreOrderReceiver>)receiver
{
    GTLStoreendpointStoreTableGroupMemberArray *memberCollection = [[GTLStoreendpointStoreTableGroupMemberArray alloc]init];
    memberCollection.members = changedMembers.allValues;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
    GTLQueryStoreendpoint *query = [GTLQueryStoreendpoint queryForUpdateStoreTableGroupMembersWithObject:memberCollection];
    
    NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
    dic[USER_AUTH_TOKEN_HEADER_NAME]=[UtilCalls getAuthTokenForCurrentUser];
    
    [query setAdditionalHTTPHeaders:dic];
    
    [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id object,NSError *error)
     {
         if(error)
             NSLog(@"queryForUpdateStoreTableGroupMemberWithObject Error:%@",[error userInfo][@"error"]);
         else
             [receiver openGroupsChanged];
     }];
}

- (void) clearCurrentOrder
{
    self.teamAndOrderDetails = nil;
    self.partySize = 0;
    self.paymentType = [InStoreOrderDetails PAYMENT_TYPE_PAYINFULL];
    self.selectedDiscount = nil;
}

@end
