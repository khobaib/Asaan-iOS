//
//  InStoreOrderSummaryTableViewController.m
//  Savoir
//
//  Created by Nirav Saraiya on 4/5/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import "InStoreOrderSummaryTableViewController.h"
#import "AppDelegate.h"
#import "OrderItemSummaryFromPOS.h"
#import "RXMLElement.h"
#import "OrderedDictionary.h"
#import "InlineCalls.h"
#import "UtilCalls.h"
#import "MBProgressHUD.h"

@interface InStoreOrderSummaryTableViewController ()
@property (strong, nonatomic) GTLStoreendpointStoreOrder *selectedOrder;
@property (nonatomic, strong) NSMutableArray *finalItems;
@end

@implementation InStoreOrderSummaryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    if (self.navigationController.viewControllers[0] != self)
        self.navigationItem.leftBarButtonItem = nil;
    else
    {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        [appDelegate.notificationUtils getSlidingMenuBarButtonSetupWith:self];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self refreshOrderDetails];
}

- (void)refreshOrderDetails
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Please Wait";
    hud.hidden = NO;
    
    if (self)
    {
        __weak __typeof(self) weakSelf = self;
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
        long long orderId = appDelegate.globalObjectHolder.inStoreOrderDetails.selectedTableGroup.orderId.longLongValue;
        GTLQueryStoreendpoint *query = [GTLQueryStoreendpoint queryForGetStoreOrderByIdWithOrderId:orderId];
        
        NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
        dic[USER_AUTH_TOKEN_HEADER_NAME]=[UtilCalls getAuthTokenForCurrentUser];
        
        [query setAdditionalHTTPHeaders:dic];
        
        [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLStoreendpointStoreOrder *object,NSError *error)
         {
             if(!error)
             {
                 weakSelf.selectedOrder = object;
                 [self parsePOSCheckDetails];
                 [weakSelf.tableView reloadData];
             }else{
                 NSLog(@"setupExistingGroupsData Error:%@",[error userInfo][@"error"]);
             }
             hud.hidden = YES;
         }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (MutableOrderedDictionary *)getCheckItemsFromXML:(NSString *)strPOSCheckDetails
{
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
        orderItemSummaryFromPOS.parentEntryId = [UtilCalls stringToNumber:[entry attribute:@"PARENTENTRY"]].intValue;
        orderItemSummaryFromPOS.entryId = [UtilCalls stringToNumber:[entry attribute:@"ID"]].intValue;
        orderItemSummaryFromPOS.position = position++;
        
        [items setObject:orderItemSummaryFromPOS forKey:[NSNumber numberWithLong:orderItemSummaryFromPOS.entryId]];
    }
    
    return items;
}

- (void) parsePOSCheckDetails
{
    MutableOrderedDictionary *items = [self getCheckItemsFromXML:self.selectedOrder.orderDetails];
    self.finalItems = [[NSMutableArray alloc]init];
    
    if (items != nil)
    {
        for (int i = 0; i < items.count; i++)
        {
            OrderItemSummaryFromPOS *item = [items objectAtIndex:i];
            if (item.parentEntryId > 0)
            {
                OrderItemSummaryFromPOS *parentItem = [items objectForKey:[NSNumber numberWithLong:item.parentEntryId]];
                if (parentItem != nil)
                {
                    NSString *desc;
                    double finalPrice = parentItem.price;
                    if (item.price > 0)
                    {
                        desc = [NSString stringWithFormat:@"%@ (%@)", item.name, [UtilCalls rawAmountToString:[NSNumber numberWithDouble:item.price]]];
                        finalPrice = parentItem.price + item.price;
                    }
                    else
                        desc = item.name;
                    
                    if (IsEmpty(parentItem.desc) == false)
                        desc = [NSString stringWithFormat:@"%@, %@", parentItem.desc, desc];
                    
                    parentItem.desc = desc;
                    parentItem.price = finalPrice;
                    
                    [items setObject:parentItem forKey:[NSNumber numberWithLong:parentItem.entryId]];
                    //                    [items removeObjectForKey:[NSNumber numberWithLong:item.entryId]];
                }
            }
        }
        for (long i = items.count-1; i >=0; i--)
        {
            OrderItemSummaryFromPOS *item = [items objectAtIndex:i];
            if (item.parentEntryId > 0)
                [items removeObjectForKey:[NSNumber numberWithLong:item.entryId]];
        }
        
        MutableOrderedDictionary *combinedItems = [[MutableOrderedDictionary alloc]init];
        for (int i = 0; i < items.count; i++)
        {
            OrderItemSummaryFromPOS *item = [items objectAtIndex:i];
            NSString *key = [NSString stringWithFormat:@"%d_%@_%@", item.posMenuItemId, [UtilCalls rawAmountToString:[NSNumber numberWithDouble:item.price]], item.desc];
            OrderItemSummaryFromPOS *duplicateItem = [combinedItems objectForKey:key];
            if (duplicateItem != nil)
                duplicateItem.qty++;
            else
                [combinedItems setObject:item forKey:key];
        }
        for (int i = 0; i < combinedItems.count; i++)
        {
            OrderItemSummaryFromPOS *item = [combinedItems objectAtIndex:i];
            [self.finalItems addObject:item];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.finalItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MenuItemCell" forIndexPath:indexPath];
    UILabel *txtMenuItemName = (UILabel *)[cell viewWithTag:501];
    UILabel *txtQty = (UILabel *)[cell viewWithTag:502];
    UILabel *txtAmount = (UILabel *)[cell viewWithTag:503];
    UILabel *txtDesc = (UILabel *)[cell viewWithTag:504];
    txtDesc.text = nil;
    txtMenuItemName.text = nil;
    txtQty.text = nil;
    txtAmount.text = nil;
    
    OrderItemSummaryFromPOS *item = [self.finalItems objectAtIndex:indexPath.row];
    if (item != nil)
    {
        txtMenuItemName.text = item.name;
        txtQty.text = [NSString stringWithFormat:@"%d", item.qty];
        txtAmount.text = [NSString stringWithFormat:@"%@", [UtilCalls rawAmountToString:[NSNumber numberWithDouble:item.price]]];
        txtDesc.text = item.desc;
    }

    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (IBAction)onPayClick:(id)sender
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Please Wait";
    hud.hidden = NO;
    
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
                 appDelegate.globalObjectHolder.inStoreOrderDetails.tableGroupMembers = object;
                 if (object.items.count == 1)
                 {
                     appDelegate.globalObjectHolder.inStoreOrderDetails.paymentType = [InStoreOrderDetails PAYMENT_TYPE_PAYINFULL];
                     [weakSelf performSegueWithIdentifier:@"seguePayEntireAmount" sender:weakSelf];
                 }
                 else
                     [weakSelf performSegueWithIdentifier:@"seguePaymentOption" sender:weakSelf];
             }else{
                 NSLog(@"setupExistingGroupsData Error:%@",[error userInfo][@"error"]);
             }
             hud.hidden = YES;
         }];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
