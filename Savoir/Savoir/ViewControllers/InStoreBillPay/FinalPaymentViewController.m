//
//  FinalPaymentViewController.m
//  Savoir
//
//  Created by Nirav Saraiya on 4/5/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import "FinalPaymentViewController.h"
#import "AppDelegate.h"
#import "UtilCalls.h"
#import "MBProgressHUD.h"
#import "InlineCalls.h"
#import "Extension.h"
#import "InStoreOrderDetails.h"
#import "OrderItemSummaryFromPOS.h"
#import "RXMLElement.h"
#import "OrderedDictionary.h"
#import "StripePay.h"
#import "GTLStoreendpointSplitOrderArguments.h"

@interface FinalPaymentViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *tipSegmentController;
@property (weak, nonatomic) IBOutlet UISlider *tipSlider;
@property (weak, nonatomic) IBOutlet UILabel *txtSubTotal;
@property (weak, nonatomic) IBOutlet UILabel *txtTip;
@property (weak, nonatomic) IBOutlet UILabel *txtTax;
@property (weak, nonatomic) IBOutlet UILabel *txtFinalAmount;
@property (weak, nonatomic) IBOutlet UILabel *txtTipLabel;

@property (strong, nonatomic) GTLStoreendpointStoreOrder *selectedOrder;
@property (nonatomic, strong) NSMutableArray *finalItems;
@property (strong, nonatomic) NSString *discountName;
@property (nonatomic) float discountAmt;

@property (nonatomic) NSUInteger groupMemberCount;
@property (nonatomic) NSUInteger payingForCount;
@property (strong, nonatomic) StripePay *stripePay;

@end

@implementation FinalPaymentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.stripePay = [[StripePay alloc]init];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    if (self.navigationController.viewControllers[0] != self)
        self.navigationItem.leftBarButtonItem = nil;
    else
    {
        [appDelegate.notificationUtils getSlidingMenuBarButtonSetupWith:self];
    }
    
    int defaultTip = appDelegate.globalObjectHolder.currentUser.defaultTip.intValue;
    if (defaultTip <= 18)
    {
        self.tipSegmentController.selectedSegmentIndex = 0;
        self.tipSlider.value = 18;
    }
    else if (defaultTip == 20)
    {
        self.tipSegmentController.selectedSegmentIndex = 1;
        self.tipSlider.value = 20;
    }
    else if (defaultTip == 25)
    {
        self.tipSegmentController.selectedSegmentIndex = 2;
        self.tipSlider.value = 25;
    }
    else
    {
        self.tipSegmentController.selectedSegmentIndex = 3;
        self.tipSlider.value = defaultTip;
    }
    [self refreshOrderDetails];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self setupGroupMembers];
}

- (void)setupGroupMembers
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
                 weakSelf.groupMemberCount = appDelegate.globalObjectHolder.inStoreOrderDetails.tableGroupMembers.items.count;
                 weakSelf.payingForCount = 0;
                 for (GTLStoreendpointStoreTableGroupMember *member in appDelegate.globalObjectHolder.inStoreOrderDetails.tableGroupMembers.items)
                 {
                     if (member.userId.longLongValue == appDelegate.globalObjectHolder.currentUser.identifier.longLongValue)
                     {
                         if (member.payingUserId == 0)
                             weakSelf.payingForCount++;
                     }
                     else if (member.payingUserId.longLongValue == appDelegate.globalObjectHolder.currentUser.identifier.longLongValue)
                         weakSelf.payingForCount++;
                 }
                 [weakSelf updatePaymentValues];
             }else{
                 NSLog(@"setupExistingGroupsData Error:%@",[error userInfo][@"error"]);
             }
             hud.hidden = YES;
         }];
    }
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
                 [weakSelf updatePaymentValues];
             }else{
                 NSLog(@"setupExistingGroupsData Error:%@",[error userInfo][@"error"]);
             }
             hud.hidden = YES;
         }];
    }
}

- (void) updatePaymentValues
{
    if (self.selectedOrder == nil || self.groupMemberCount == 0)
        return;
    [self parsePOSCheckDetails];
    self.txtFinalAmount.text = [UtilCalls rawAmountToString:[NSNumber numberWithDouble:[self finalTotal]]];
    self.txtSubTotal.text = [UtilCalls rawAmountToString:[NSNumber numberWithDouble:([self subTotalNoDiscountMyShare] - [self discount])]];
    self.txtTip.text = [UtilCalls rawAmountToString:[NSNumber numberWithDouble:[self gratuity]]];
    self.txtTax.text = [UtilCalls rawAmountToString:[NSNumber numberWithDouble:[self taxAmount]]];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    GTLStoreendpointStoreTableGroupMember *memberMe = appDelegate.globalObjectHolder.inStoreOrderDetails.memberMe;
    memberMe.finalTotal = [NSNumber numberWithDouble:[self finalTotal]];
    memberMe.subtotal = [NSNumber numberWithDouble:([self subTotalNoDiscountMyShare] - [self discount])];
    memberMe.tip = [NSNumber numberWithDouble:[self gratuity]];
    memberMe.tax = [NSNumber numberWithDouble:([self taxAmount])];
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
    
    RXMLElement *entry = [[[rootXML child:@"GETCHECKDETAILS"] child:@"CHECK"] child:@"DISCOUNTS"];
    self.discountAmt = [UtilCalls stringToNumber:[entry attribute:@"AMOUNT"]].floatValue;
    self.discountName = [entry attribute:@"DISP_NAME"];
    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tipSegmentControllerValueChanged:(id)sender
{
    if (self.tipSegmentController.selectedSegmentIndex == 0)
        self.tipSlider.value = 18;
    else if (self.tipSegmentController.selectedSegmentIndex == 1)
        self.tipSlider.value = 20;
    else if (self.tipSegmentController.selectedSegmentIndex == 2)
        self.tipSlider.value = 25;
    
    [self updatePaymentValues];
}

- (IBAction)tipSliderValueChanged:(id)sender
{
    self.tipSegmentController.selectedSegmentIndex = 2;
    
    [self updatePaymentValues];
}

- (double)subTotalNoDiscountFull
{
    NSUInteger subTotalNoDiscount = 0;
    for (OrderItemSummaryFromPOS *item in self.finalItems)
        subTotalNoDiscount += item.price*item.qty;
    return subTotalNoDiscount;
}

- (double)subTotalNoDiscountMyShare
{
    if (self.groupMemberCount == 0)
        return 0;
    else
        return [self subTotalNoDiscountFull]*self.payingForCount/self.groupMemberCount;
}

- (double)discount
{
    if (self.groupMemberCount == 0)
        return 0;
    else
        return self.discountAmt*self.payingForCount/self.groupMemberCount;
}

- (double)gratuity
{
    return [self subTotalNoDiscountMyShare] * self.tipSlider.value/100;
}

- (double)taxAmount
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    double tax = appDelegate.globalObjectHolder.selectedStore.taxPercent.longValue/10000.0;
    return ([self subTotalNoDiscountMyShare] - [self discount] + [self gratuity])*tax;
}

- (double)finalTotal
{
    return [self subTotalNoDiscountMyShare] - [self discount] + [self gratuity] + [self taxAmount];
}

- (IBAction)payNowClicked:(id)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    if ([self finalTotal] < 1)
        return;
    
    if (self.stripePay.applePayEnabled)
    {
        if (self.stripePay.token == nil)
        {
            NSString *amountStr = [UtilCalls doubleAmountToString:[NSNumber numberWithDouble:[self finalTotal]]];
            NSDecimalNumber *finalAmount = [NSDecimalNumber decimalNumberWithString:amountStr];
            [self.stripePay beginApplePay:self Title:appDelegate.globalObjectHolder.selectedStore.name Label:@"Order" AndAmount:finalAmount];
            return;
        }
    }
    else
    {
        if (appDelegate.globalObjectHolder.defaultUserCard == nil)
        {
            [self performSegueWithIdentifier:@"segueOrderSummaryToSelectPaymentMode" sender:self];
            return;
        }
    }
    
    GTLStoreendpointSplitOrderArguments *orderArguments = [[GTLStoreendpointSplitOrderArguments alloc]init];
    
    if (self.stripePay.applePayEnabled && self.stripePay.token != nil)
        orderArguments.token = self.stripePay.token.tokenId;
    else
    {
        orderArguments.cardid = appDelegate.globalObjectHolder.defaultUserCard.cardId;
        orderArguments.customerId = appDelegate.globalObjectHolder.defaultUserCard.providerCustomerId;
    }
    orderArguments.stgm = appDelegate.globalObjectHolder.inStoreOrderDetails.memberMe;

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Please Wait";
    hud.hidden = NO;
    
    if (self)
    {
        __weak __typeof(self) weakSelf = self;
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
        GTLQueryStoreendpoint *query = [GTLQueryStoreendpoint queryForPayForMemberWithObject:orderArguments];
        
        NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
        dic[USER_AUTH_TOKEN_HEADER_NAME]=[UtilCalls getAuthTokenForCurrentUser];
        
        [query setAdditionalHTTPHeaders:dic];
        
        [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id object,NSError *error)
         {
             if(!error)
             {
                 NSString *title = [NSString stringWithFormat:@"Your Payment - %@", appDelegate.globalObjectHolder.selectedStore.name];
                 NSString *msg = [NSString stringWithFormat:@"Thank you - your payment has been received and will be processed soon."];
                 [appDelegate.globalObjectHolder removeInStoreOrderInProgress];
                 UIAlertView *alert=[[UIAlertView alloc]initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                 [alert show];
                 NotificationUtils *notificationUtils = [[NotificationUtils alloc]init];
                 [notificationUtils scheduleNotificationWithOrder:weakSelf.selectedOrder];
//                 if (self.revealViewController != nil)
//                     [weakSelf performSegueWithIdentifier:@"SWOrderSummaryToStoreList" sender:weakSelf];
//                 else
                     [weakSelf performSegueWithIdentifier:@"segueUnwindBillToStoreList" sender:weakSelf];
             }else{
                 NSLog(@"queryForPayForMemberWithObject Error:%@",[error userInfo][@"error"]);
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
