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

@implementation InStoreOrderDetails

+ (int)PAYMENT_TYPE_PAYINFULL { return 1; }
+ (int)PAYMENT_TYPE_SPLITEVENLY { return 2; }
+ (int)PAYMENT_TYPE_SPLITBYITEM  { return 3; }

- (void)createGroup
{
    if (self)
    {
        __weak __typeof(self) weakSelf = self;
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
        long long storeId = self.selectedStore.identifier.longLongValue;
        GTLQueryStoreendpoint *query = [GTLQueryStoreendpoint queryForCreateStoreTableGroupWithStoreId:storeId];
        
        NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
        dic[USER_AUTH_TOKEN_HEADER_NAME]=[UtilCalls getAuthTokenForCurrentUser];
        
        [query setAdditionalHTTPHeaders:dic];
        
        [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLStoreendpointStoreTableGroup *object, NSError *error)
         {
             if(!error)
                 weakSelf.selectedTableGroup = object;
             else
                 NSLog(@"setupExistingGroupsData Error:%@",[error userInfo][@"error"]);
         }];
    }
}

- (void) joinGroup:(GTLStoreendpointStoreTableGroup *)tableGroup
{
    self.selectedTableGroup = tableGroup;
    
    if (self)
    {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
        GTLQueryStoreendpoint *query = [GTLQueryStoreendpoint queryForAddMemberToStoreTableGroupWithOrderId:appDelegate.globalObjectHolder.inStoreOrderDetails.selectedTableGroup.orderId.longLongValue storeTableGroupId:appDelegate.globalObjectHolder.inStoreOrderDetails.selectedTableGroup.identifier.longLongValue];
        
        NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
        dic[USER_AUTH_TOKEN_HEADER_NAME]=[UtilCalls getAuthTokenForCurrentUser];
        
        [query setAdditionalHTTPHeaders:dic];
        
        [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id object,NSError *error)
         {
             if(error)
                 NSLog(@"queryForAddMemberToStoreTableGroup Error:%@",[error userInfo][@"error"]);
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
        long long orderId = self.selectedTableGroup.orderId.longLongValue;
        NSLog(@"getStoreOrderDetails orderId = %lld selectedTableGroupId = %lld", orderId, self.selectedTableGroup.identifier.longLongValue);
        if (orderId == 0)
            return;
        GTLQueryStoreendpoint *query = [GTLQueryStoreendpoint queryForGetStoreOrderByIdWithOrderId:orderId];
        
        NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
        dic[USER_AUTH_TOKEN_HEADER_NAME]=[UtilCalls getAuthTokenForCurrentUser];
        
        [query setAdditionalHTTPHeaders:dic];
        
        [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLStoreendpointStoreOrder *object,NSError *error)
         {
             if(!error)
             {
                 weakSelf.order = object;
                 NSLog(@"parseOrderDetails XML=%@", object.orderDetails);
                 [receiver orderChanged];
             }else{
                 NSLog(@"getStoreOrderDetails Error:%@",[error userInfo][@"error"]);
             }
         }];
    }
}

- (void)getGroupMembers:(id <InStoreOrderReceiver>)receiver
{
    if (self)
    {
        __weak __typeof(self) weakSelf = self;
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
        long long storeTableGroupId = appDelegate.globalObjectHolder.inStoreOrderDetails.selectedTableGroup.identifier.longLongValue;
        GTLQueryStoreendpoint *query = [GTLQueryStoreendpoint queryForGetMembersForStoreTableGroupWithStoreTableGroupId:storeTableGroupId];
        
        NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
        dic[USER_AUTH_TOKEN_HEADER_NAME]=[UtilCalls getAuthTokenForCurrentUser];
        
        [query setAdditionalHTTPHeaders:dic];
        
        [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLStoreendpointStoreTableGroupMemberCollection *object,NSError *error)
         {
             if(!error)
             {
                 weakSelf.tableGroupMembers = object;
                 [receiver tableGroupMemberChanged];
             }else{
                 NSLog(@"getGroupMembers Error:%@",[error userInfo][@"error"]);
             }
         }];
    }

}

- (void) updateStoreTableGroupMembers:(NSMutableDictionary *)changedMembers
{
    GTLStoreendpointStoreTableGroupMemberArray *memberCollection = [[GTLStoreendpointStoreTableGroupMemberArray alloc]init];
    memberCollection.members = changedMembers.allValues;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
    GTLQueryStoreendpoint *query = [GTLQueryStoreendpoint queryForUpdateStoreTableGroupMemberWithObject:memberCollection];
    
    NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
    dic[USER_AUTH_TOKEN_HEADER_NAME]=[UtilCalls getAuthTokenForCurrentUser];
    
    [query setAdditionalHTTPHeaders:dic];
    
    [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id object,NSError *error)
     {
         if(error)
             NSLog(@"queryForUpdateStoreTableGroupMemberWithObject Error:%@",[error userInfo][@"error"]);
     }];
}

- (MutableOrderedDictionary *)getCheckItemsFromXML:(NSString *)strPOSCheckDetails
{
    if (IsEmpty(strPOSCheckDetails))
        return nil;
    RXMLElement *rootXML = [RXMLElement elementFromXMLString:strPOSCheckDetails encoding:NSUTF8StringEncoding];
    if (rootXML == nil)
        return nil;
    //    NSArray *rxmlEntries = [[[rootXML child:@"GETCHECKDETAILS"] child:@"CHECK"] children:@"ENTRIES"];
    MutableOrderedDictionary *items = [[MutableOrderedDictionary alloc]init];
    
    int position = 0;
    NSArray *allEntries = [[[[rootXML child:@"GETCHECKDETAILS"] child:@"CHECK"] child:@"ENTRIES"] children:@"ENTRY"];
    
    for (RXMLElement *entry in allEntries)
    {
        OrderItemSummaryFromPOS *orderItemSummaryFromPOS = [[OrderItemSummaryFromPOS alloc]init];
        orderItemSummaryFromPOS.posMenuItemId = [UtilCalls stringToNumber:[entry attribute:@"ITEMID"]].intValue;
        orderItemSummaryFromPOS.qty = [UtilCalls stringToNumber:[entry attribute:@"QUANTITY"]].intValue;
        orderItemSummaryFromPOS.price = [UtilCalls stringToNumber:[entry attribute:@"PRICE"]].floatValue;
        orderItemSummaryFromPOS.name = [entry attribute:@"DISP_NAME"];
        orderItemSummaryFromPOS.desc = [entry attribute:@"OPTION"];
        orderItemSummaryFromPOS.entryId = [UtilCalls stringToNumber:[entry attribute:@"ID"]].intValue;
        orderItemSummaryFromPOS.position = position++;
        
        [items setObject:orderItemSummaryFromPOS forKey:[NSNumber numberWithLong:orderItemSummaryFromPOS.entryId]];
    }
    
    return items;
}

- (NSMutableArray *) parseOrderDetails
{
    MutableOrderedDictionary *items = [self getCheckItemsFromXML:self.order.orderDetails];
    NSMutableArray *finalItems = [[NSMutableArray alloc]init];
    for (int i = 0; i < items.count; i++)
    {
        OrderItemSummaryFromPOS *item = [items objectAtIndex:i];
        [finalItems addObject:item];
    }
    NSLog(@"parseOrderDetails count=%ld", (long)finalItems.count);
    return finalItems;
}


@end
