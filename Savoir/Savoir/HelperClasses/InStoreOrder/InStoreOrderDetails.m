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
             {
                 NSString *msg = @"Failed to create a table group. Please retry in a few minutes. If this error persists please contact Savoir Customer Assistance team.";
                 [UtilCalls handleGAEServerError:error Message:msg Title:@"Savoir Error" Silent:true];
             }
             else
             {
                 self.teamAndOrderDetails = object;
                 [receiver orderChanged:error];
             }
         }];
    }
}

- (void)leaveGroup:(id <InStoreOrderReceiver>)receiver
{
    if (self)
    {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
        GTLQueryStoreendpoint *query = [GTLQueryStoreendpoint queryForRemoveMemberFromStoreTableGroup];
        
        NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
        dic[USER_AUTH_TOKEN_HEADER_NAME]=[UtilCalls getAuthTokenForCurrentUser];
        
        [query setAdditionalHTTPHeaders:dic];
        
        [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error)
         {
             if(error)
             {
                 NSString *msg = @"Failed to leave a table group.";
                 [UtilCalls handleGAEServerError:error Message:msg Title:@"Leave Group/Table Error" Silent:true];
             }
             else
             {
                 [self clearCurrentOrder];
                 [receiver orderChanged:error];
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
             {
                 NSString *msg = @"Failed to join a table group.";
                 [UtilCalls handleGAEServerError:error Message:msg Title:@"Join Group/Table Error" Silent:true];
             }
             else
             {
                 self.teamAndOrderDetails = object;
                 [receiver orderChanged:error];
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
                 [receiver openGroupsChanged:error];
             }else{
                 NSString *msg = @"Failed to get available groups. Please retry in a few minutes. If this error persists please contact Savoir Customer Assistance team.";
                 [UtilCalls handleGAEServerError:error Message:msg Title:@"Savoir Error" Silent:true];
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
                 [receiver orderChanged:error];
             }else{
                 NSString *msg = @"Failed to get order information. Please retry in a few minutes. If this error persists please contact Savoir Customer Assistance team.";
                 [UtilCalls handleGAEServerError:error Message:msg Title:@"Savoir Error" Silent:true];
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
         {
             NSString *msg = @"Failed to save changes. Please retry in a few minutes. If this error persists please contact Savoir Customer Assistance team.";
             [UtilCalls handleGAEServerError:error Message:msg Title:@"Savoir Error" Silent:true];
         }
         else
             [receiver openGroupsChanged:error];
     }];
}

- (void) clearCurrentOrder
{
    self.teamAndOrderDetails = nil;
    self.partySize = 0;
    self.paymentType = [InStoreOrderDetails PAYMENT_TYPE_PAYINFULL];
    self.selectedDiscount = nil;
    self.selectedStore = nil;
}

@end
