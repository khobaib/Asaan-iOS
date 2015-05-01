//
//  OrderSummaryViewController.m
//  Savoir
//
//  Created by Nirav Saraiya on 12/7/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import "OrderSummaryViewController.h"
#import "UIColor+SavoirGoldColor.h"
#import "UIColor+SavoirBackgroundColor.h"
#import "AppDelegate.h"
#import "UtilCalls.h"
#import "OnlineOrderSelectedMenuItem.h"
#import "OnlineOrderSelectedModifierGroup.h"
#import "OnlineOrderDetails.h"
#import "MenuTableViewController.h"
#import "MenuModifierGroupViewController.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import <MBProgressHUD.h>
#import "AppDelegate.h"
#import "UIAlertView+Blocks.h"
#import "OrderTypeTableViewController.h"
#import "SelectAddressTableViewController.h"
#import "SelectPaymentTableViewController.h"
#import "InlineCalls.h"
#import "GTLStoreendpointAsaanLongString.h"
#import "GTLStoreendpointPlaceOrderArguments.h"
#import "UtilCalls.h"
#import "NotificationUtils.h"
#import "Constants.h"
#import "XMLPOSOrder.h"
#import "HTMLFaxOrder.h"
#import "OrderDiscountViewController.h"
#import "DiscountReceiver.h"

@interface OrderSummaryViewController () <UITableViewDataSource, UITableViewDelegate, DiscountReceiver>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) OnlineOrderDetails *orderInProgress;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnAdd;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnEdit;
@property (strong, nonatomic) MenuTableViewController *itemInputController;
@property (strong, nonatomic) StripePay *stripePay;

@property (nonatomic) Boolean bInPlaceOrderMode;

@property (nonatomic) NSUInteger selectedIndex;
@end

@implementation OrderSummaryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.stripePay = [[StripePay alloc]init];
    
    if (self.navigationController.viewControllers[0] != self)
        self.navigationItem.leftBarButtonItem = nil;
    else
    {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        [appDelegate.notificationUtils getSlidingMenuBarButtonSetupWith:self];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    appDelegate.topViewController = self;
    
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.barTintColor = [UIColor asaanBackgroundColor];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    self.orderInProgress = appDelegate.globalObjectHolder.orderInProgress;
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (Boolean) placeOrderWithToken:(STPToken *)token
{
    return false;
}

- (IBAction)placeOrder:(id)sender
{
    self.bInPlaceOrderMode = YES;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];

    if (self.orderInProgress == nil)
        return;
    
    if ([StripePay applePayEnabled])
    {
        if (self.stripePay.token == nil)
        {
            NSString *amountStr = [UtilCalls doubleAmountToString:[NSNumber numberWithDouble:[self finalAmount]]];
            NSDecimalNumber *finalAmount = [NSDecimalNumber decimalNumberWithString:amountStr];
            [self.stripePay beginApplePay:self Title:self.selectedStore.name Label:@"Order" AndAmount:finalAmount];
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
    
    if (![self AreDeliveryRequirementsValid])
        return;
    
    
    GTLStoreendpointStoreOrder *order = [[GTLStoreendpointStoreOrder alloc]init];
    
    order.guestCount = [NSNumber numberWithInt:self.orderInProgress.partySize];  // intValue
    order.orderMode = [NSNumber numberWithInt:self.orderInProgress.orderType];  // intValue
    order.storeId = self.selectedStore.identifier;  // longLongValue
    order.storeName = self.selectedStore.name;
    order.subTotal = [UtilCalls doubleAmountToLong:[self subTotal]];
    order.deliveryFee = [UtilCalls doubleAmountToLong:[self deliveryFee]];
    order.serviceCharge = [UtilCalls doubleAmountToLong:[self gratuity]];
    order.tax = [UtilCalls doubleAmountToLong:[self taxAmount]];
    long long finalTotal = [UtilCalls doubleAmountToLong:[self finalAmount]].longLongValue;
    order.finalTotal = [NSNumber numberWithLongLong:finalTotal];
    
    if ([self discountAmount] > 0)
    {
        order.discount = [UtilCalls doubleAmountToLong:[self discountAmount]];
        order.discountDescription = self.orderInProgress.selectedDiscount.title;
    }
    
    GTLStoreendpointPlaceOrderArguments *orderArguments = [[GTLStoreendpointPlaceOrderArguments alloc]init];
    
    if ([StripePay applePayEnabled] && self.stripePay.token != nil)
        orderArguments.token = self.stripePay.token.tokenId;
    else
    {
        orderArguments.userId = appDelegate.globalObjectHolder.defaultUserCard.userId;  // longLongValue
        orderArguments.cardid = appDelegate.globalObjectHolder.defaultUserCard.cardId;
        orderArguments.customerId = appDelegate.globalObjectHolder.defaultUserCard.providerCustomerId;
    }
    
    NSString *strOrder = nil;
    order.orderHTML = [HTMLFaxOrder buildHTMLOrder:self.orderInProgress gratuity:[self gratuity] discountTitle:self.orderInProgress.selectedDiscount.title discountAmount:[self discountAmount] subTotal:[self subTotal] deliveryFee:[self deliveryFee] taxAmount:[self taxAmount] finalAmount:[self finalAmount] orderEstTime:[self orderDateString]];
    
    if (self.selectedStore.providesPosIntegration.boolValue == NO)
    {
        strOrder = order.orderHTML;
        order.orderDetails = [XMLPOSOrder buildPOSResponseXML:self.orderInProgress checkId:0 gratuity:[self gratuity] subTotal:[self subTotal] deliveryFee:[self deliveryFee] taxAmount:[self taxAmount] finalAmount:[self finalAmount] guestCount:order.guestCount.intValue tableNumber:0];
    }
    else
        strOrder = [XMLPOSOrder buildPOSOrder:self.orderInProgress gratuity:[self gratuity]];
    
    orderArguments.strOrder = strOrder;
    orderArguments.order = order;
    
    GTLQueryStoreendpoint *query=[GTLQueryStoreendpoint queryForPlaceOrderWithObject:orderArguments];
    
    NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
    dic[USER_AUTH_TOKEN_HEADER_NAME]=[UtilCalls getAuthTokenForCurrentUser];
    
    [query setAdditionalHTTPHeaders:dic];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    if ([UtilCalls canStore:self.selectedStore fulfillOrderAt:self.orderInProgress.orderTime] == NO)
    {
        NSString *msg = [NSString stringWithFormat:@"%@ cannot accept any online orders at this time.", self.selectedStore.name];
        [UIAlertView showWithTitle:@"Online Order Failure" message:msg cancelButtonTitle:@"Ok" otherButtonTitles:nil
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex)
         {
         }];
    }
    else
    {
        __weak __typeof(self) weakSelf = self;
        GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
        [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket,GTLStoreendpointStoreOrder *object,NSError *error)
        {
            [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
            
            if(error == nil && object.identifier != nil && object.identifier.longLongValue != 0)
            {
                NSString *title = [NSString stringWithFormat:@"Your Order - %@", self.selectedStore.name];
                NSString *msg = [NSString stringWithFormat:@"Thank you - your order has been placed. If you need to make changes please call %@ immediately at %@.", weakSelf.selectedStore.name, weakSelf.selectedStore.phone];
                [appDelegate.globalObjectHolder removeOrderInProgress];
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                [alert show];
                NotificationUtils *notificationUtils = [[NotificationUtils alloc]init];
                [notificationUtils scheduleNotificationWithOrder:object];
                if (self.revealViewController != nil)
                    [weakSelf performSegueWithIdentifier:@"SWOrderSummaryToStoreList" sender:weakSelf];
                else
                    [weakSelf performSegueWithIdentifier:@"segueUnwindOrderSummaryToStoreList" sender:weakSelf];
            }
            else
            {
                NSLog(@"%@",[error userInfo][@"error"]);
                NSString *title = @"Something went wrong";
                NSString *msg = [NSString stringWithFormat:@"We were unable to reach %@ and place your order. We're really sorry. Please call %@ directly at %@ to place your order.", weakSelf.selectedStore.name, weakSelf.selectedStore.name, weakSelf.selectedStore.phone];
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                [alert show];
            }
        }];
    }
}

- (IBAction)cancelOrder:(id)sender
{
    __weak __typeof(self) weakSelf = self;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSString *errMsg = [NSString stringWithFormat:@"Do you want to cancel your current order at %@?", self.selectedStore.name];
    [UIAlertView showWithTitle:@"Cancel your order?" message:errMsg cancelButtonTitle:@"No" otherButtonTitles:@[@"Yes"]
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex)
     {
         if (buttonIndex == [alertView cancelButtonIndex])
             return;
         else
         {
             [appDelegate.globalObjectHolder removeOrderInProgress];
             if (self.revealViewController != nil)
                 [weakSelf performSegueWithIdentifier:@"SWOrderSummaryToStoreList" sender:weakSelf];
             else
                 [weakSelf performSegueWithIdentifier:@"segueUnwindOrderSummaryToStoreList" sender:weakSelf];
         }
     }];
}
- (IBAction)editTable:(id)sender
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

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:YES];
}

#pragma mark -
#pragma mark === DiscountReceiver ===
#pragma mark -

- (void)selectedDiscount:(GTLStoreendpointStoreDiscount *)discount
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    appDelegate.globalObjectHolder.orderInProgress.selectedDiscount = discount;
}

#pragma mark -
#pragma mark  === UITableViewDataSource ===
#pragma mark -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.orderInProgress == nil || self.orderInProgress.selectedMenuItems == nil || self.orderInProgress.selectedMenuItems.count == 0)
        return 0;
    
    if (self.orderInProgress.orderType == OrderTypeTableViewController.ORDERTYPE_CARRYOUT)
        return self.orderInProgress.selectedMenuItems.count + 7;
    else
        return self.orderInProgress.selectedMenuItems.count + 9;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (self.orderInProgress.selectedMenuItems.count <= indexPath.row)
    {
        int realIndex = (int)(indexPath.row - self.orderInProgress.selectedMenuItems.count);
        cell = [self cellForAdditionalRowAtIndex:realIndex forTable:tableView forIndexPath:indexPath];
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"MenuItemCell" forIndexPath:indexPath];
        UILabel *txtMenuItemName = (UILabel *)[cell viewWithTag:501];
        UILabel *txtQty = (UILabel *)[cell viewWithTag:502];
        UILabel *txtAmount = (UILabel *)[cell viewWithTag:503];
        cell.accessoryType = UITableViewCellAccessoryNone;
        OnlineOrderSelectedMenuItem *onlineOrderSelectedMenuItem = [self.orderInProgress.selectedMenuItems objectAtIndex:indexPath.row];
        if (onlineOrderSelectedMenuItem != nil)
        {
            txtMenuItemName.text = onlineOrderSelectedMenuItem.selectedItem.shortDescription;
            txtQty.text = [NSString stringWithFormat:@"%lu", (unsigned long)onlineOrderSelectedMenuItem.qty];
            NSNumber *amount = [[NSNumber alloc] initWithLong:onlineOrderSelectedMenuItem.amount];
            txtAmount.text = [UtilCalls amountToString:amount];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.orderInProgress.selectedMenuItems.count > indexPath.row)
        return UITableViewCellEditingStyleDelete;
    else
        return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If row is deleted, remove it from the list.
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self.orderInProgress.selectedMenuItems removeObjectAtIndex:indexPath.row];
//        if (self.orderInProgress.selectedMenuItems.count > 0)
//            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//        else
        [tableView reloadData];
    }
}
- (double)subTotalNoDiscount
{
    NSUInteger subTotalNoDiscount = 0;
    for (OnlineOrderSelectedMenuItem *onlineOrderSelectedMenuItem in self.orderInProgress.selectedMenuItems)
        subTotalNoDiscount += onlineOrderSelectedMenuItem.amount;
    return subTotalNoDiscount/100.0;
}
- (double)discountAmount // already * by 1000000
{
    GTLStoreendpointStoreDiscount *discount = self.orderInProgress.selectedDiscount;
    if (discount == nil)
        return 0.0;
    
    if (self.orderInProgress.selectedDiscount.percentOrAmount.boolValue == true)
        return discount.value.longLongValue * [self subTotalNoDiscount]/1000000.0;
    else
        return discount.value.longLongValue/100.0;
}

- (double)taxAmount
{
//    NSUInteger taxPercentAmount = 0;
//    for (OnlineOrderSelectedMenuItem *onlineOrderSelectedMenuItem in self.orderInProgress.selectedMenuItems)
//        taxPercentAmount += onlineOrderSelectedMenuItem.amount * onlineOrderSelectedMenuItem.selectedItem.tax.longLongValue;
//    return taxPercentAmount;
    if (self.orderInProgress.orderType == OrderTypeTableViewController.ORDERTYPE_CARRYOUT)
        return ([self subTotal] + [self gratuity])*self.selectedStore.taxPercent.longLongValue/10000.0;
    else
        return ([self subTotal] + [self gratuity] + [self deliveryFee])*self.selectedStore.taxPercent.longLongValue/10000.0;
}

- (double)gratuity
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    if (appDelegate.globalObjectHolder.currentUser.defaultTip.longValue == 0)
        return [self subTotalNoDiscount] * 0.18;
    else
        return [self subTotalNoDiscount] * appDelegate.globalObjectHolder.currentUser.defaultTip.longValue/100;
}

- (double)subTotal  // already * by 1000000
{
    if (self.orderInProgress.selectedDiscount.percentOrAmount.boolValue == true)
        return [self subTotalNoDiscount] - [self discountAmount];
    else
        return [self subTotalNoDiscount] - [self discountAmount];
}

- (double)deliveryFee // $5 - fixed for now
{
    return self.selectedStore.deliveryFee.intValue/100.0;
}

- (double)finalAmount
{
    if (self.orderInProgress.orderType == OrderTypeTableViewController.ORDERTYPE_CARRYOUT)
        return ([self subTotal] + [self gratuity] + [self taxAmount]);
    else
        return ([self subTotal] + [self gratuity] + [self taxAmount] + [self deliveryFee]);
}

- (NSString *)orderDateString
{
    NSDate *currentTime = [NSDate date];
    NSDate *newTime = self.orderTime;
    
    NSDate *minOrderTime = [[NSDate alloc] initWithTimeInterval:3600
                                                      sinceDate:currentTime];
    NSDate *orderTime = [newTime laterDate:minOrderTime];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm a"];
    return [dateFormatter stringFromDate: orderTime];
}

- (UITableViewCell *)cellForAdditionalRowAtIndex:(int)index forTable:(UITableView *)tableView forIndexPath:indexPath
{
    if (self.orderInProgress.orderType == OrderTypeTableViewController.ORDERTYPE_CARRYOUT && index > 2)
        index++;
    if (self.orderInProgress.orderType == OrderTypeTableViewController.ORDERTYPE_CARRYOUT && index > 6)
        index++;

    UITableViewCell *cell;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    switch (index)
    {
        case 0: // Discount
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"MenuItemCell" forIndexPath:indexPath];
            UILabel *txtMenuItemName = (UILabel *)[cell viewWithTag:501];
            UILabel *txtQty = (UILabel *)[cell viewWithTag:502];
            UILabel *txtAmount = (UILabel *)[cell viewWithTag:503];
            cell.tag = 703;
            txtQty.text = nil;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

            NSString *discount = appDelegate.globalObjectHolder.orderInProgress.selectedDiscount.title;
            if (IsEmpty(discount))
            {
                discount = @"(Not specified)";
                txtAmount.text = nil;
            }
            else
            {
                NSNumber *amount = [[NSNumber alloc] initWithDouble:[self discountAmount]];
                txtAmount.text = [NSString stringWithFormat:@"%@-", [UtilCalls doubleAmountToString:amount]];
            }
            txtMenuItemName.text = [NSString stringWithFormat:@"Discount %@", discount];
            break;
        }
        case 1: // Subtotal
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"MenuItemCellNoDisclosure" forIndexPath:indexPath];
            UILabel *txtMenuItemName = (UILabel *)[cell viewWithTag:501];
            UILabel *txtQty = (UILabel *)[cell viewWithTag:502];
            UILabel *txtAmount = (UILabel *)[cell viewWithTag:503];
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            txtMenuItemName.text = @"Subtotal";
            txtQty.text = nil;
            NSNumber *amount = [[NSNumber alloc] initWithDouble:[self subTotal]];
            txtAmount.text = [UtilCalls doubleAmountToString:amount];
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
        }
        case 2: // Gratuity
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"MenuItemCellNoDisclosure" forIndexPath:indexPath];
            UILabel *txtMenuItemName = (UILabel *)[cell viewWithTag:501];
            UILabel *txtQty = (UILabel *)[cell viewWithTag:502];
            UILabel *txtAmount = (UILabel *)[cell viewWithTag:503];
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            txtMenuItemName.text = @"Gratuity";
            txtQty.text = nil;
            NSNumber *percentAmount = [[NSNumber alloc] initWithDouble:[self gratuity]];
            txtAmount.text = [UtilCalls doubleAmountToString:percentAmount];
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
        }
        case 3: // Delivery Fee
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"MenuItemCellNoDisclosure" forIndexPath:indexPath];
            UILabel *txtMenuItemName = (UILabel *)[cell viewWithTag:501];
            UILabel *txtQty = (UILabel *)[cell viewWithTag:502];
            UILabel *txtAmount = (UILabel *)[cell viewWithTag:503];
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            txtMenuItemName.text = @"Delivery";
            txtQty.text = nil;
            NSNumber *amount = [[NSNumber alloc] initWithLong:[self deliveryFee]];
            txtAmount.text = [UtilCalls doubleAmountToString:amount];
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
        }
        case 4: // Tax
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"MenuItemCellNoDisclosure" forIndexPath:indexPath];
            UILabel *txtMenuItemName = (UILabel *)[cell viewWithTag:501];
            UILabel *txtQty = (UILabel *)[cell viewWithTag:502];
            UILabel *txtAmount = (UILabel *)[cell viewWithTag:503];
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            txtMenuItemName.text = @"Tax";
            txtQty.text = nil;
            NSNumber *amount = [[NSNumber alloc] initWithDouble:[self taxAmount]];
            txtAmount.text = [UtilCalls doubleAmountToString:amount];
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
        }
        case 5: // Final Total
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"MenuItemCellNoDisclosure" forIndexPath:indexPath];
            UILabel *txtMenuItemName = (UILabel *)[cell viewWithTag:501];
            UILabel *txtQty = (UILabel *)[cell viewWithTag:502];
            UILabel *txtAmount = (UILabel *)[cell viewWithTag:503];
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            txtMenuItemName.text = @"Final Amount";
            txtQty.text = nil;
            NSNumber *amount = [[NSNumber alloc] initWithDouble:[self finalAmount]];
            txtAmount.text = [UtilCalls doubleAmountToString:amount];
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
        }
        case 6: // Estimated Delivery Time
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"OtherCell" forIndexPath:indexPath];
            cell.textLabel.text = [NSString stringWithFormat:@"Est. Delivery Time %@", [self orderDateString]];
            break;
        }
        case 7: // Delivery Address
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"OtherCell" forIndexPath:indexPath];
            NSString *address = appDelegate.globalObjectHolder.defaultUserAddress.fullAddress;
            if (IsEmpty(address))
                address = @"(Not specified)";
            cell.textLabel.text = [NSString stringWithFormat:@"Delivery Address %@", address];
            cell.tag = 701;
            break;
        }
        case 8: // Payment Mode
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"OtherCell" forIndexPath:indexPath];
            NSString *card = appDelegate.globalObjectHolder.defaultUserCard.last4;
            
            if ([StripePay applePayEnabled])
                cell.textLabel.text = @"Payment Mode Apple Pay";
            else if (IsEmpty(card))
                card = @"(Not specified)";
            cell.textLabel.text = [NSString stringWithFormat:@"Payment Mode %@", card];
            cell.tag = 702;
            break;
        }
//        case 9: // Special Instructions
//        {
//            cell = [tableView dequeueReusableCellWithIdentifier:@"OtherCell" forIndexPath:indexPath];
//            cell.textLabel.text = [NSString stringWithFormat:@"Special Instructions %@", self.orderInProgress.specialInstructions];
//            break;
//        }
        default:
            break;
    }
    return cell;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewCell *headerCell = [tableView dequeueReusableCellWithIdentifier:@"HeaderCell"];
    if (self.selectedStore != nil)
        [UtilCalls setupHeaderView:headerCell WithTitle:self.selectedStore.name AndSubTitle:@"Order Summary"];
    return headerCell;
}

#pragma mark -
#pragma mark === UITableViewDelegate ===
#pragma mark -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //segueOrderSummaryToModifierGroup
    self.selectedIndex = indexPath.row;
    if (self.orderInProgress.selectedMenuItems.count > indexPath.row)
    {
        [self performSegueWithIdentifier:@"segueOrderSummaryToModifierGroup" sender:self];
        return;
    }
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (cell.tag == 701)
        [self performSegueWithIdentifier:@"segueOrderSummaryToSelectAddress" sender:self];
    else if (cell.tag == 702)
        [self performSegueWithIdentifier:@"segueOrderSummaryToSelectPaymentMode" sender:self];
    else if (cell.tag == 703)
        [self performSegueWithIdentifier:@"segueOrderSummaryToAddDiscount" sender:self];
}

- (Boolean) isDefaultUserAddressValidForStoreDelivery
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    if(appDelegate.globalObjectHolder.defaultUserAddress == nil)
        return NO;
    
    GTLUserendpointUserAddress *userAddress = appDelegate.globalObjectHolder.defaultUserAddress;
    CLLocation* first = [[CLLocation alloc] initWithLatitude:userAddress.lat.doubleValue longitude:userAddress.lng.doubleValue];
    
    return [UtilCalls isDistanceBetweenPointA:first AndStore:self.selectedStore withinRange:self.selectedStore.deliveryDistance.intValue];
}

- (Boolean)AreDeliveryRequirementsValid
{
    if (self.orderInProgress.orderType == [OrderTypeTableViewController ORDERTYPE_DELIVERY])
    {
        if (![self isDefaultUserAddressValidForStoreDelivery])
        {
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
            if (appDelegate.globalObjectHolder.defaultUserAddress != nil)
            {
                __block Boolean bReturn = NO;
                __weak __typeof(self) weakSelf = self;
                NSString *errMsg = [NSString stringWithFormat:@"%@ does not deliver to your %@ address. what do you want to do?", self.selectedStore.name, appDelegate.globalObjectHolder.defaultUserAddress.name];
                [UIAlertView showWithTitle:@"Address outside delivery range" message:errMsg cancelButtonTitle:@"Switch to Carryout" otherButtonTitles:@[@"Change Address", @"Cancel"]
                                  tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex)
                 {
                     if (buttonIndex == [alertView cancelButtonIndex])
                     {
                         weakSelf.orderInProgress.orderType = [OrderTypeTableViewController ORDERTYPE_CARRYOUT];
                         [weakSelf.tableView reloadData];
                         bReturn = YES;
                     }
                     else if (buttonIndex == 1)
                     {
                         [weakSelf performSegueWithIdentifier:@"segueOrderSummaryToSelectAddress" sender:weakSelf];
                         bReturn = NO;
                     }
                     else
                         bReturn = NO;
                 }];
                return bReturn;
            }
            else
            {
                [self performSegueWithIdentifier:@"segueOrderSummaryToSelectAddress" sender:self];
                return NO;
            }
        }
    }
    return YES;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
 
    if ([[segue identifier] isEqualToString:@"segueOrderSummaryToMenu"])
    {
        MenuTableViewController *controller = [segue destinationViewController];
        [controller setSelectedStore:self.selectedStore];
        [controller setOrderType:self.orderType];
        [controller setPartySize:self.partySize];
        [controller setOrderTime:self.orderTime];
        [controller setBMenuIsInOrderMode:YES];
    }
    else if ([[segue identifier] isEqualToString:@"segueOrderSummaryToModifierGroup"])
    {
        MenuModifierGroupViewController *controller = [segue destinationViewController];
        [controller setSelectedIndex:self.selectedIndex];
        [controller setBInEditMode:YES];
    }
    else if ([[segue identifier] isEqualToString:@"segueOrderSummaryToSelectAddress"])
    {
        SelectAddressTableViewController *controller = [segue destinationViewController];
        [controller setSelectedStore:self.selectedStore];
    }
    else if ([[segue identifier] isEqualToString:@"segueInstorePayToOrderDiscountViewController"])
    {
        OrderDiscountViewController *controller = [segue destinationViewController];
        [controller setSelectedStore:self.selectedStore];
        [controller setReceiver:self];
    }
}

- (IBAction)unwindToOrderSummary:(UIStoryboardSegue *)unwindSegue
{
    UIViewController *cc = [unwindSegue sourceViewController];
    
    //segueunwindSelectPaymentToOrderSummary
    if ([cc isKindOfClass:[SelectPaymentTableViewController class]])
    {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        if(appDelegate.globalObjectHolder.defaultUserCard == nil)
            return;
        
        if (self.bInPlaceOrderMode)
        {
            if (![self AreDeliveryRequirementsValid])
                return;
            [self placeOrder:self];
        }
    }
    //segueunwindSelectAddressToOrderSummary
    if ([cc isKindOfClass:[SelectAddressTableViewController class]])
    {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        if(appDelegate.globalObjectHolder.defaultUserAddress == nil)
            return;
        
        if (self.bInPlaceOrderMode)
            [self placeOrder:self];
    }
}
@end
