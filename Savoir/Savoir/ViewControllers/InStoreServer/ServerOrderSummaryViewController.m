//
//  ServerOrderSummaryViewController.m
//  Savoir
//
//  Created by Nirav Saraiya on 4/8/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import "ServerOrderSummaryViewController.h"
#import "AppDelegate.h"
#import "OrderItemSummaryFromPOS.h"
#import "RXMLElement.h"
#import "OrderedDictionary.h"
#import "InlineCalls.h"
#import "UtilCalls.h"
#import "MBProgressHUD.h"
#import "GTLStoreendpointStoreOrder.h"
#import "XMLPOSOrder.h"
#import "ServerSelectGroupTableViewController.h"
#import "MenuTableViewController.h"
#import "OrderTypeTableViewController.h"
#import "OrderDiscountViewController.h"
#import "DiscountReceiver.h"
#import "UIAlertView+Blocks.h"

@interface ServerOrderSummaryViewController ()<UITableViewDataSource, UITableViewDelegate, DiscountReceiver, GroupSelectionReceiver>
@property (weak, nonatomic) IBOutlet UITextField *txtTable;
@property (weak, nonatomic) IBOutlet UITextField *txtCheckId;
@property (weak, nonatomic) IBOutlet UITextField *txtPartySize;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnEdit;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnAdd;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *finalItems;
@property (strong, nonatomic) NSString *XMLOrderStr;
@property (nonatomic) Boolean bSaveClicked;
@property (nonatomic) Boolean bCloseClicked;
@property (strong, nonatomic) GTLStoreendpointStoreTableGroup *selectedTableGroup;

@end

@implementation ServerOrderSummaryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    if (self.navigationController.viewControllers[0] != self)
        self.navigationItem.leftBarButtonItem = nil;
    else
    {
        [appDelegate.notificationUtils getSlidingMenuBarButtonSetupWith:self];
    }

    self.txtTable.text = [NSString stringWithFormat:@"%d", appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.order.tableNumber.intValue];
    self.txtPartySize.text = [NSString stringWithFormat:@"%d", appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.order.guestCount.intValue];
    self.txtCheckId.text = [NSString stringWithFormat:@"%d", appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.order.poscheckId.intValue];
    self.XMLOrderStr = appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.order.orderDetails;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.bCloseClicked = false;
    self.bSaveClicked = false;
    
    [self updateOrderStringFromOrderInProgress];
    self.finalItems = [XMLPOSOrder parseOrderDetails:self.XMLOrderStr];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self saveClicked];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:YES];
}

#pragma mark -
#pragma mark === TableOrderReceiver ===
#pragma mark -

- (void) changedGroupSelection:(GTLStoreendpointStoreTableGroup *)tableGroup
{
    self.selectedTableGroup = tableGroup;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.finalItems.count == 0)
        return 0;
    else
        return self.finalItems.count + 2; // Two extra rows for discount and subtotal
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (self.finalItems.count <= indexPath.row)
    {
        int realIndex = (int)(indexPath.row - self.finalItems.count);
        cell = [self cellForAdditionalRowAtIndex:realIndex forTable:tableView forIndexPath:indexPath];
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"MenuItemCell" forIndexPath:indexPath];
        UILabel *txtMenuItemName = (UILabel *)[cell viewWithTag:501];
        UILabel *txtQty = (UILabel *)[cell viewWithTag:502];
        UILabel *txtAmount = (UILabel *)[cell viewWithTag:503];
        UILabel *txtDesc = (UILabel *)[cell viewWithTag:504];
        txtDesc.text = nil;
        txtMenuItemName.text = nil;
        txtQty.text = nil;
        txtAmount.text = nil;
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        OrderItemSummaryFromPOS *item = [self.finalItems objectAtIndex:indexPath.row];
        if (item != nil)
        {
            txtMenuItemName.text = item.name;
            txtQty.text = [NSString stringWithFormat:@"%d", item.qty];
            txtAmount.text = [NSString stringWithFormat:@"%@", [UtilCalls rawAmountToString:[NSNumber numberWithDouble:item.price]]];
            txtDesc.text = item.desc;
        }
    }
    
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (UITableViewCell *)cellForAdditionalRowAtIndex:(int)index forTable:(UITableView *)tableView forIndexPath:indexPath
{
    UITableViewCell *cell;
    switch (index)
    {
        case 0: // Discount
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"MenuItemCell" forIndexPath:indexPath];
            cell.tag = 703;

            UILabel *txtMenuItemName = (UILabel *)[cell viewWithTag:501];
            UILabel *txtQty = (UILabel *)[cell viewWithTag:502];
            UILabel *txtAmount = (UILabel *)[cell viewWithTag:503];
            UILabel *txtDesc = (UILabel *)[cell viewWithTag:504];
            
            txtDesc.text = nil;
            txtMenuItemName.text = nil;
            txtQty.text = nil;
            txtAmount.text = nil;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            txtMenuItemName.text = @"Discount";
            NSString *discount = [self discountTitle];
            if (!IsEmpty(discount))
            {
                NSNumber *amount = [[NSNumber alloc] initWithDouble:[self discountAmount]];
                txtAmount.text = [NSString stringWithFormat:@"%@-", [UtilCalls doubleAmountToString:amount]];
                txtDesc.text = discount;
            }
            else
                txtDesc.text = @"No Discount Selected";
            break;
        }
        case 1: // Subtotal
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"MenuItemCell" forIndexPath:indexPath];
            cell.tag = 704;
            
            UILabel *txtMenuItemName = (UILabel *)[cell viewWithTag:501];
            UILabel *txtQty = (UILabel *)[cell viewWithTag:502];
            UILabel *txtAmount = (UILabel *)[cell viewWithTag:503];
            UILabel *txtDesc = (UILabel *)[cell viewWithTag:504];
            
            txtDesc.text = nil;
            txtMenuItemName.text = nil;
            txtQty.text = nil;
            txtAmount.text = nil;
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            txtMenuItemName.text = @"Subtotal";
            NSNumber *amount = [[NSNumber alloc] initWithDouble:[self subTotal]];
            txtAmount.text = [UtilCalls doubleAmountToString:amount];
            break;
        }
        default:
            break;
    }
    return cell;
}

#pragma mark -
#pragma mark === UITableViewDelegate ===
#pragma mark -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (cell.tag == 703)
    {
        UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        OrderDiscountViewController *destination = [mainStoryBoard instantiateViewControllerWithIdentifier:@"OrderDiscountViewController"];
        
        UIStoryboardSegue *segue = [UIStoryboardSegue segueWithIdentifier:@"segueInstorePayToOrderDiscountViewController" source:self destination:destination performHandler:^(void) {
            //view transition/animation
            [self.navigationController pushViewController:destination animated:YES];
        }];
        
        [self shouldPerformSegueWithIdentifier:segue.identifier sender:self];//optional
        [self prepareForSegue:segue sender:self];
        
        [segue perform];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.finalItems.count + 1 == indexPath.row)
        return UITableViewCellEditingStyleNone;
    else
        return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If row is deleted, remove it from the list.
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        if (indexPath.row == self.finalItems.count)
        {
            [self selectedDiscount:nil];
        }
        else
        {
            OrderItemSummaryFromPOS *item = [self.finalItems objectAtIndex:indexPath.row];
            int deletedEntryId = item.entryId;
            for (OrderItemSummaryFromPOS *anotherItem in self.finalItems)
            {
                if (anotherItem.entryId == deletedEntryId || anotherItem.parentEntryId == deletedEntryId)
                {
                    NSLog(@"%@", self.XMLOrderStr);
                    self.XMLOrderStr = [XMLPOSOrder buildPOSResponseXMLByRemovingItem:anotherItem.entryId FromOrderString:self.XMLOrderStr];
                }
            }
            self.finalItems = [XMLPOSOrder parseOrderDetails:self.XMLOrderStr];
        }
        [self.tableView reloadData];
    }
}

#pragma mark -
#pragma mark === DiscountReceiver ===
#pragma mark -

- (void)selectedDiscount:(GTLStoreendpointStoreDiscount *)discount
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    appDelegate.globalObjectHolder.inStoreOrderDetails.selectedDiscount = discount;
    self.XMLOrderStr = [XMLPOSOrder replaceDiscountIdWith:discount.identifier.longLongValue Description:discount.title IsPercent:discount.percentOrAmount.intValue Value:discount.value.intValue Amount:[self discountAmount] InOrderString:self.XMLOrderStr];
}

#pragma mark -
#pragma mark === Private Implementation ===
#pragma mark -

- (double)subTotalNoDiscount
{
    NSUInteger subTotalNoDiscount = 0;
    for (OrderItemSummaryFromPOS *item in self.finalItems)
        subTotalNoDiscount += item.price;
    return subTotalNoDiscount;
}

- (double)discountAmount // already * by 1000000
{
//    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
//    GTLStoreendpointStoreDiscount *discount = appDelegate.globalObjectHolder.inStoreOrderDetails.selectedDiscount;
//    if (discount == nil)
//        return 0;
//    if (discount.percentOrAmount.boolValue == true)
//        return ([self subTotalNoDiscount]*discount.value.intValue/100);
//    else
//        return discount.value.intValue/100;
    GTLStoreendpointStoreDiscount *discount = [XMLPOSOrder getDiscountFromXML:self.XMLOrderStr];
        if (discount == nil)
            return 0;
        if (discount.percentOrAmount.boolValue == true)
            return ([self subTotalNoDiscount]*discount.value.intValue/100);
        else
            return discount.value.intValue/100;
}

- (NSString *)discountTitle
{
    GTLStoreendpointStoreDiscount *discount = [XMLPOSOrder getDiscountFromXML:self.XMLOrderStr];
    return discount.title;
}

- (double)subTotal  // already * by 1000000
{
    return [self subTotalNoDiscount] - [self discountAmount];
}

- (void)saveClicked
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    int tableNumber = [self.txtTable.text intValue];
    int guestCount = [self.txtPartySize.text intValue];
    int poscheckId = [self.txtCheckId.text intValue];
    double subTotal = ([self subTotalNoDiscount] - [self discountAmount]);
    
    self.XMLOrderStr = [XMLPOSOrder replaceValuesInOrderString:self.XMLOrderStr gratuity:0.0 subTotal:subTotal deliveryFee:0.0 taxAmount:0.0 finalAmount:0.0 checkId:poscheckId guestCount:guestCount tableNumber:tableNumber];
    
    if (tableNumber == 0 && guestCount == 0 && poscheckId == 0 && subTotal == 0 && IsEmpty(self.XMLOrderStr))
    {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        return;
    }
    
    if (self.bCloseClicked == true || self.bSaveClicked == true)
        [self saveStoreOrder];
    
    if (IsEmpty(self.XMLOrderStr) == false && [appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.order.orderDetails isEqualToString:self.XMLOrderStr] == false)
        [self saveStoreOrder];
    
    if (self.selectedTableGroup != nil && (appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.order.identifier.longLongValue > 0))
        [self saveStoreOrder];

    if (tableNumber != appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.order.tableNumber.intValue ||
        guestCount != appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.order.guestCount.intValue ||
        poscheckId != appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.order.poscheckId.intValue)
        [self saveStoreOrder];
}

- (void)saveStoreOrder
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
    
    int tableNumber = [self.txtTable.text intValue];
    int guestCount = [self.txtPartySize.text intValue];
    int poscheckId = [self.txtCheckId.text intValue];
    double subTotal = ([self subTotalNoDiscount] - [self discountAmount]);

    if (appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.order == nil)
    {
        appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.order = [[GTLStoreendpointStoreOrder alloc]init];
        appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.order.storeId = appDelegate.globalObjectHolder.inStoreOrderDetails.selectedStore.identifier;
        appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.order.storeName = appDelegate.globalObjectHolder.inStoreOrderDetails.selectedStore.name;
        appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.order.orderMode = [NSNumber numberWithInt:[OrderTypeTableViewController ORDERTYPE_DININGIN]];
    }
    
    appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.order.orderDetails = self.XMLOrderStr;
    appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.order.tableNumber = [NSNumber numberWithInt:tableNumber];
    appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.order.guestCount = [NSNumber numberWithInt:guestCount];
    appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.order.poscheckId = [NSNumber numberWithInt:poscheckId];
    appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.order.subTotal = [NSNumber numberWithInt:subTotal*100];
    appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.order.discount = [NSNumber numberWithInt:[self discountAmount]*100];
    appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.order.discountDescription = [self discountTitle];
    
    
    if (self.selectedTableGroup.identifier.longLongValue > 0)
        appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.order.storeTableGroupId = self.selectedTableGroup.identifier;
    if (self.bCloseClicked == true)
        appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.order.orderStatus = [NSNumber numberWithInt:5]; //Close table
    
    GTLQueryStoreendpoint *query = [GTLQueryStoreendpoint queryForUpdateOrderFromServerWithObject:appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.order];
    
    NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
    dic[USER_AUTH_TOKEN_HEADER_NAME]=[UtilCalls getAuthTokenForCurrentUser];
    
    [query setAdditionalHTTPHeaders:dic];
    
    __weak __typeof(self) weakSelf = self;
    [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLStoreendpointStoreOrder *object, NSError *error)
     {
         if(error)
         {
             [[[UIAlertView alloc]initWithTitle:@"Order Change Error" message:[error userInfo][@"error"] delegate:weakSelf cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
             NSLog(@"ServerOrderSummary: queryForUpdateOrderFromServerWithObject Error:%@",[error userInfo][@"error"]);
         }
         else
         {
             appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.order = object;
             [weakSelf.receiver changedOrder:appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.order];
             if (weakSelf.bCloseClicked == true || weakSelf.bSaveClicked == true)
                 [weakSelf performSegueWithIdentifier:@"segueUnwindOrderToServerTable" sender:weakSelf];
             [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
         }
     }];
}

- (void)updateOrderStringFromOrderInProgress
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    int tableNumber = [self.txtTable.text intValue];
    int guestCount = [self.txtPartySize.text intValue];
    int poscheckId = [self.txtCheckId.text intValue];
    
    if(appDelegate.globalObjectHolder.orderInProgress == nil)
        return;
    NSString *XMLOrderStr;
    
    if (IsEmpty(self.XMLOrderStr) == true)
        XMLOrderStr = [XMLPOSOrder buildPOSResponseXML:appDelegate.globalObjectHolder.orderInProgress checkId:poscheckId gratuity:0.0 subTotal:0 deliveryFee:0 taxAmount:0 finalAmount:0 guestCount:guestCount tableNumber:tableNumber];
    else
        XMLOrderStr = [XMLPOSOrder buildPOSResponseXMLByAddingNewItems:appDelegate.globalObjectHolder.orderInProgress ToOrderString:self.XMLOrderStr];
    self.XMLOrderStr = XMLOrderStr;
    appDelegate.globalObjectHolder.orderInProgress = nil;
}
//
//- (MutableOrderedDictionary *)getCheckItemsFromXML:(NSString *)strPOSCheckDetails
//{
//    if (IsEmpty(strPOSCheckDetails))
//        return nil;
//    RXMLElement *rootXML = [RXMLElement elementFromXMLString:strPOSCheckDetails encoding:NSUTF8StringEncoding];
//    if (rootXML == nil)
//        return nil;
//    //    NSArray *rxmlEntries = [[[rootXML child:@"GETCHECKDETAILS"] child:@"CHECK"] children:@"ENTRIES"];
//    MutableOrderedDictionary *items = [[MutableOrderedDictionary alloc]init];
//
//    int position = 0;
//    NSArray *allEntries = [[[[rootXML child:@"GETCHECKDETAILS"] child:@"CHECK"] child:@"ENTRIES"] children:@"ENTRY"];
//
//    for (RXMLElement *entry in allEntries)
//    {
//        OrderItemSummaryFromPOS *orderItemSummaryFromPOS = [[OrderItemSummaryFromPOS alloc]init];
//        orderItemSummaryFromPOS.posMenuItemId = [UtilCalls stringToNumber:[entry attribute:@"ITEMID"]].intValue;
//        orderItemSummaryFromPOS.qty = [UtilCalls stringToNumber:[entry attribute:@"QUANTITY"]].intValue;
//        orderItemSummaryFromPOS.price = [UtilCalls stringToNumber:[entry attribute:@"PRICE"]].floatValue;
//        orderItemSummaryFromPOS.name = [entry attribute:@"DISP_NAME"];
//        orderItemSummaryFromPOS.desc = [entry attribute:@"OPTION"];
//        orderItemSummaryFromPOS.entryId = [UtilCalls stringToNumber:[entry attribute:@"ID"]].intValue;
//        orderItemSummaryFromPOS.position = position++;
//
//        [items setObject:orderItemSummaryFromPOS forKey:[NSNumber numberWithLong:orderItemSummaryFromPOS.entryId]];
//    }
//
//    return items;
//}
//
//- (void) parsePOSCheckDetails
//{
//    MutableOrderedDictionary *items = [self getCheckItemsFromXML:appDelegate.globalObjectHolder.inStoreOrderDetails.order.orderDetails];
//    self.finalItems = [[NSMutableArray alloc]init];
//    for (int i = 0; i < items.count; i++)
//    {
//        OrderItemSummaryFromPOS *item = [items objectAtIndex:i];
//        [self.finalItems addObject:item];
//    }
//}

#pragma mark -
#pragma mark === Button Actions ===
#pragma mark -

- (IBAction)btnEditClicked:(id)sender
{
    if (self.btnEdit.tag == 0) // start editing
    {
        [self setEditing:YES animated:YES];
        self.btnEdit.title = @"Done";
        self.btnEdit.tag = 1;
        self.btnAdd.enabled = NO;
    }
    else
    {
        [self setEditing:NO animated:YES];
        self.btnEdit.title = @"Edit";
        self.btnEdit.tag = 0;
        self.btnAdd.enabled = YES;
    }
}

- (IBAction)btnAddClicked:(id)sender
{
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MenuTableViewController *destination = [mainStoryBoard instantiateViewControllerWithIdentifier:@"MenuTableViewController"];
    
    UIStoryboardSegue *segue = [UIStoryboardSegue segueWithIdentifier:@"segueServerOrderSummaryToMenu" source:self destination:destination performHandler:^(void) {
        //view transition/animation
        [self.navigationController pushViewController:destination animated:YES];
    }];
    
    [self shouldPerformSegueWithIdentifier:segue.identifier sender:sender];//optional
    [self prepareForSegue:segue sender:sender];
    
    [segue perform];
}
- (IBAction)btnCloseClicked:(id)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    if (appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.order == nil)
    {
        [[[UIAlertView alloc]initWithTitle:@"Close Order" message:@"Cannot close an unsaved order. Please save order first." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        return;
    }
    if (appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.order.storeTableGroupId.longLongValue > 0 &&
        appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.order.orderStatus.intValue < 4)
    {
        NSString *title = [NSString stringWithFormat:@"Closing an unpaid Savoir order!"];
        NSString *msg = [NSString stringWithFormat:@"This order has a Savoir Group attached to it and is not paid. Would you still like to close it?"];
        [UIAlertView showWithTitle:title message:msg cancelButtonTitle:@"No" otherButtonTitles:@[@"Close Order"]
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex)
         {
             if (buttonIndex != [alertView cancelButtonIndex])
             {
                 self.bCloseClicked = true;
                 [self saveClicked];
             }
         }];
    }
    else
    {
        self.bCloseClicked = true;
        [self saveClicked];
    }
}
- (IBAction)btnSaveClicked:(id)sender
{
    self.bSaveClicked = true;
    [self saveClicked];
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    if ([[segue identifier] isEqualToString:@"segueShowServerOrderToSelectGroup"])
    {
        ServerSelectGroupTableViewController *controller = [segue destinationViewController];
        [controller setSelectedOrder:appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.order];
        [controller setReceiver:self];
    }
    else if ([[segue identifier] isEqualToString:@"segueServerOrderSummaryToMenu"])
    {
        MenuTableViewController *controller = [segue destinationViewController];
        [controller setSelectedStore:appDelegate.globalObjectHolder.inStoreOrderDetails.selectedStore];
        [controller setBMenuIsInOrderMode:YES];
    }
    else if ([[segue identifier] isEqualToString:@"segueInstorePayToOrderDiscountViewController"])
    {
        OrderDiscountViewController *controller = [segue destinationViewController];
        [controller setSelectedStore:appDelegate.globalObjectHolder.inStoreOrderDetails.selectedStore];
        [controller setReceiver:self];
    }
}

- (IBAction)unwindToServerOrderSummary:(UIStoryboardSegue *)unwindSegue
{
}

@end
