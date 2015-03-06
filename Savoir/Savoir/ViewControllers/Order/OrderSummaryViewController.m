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
#import "DeliveryOrCarryoutViewController.h"
#import "SelectAddressTableViewController.h"
#import "SelectPaymentTableViewController.h"
#import "InlineCalls.h"
#import "GTLStoreendpointAsaanLongString.h"
#import "UtilCalls.h"
#import "NotificationUtils.h"
#import "Constants.h"

@interface OrderSummaryViewController () <UITableViewDataSource, UITableViewDelegate>
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
    
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.barTintColor = [UIColor asaanBackgroundColor];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
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
    
    if (self.stripePay.applePayEnabled)
    {
        if (self.stripePay.token == nil)
        {
            NSNumber *amount = [[NSNumber alloc] initWithLong:[self finalAmount]];
            NSString *amountStr = [UtilCalls percentAmountToString:amount];
            NSDecimalNumber *finalAmount = [NSDecimalNumber decimalNumberWithString:amountStr];
            [self.stripePay beginApplePay:self Title:self.orderInProgress.selectedStore.name Label:@"Order" AndAmount:finalAmount];
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
    
    NSString *strItems = @"<ITEMREQUESTS>";
    for (OnlineOrderSelectedMenuItem *object in self.orderInProgress.selectedMenuItems)
    {
        NSString *itemString=[NSString stringWithFormat:@"<ADDITEM QTY=\"%lu\" ITEMID=\"%@\" >",(unsigned long)object.qty,object.selectedItem.menuItemPOSId];
        strItems=[strItems stringByAppendingString:itemString];
        for (OnlineOrderSelectedModifierGroup *modGroup in object.selectedModifierGroups)
        {
            for (int i = 0; i < modGroup.selectedModifierIndexes.count; i++)
            {
                NSNumber *value = [modGroup.selectedModifierIndexes objectAtIndex:i];
                if (value.boolValue)
                {
                    GTLStoreendpointStoreMenuItemModifier *modifier = [modGroup.modifiers objectAtIndex:i];
                    NSString *modString=[NSString stringWithFormat:@"<MODITEM QTY=\"1\" ITEMID=\"%@\" />",modifier.modifierPOSId];
                    strItems=[strItems stringByAppendingString:modString];
                }
            }
        }
        strItems=[strItems stringByAppendingString:@"</ADDITEM>"];
    }
    strItems=[strItems stringByAppendingString:@"</ITEMREQUESTS>"];
    
    NSString *discountStr;
    if (self.orderInProgress.selectedDiscount != nil)
    {
        NSString *discountAmtOrPercent = [UtilCalls amountToStringNoCurrency:[NSNumber numberWithLongLong:self.orderInProgress.selectedDiscount.value.longLongValue]];
        discountStr = [NSString stringWithFormat:@"<DISCOUNTS ID=\"%lld\" AMOUNT=\"%@\" REFERENCE=\"Discounts FROM ASAAN\" />", self.orderInProgress.selectedDiscount.posDiscountId.longLongValue, discountAmtOrPercent];
        strItems=[strItems stringByAppendingString:discountStr];
    }
    
    NSString *gratuityStr;
    if ([self gratuity] > 0)
    {
//        gratuityStr = [NSString stringWithFormat:@"<SERVICECHARGES ID=\"%d\" AMOUNT=\"%@\" REFERENCE=\"SVC CHRG FROM ASAAN\" />", 902, [UtilCalls percentAmountToStringNoCurrency:[NSNumber numberWithLong:[self gratuity]]]];
        gratuityStr = [NSString stringWithFormat:@"<SERVICECHARGES ID=\"%d\" AMOUNT=\"%@\" REFERENCE=\"SVC CHRG FROM ASAAN\" />", 901, [UtilCalls percentAmountToStringNoCurrency:[NSNumber numberWithLong:[self gratuity]]]];
        strItems=[strItems stringByAppendingString:gratuityStr];
    }
    
    //NSString *contactString=[NSString stringWithFormat:@"<CONTACT FIRSTNAME=\"%@\" LASTNAME=\"%@\" PHONE1=\"%@\" PHONE2=\"8012345678\" COMPANY=\"TEST CO\" DEPT=\"DEPT 123\" />"];
    
    PFUser *user = [PFUser currentUser];
    NSString *contactString=[NSString stringWithFormat:@"<CONTACT FIRSTNAME=\"%@\" LASTNAME=\"%@\" PHONE1=\"%@\" />", user[@"firstName"], user[@"lastName"], user[@"phone"]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm a"];
    NSString *orderTime = [dateFormatter stringFromDate: self.orderInProgress.orderTime];
    
    NSString *orderString;
    if (self.orderInProgress.orderType == [DeliveryOrCarryoutViewController ORDERTYPE_DELIVERY])
    {
        
        //    NSString *deliveryString=[NSString stringWithFormat:@"<DELIVERY DELIVERYACCT=\"%@\" DELIVERYNOTE=\"%@\" ADDRESS1=\"123 Main street\" ADDRESS2=\"APT 123\" ADDRESS3=\"Back Door\" CITY=\"DENVER\" STATE=\"CO\" POSTALCODE=\"12345\" CROSSSTREET=\"MAIN AND 1st\" />"];
        GTLUserendpointUserAddress *address = appDelegate.globalObjectHolder.defaultUserAddress;
        NSString *deliveryString=[NSString stringWithFormat:@"<DELIVERY DELIVERYACCT=\"%@\" DELIVERYNOTE=\"%@\" ADDRESS=\"%@\" />", address.title, address.notes, address.fullAddress];
        
        orderString=[NSString stringWithFormat:@"<CHECKREQUESTS><ADDCHECK EXTCHECKID=\"ASAAN\" READYTIME=\"%@\" GUESTCOUNT=\"%d\" NOTE=\"%@\" ORDERMODE=\"@ORDER_MODE\">%@%@%@</ADDCHECK></CHECKREQUESTS>",orderTime, self.orderInProgress.partySize, self.orderInProgress.specialInstructions, contactString, deliveryString, strItems];
    }
    else
        orderString=[NSString stringWithFormat:@"<CHECKREQUESTS><ADDCHECK EXTCHECKID=\"ASAAN\" READYTIME=\"%@\" GUESTCOUNT=\"%d\" NOTE=\"%@\" ORDERMODE=\"@ORDER_MODE\">%@%@</ADDCHECK></CHECKREQUESTS>",orderTime, self.orderInProgress.partySize, self.orderInProgress.specialInstructions, contactString, strItems];
    
    NSLog(@"%@",orderString);
    
    GTLStoreendpointPlaceOrderArguments *orderArguments = [[GTLStoreendpointPlaceOrderArguments alloc]init];
    orderArguments.guestCount = [NSNumber numberWithInt:self.orderInProgress.partySize];  // intValue
    orderArguments.orderMode = [NSNumber numberWithInt:self.orderInProgress.orderType];  // intValue
    orderArguments.storeId = self.orderInProgress.selectedStore.identifier;  // longLongValue
    orderArguments.storeName = self.orderInProgress.selectedStore.name;
    orderArguments.strOrder = orderString;
    
    if (self.stripePay.applePayEnabled && self.stripePay.token != nil)
        orderArguments.token = self.stripePay.token.tokenId;
    else
    {
        orderArguments.userId = appDelegate.globalObjectHolder.defaultUserCard.userId;  // longLongValue
        orderArguments.cardid = appDelegate.globalObjectHolder.defaultUserCard.cardId;
        orderArguments.customerId = appDelegate.globalObjectHolder.defaultUserCard.providerCustomerId;
    }
    
    GTLQueryStoreendpoint *query=[GTLQueryStoreendpoint queryForPlaceOrderWithObject:orderArguments];
    
    //[query setCustomParameter:@"hmHAJvHvKYmilfOqgUnc22tf/RL5GLmPbcFBg02d6wm+ZB1o3f7RKYqmB31+DGoH9Ad3s3WP99n587qDZ5tm+w==" forKey:@"asaan-auth-token"];
    NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
    dic[USER_AUTH_TOKEN_HEADER_NAME]=[UtilCalls getAuthTokenForCurrentUser];
    
    [query setAdditionalHTTPHeaders:dic];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    __weak __typeof(self) weakSelf = self;
    GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
    [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket,GTLStoreendpointStoreOrder *object,NSError *error)
    {
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        
        NSLog(@"%@",object);
        if(error == nil && object.identifier != nil && object.identifier.longLongValue != 0)
        {
            NSString *title = [NSString stringWithFormat:@"Your Order - %@", self.orderInProgress.selectedStore.name];
            NSString *msg = [NSString stringWithFormat:@"Thank you - your order has been placed. If you need to make changes please call %@ immediately at %@.", weakSelf.orderInProgress.selectedStore.name, weakSelf.orderInProgress.selectedStore.phone];
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
            NSLog(@"%@",[error userInfo]);
            NSString *title = @"Something went wrong";
            NSString *msg = [NSString stringWithFormat:@"We were unable to reach %@ and place your order. We're really sorry. Please call %@ directly at %@ to place your order.", weakSelf.orderInProgress.selectedStore.name, weakSelf.orderInProgress.selectedStore.name, weakSelf.orderInProgress.selectedStore.phone];
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
        }
    }];
}

- (IBAction)cancelOrder:(id)sender
{
    __weak __typeof(self) weakSelf = self;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSString *errMsg = [NSString stringWithFormat:@"Do you want to cancel your current order at %@?", self.orderInProgress.selectedStore.name];
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
#pragma mark  === UITableViewDataSource ===
#pragma mark -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.orderInProgress == nil || self.orderInProgress.selectedMenuItems == nil || self.orderInProgress.selectedMenuItems.count == 0)
        return 0;
    
    if (self.orderInProgress.orderType == DeliveryOrCarryoutViewController.ORDERTYPE_CARRYOUT)
        return self.orderInProgress.selectedMenuItems.count + 9;
    else
        return self.orderInProgress.selectedMenuItems.count + 11;
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
- (NSUInteger)subTotalNoDiscount
{
    NSUInteger subTotalNoDiscount = 0;
    for (OnlineOrderSelectedMenuItem *onlineOrderSelectedMenuItem in self.orderInProgress.selectedMenuItems)
        subTotalNoDiscount += onlineOrderSelectedMenuItem.amount;
    return subTotalNoDiscount;
}
- (NSUInteger)discountAmount // already * by 1000000
{
    GTLStoreendpointStoreDiscount *discount = self.orderInProgress.selectedDiscount;
    if (discount == nil)
        return 0;
    
    if (self.orderInProgress.selectedDiscount.percentOrAmount.boolValue == true)
        return [self subTotalNoDiscount] * discount.value.longLongValue;
    else
        return discount.value.longLongValue*10000;
}

- (NSUInteger)taxAmount // already * by 1000000
{
    NSUInteger taxPercentAmount = 0;
    for (OnlineOrderSelectedMenuItem *onlineOrderSelectedMenuItem in self.orderInProgress.selectedMenuItems)
        taxPercentAmount += onlineOrderSelectedMenuItem.amount * onlineOrderSelectedMenuItem.selectedItem.tax.longLongValue;
    return taxPercentAmount;
}

- (NSUInteger)gratuity // 15% - fixed for now
{
    return [self subTotalNoDiscount]*100*15;
}

- (NSUInteger)subTotal  // already * by 1000000
{
    if (self.orderInProgress.selectedDiscount.percentOrAmount.boolValue == true)
        return ([self subTotalNoDiscount]*10000) - [self discountAmount];
    else
        return ([self subTotalNoDiscount]*10000 - [self discountAmount]);
}

- (NSUInteger)orderTotal
{
    return [self subTotal] + [self gratuity] + [self taxAmount];
}

- (NSUInteger)deliveryFee // $5 - fixed for now
{
//    return 5000000;
    return self.orderInProgress.selectedStore.deliveryFee.intValue*10000;
}

- (NSUInteger)finalAmount
{
    if (self.orderInProgress.orderType == DeliveryOrCarryoutViewController.ORDERTYPE_CARRYOUT)
        return ([self subTotal] + [self gratuity] + [self taxAmount]);
    else
        return ([self subTotal] + [self gratuity] + [self taxAmount] + [self deliveryFee]);
}

- (NSString *)orderDateString
{
    NSDate *currentTime = [NSDate date];
    NSDate *newTime = self.orderInProgress.orderTime;
    
    NSDate *minOrderTime = [[NSDate alloc] initWithTimeInterval:3600
                                                      sinceDate:currentTime];
    NSDate *orderTime = [newTime laterDate:minOrderTime];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm a"];
    return [dateFormatter stringFromDate: orderTime];
}

- (UITableViewCell *)cellForAdditionalRowAtIndex:(int)index forTable:(UITableView *)tableView forIndexPath:indexPath
{
    if (self.orderInProgress.orderType == DeliveryOrCarryoutViewController.ORDERTYPE_CARRYOUT && index > 4)
        index++;
    if (self.orderInProgress.orderType == DeliveryOrCarryoutViewController.ORDERTYPE_CARRYOUT && index > 7)
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
                NSNumber *amount = [[NSNumber alloc] initWithLong:[self discountAmount]];
                txtAmount.text = [NSString stringWithFormat:@"%@-", [UtilCalls percentAmountToString:amount]];
            }
            txtMenuItemName.text = [NSString stringWithFormat:@"Discount %@", discount];
            break;
        }
        case 1: // Subtotal
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"MenuItemCell" forIndexPath:indexPath];
            UILabel *txtMenuItemName = (UILabel *)[cell viewWithTag:501];
            UILabel *txtQty = (UILabel *)[cell viewWithTag:502];
            UILabel *txtAmount = (UILabel *)[cell viewWithTag:503];
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            txtMenuItemName.text = @"Subtotal";
            txtQty.text = nil;
            NSNumber *amount = [[NSNumber alloc] initWithLong:[self subTotal]];
            txtAmount.text = [UtilCalls percentAmountToString:amount];
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
        }
        case 2: // Gratuity
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"MenuItemCell" forIndexPath:indexPath];
            UILabel *txtMenuItemName = (UILabel *)[cell viewWithTag:501];
            UILabel *txtQty = (UILabel *)[cell viewWithTag:502];
            UILabel *txtAmount = (UILabel *)[cell viewWithTag:503];
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            txtMenuItemName.text = @"Gratuity (Default: 15%)";
            txtQty.text = nil;
            NSNumber *percentAmount = [[NSNumber alloc] initWithLong:[self gratuity]];
            txtAmount.text = [UtilCalls percentAmountToString:percentAmount];
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
        }
        case 3: // Tax
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"MenuItemCell" forIndexPath:indexPath];
            UILabel *txtMenuItemName = (UILabel *)[cell viewWithTag:501];
            UILabel *txtQty = (UILabel *)[cell viewWithTag:502];
            UILabel *txtAmount = (UILabel *)[cell viewWithTag:503];
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            txtMenuItemName.text = @"Tax (est.)";
            txtQty.text = nil;
            NSNumber *amount = [[NSNumber alloc] initWithLong:[self taxAmount]];
            txtAmount.text = [UtilCalls percentAmountToString:amount];
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
        }
        case 4: // Order Total
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"MenuItemCell" forIndexPath:indexPath];
            UILabel *txtMenuItemName = (UILabel *)[cell viewWithTag:501];
            UILabel *txtQty = (UILabel *)[cell viewWithTag:502];
            UILabel *txtAmount = (UILabel *)[cell viewWithTag:503];
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            txtMenuItemName.text = @"Order Total";
            txtQty.text = nil;
            NSNumber *amount = [[NSNumber alloc] initWithLong:[self orderTotal]];
            txtAmount.text = [UtilCalls percentAmountToString:amount];
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
        }
        case 5: // Delivery Fee
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"MenuItemCell" forIndexPath:indexPath];
            UILabel *txtMenuItemName = (UILabel *)[cell viewWithTag:501];
            UILabel *txtQty = (UILabel *)[cell viewWithTag:502];
            UILabel *txtAmount = (UILabel *)[cell viewWithTag:503];
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            txtMenuItemName.text = @"Delivery";
            txtQty.text = nil;
            NSNumber *amount = [[NSNumber alloc] initWithLong:[self deliveryFee]];
            txtAmount.text = [UtilCalls percentAmountToString:amount];
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
        }
        case 6: // Amount Due
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"MenuItemCell" forIndexPath:indexPath];
            UILabel *txtMenuItemName = (UILabel *)[cell viewWithTag:501];
            UILabel *txtQty = (UILabel *)[cell viewWithTag:502];
            UILabel *txtAmount = (UILabel *)[cell viewWithTag:503];
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            txtMenuItemName.text = @"Amount Due";
            txtQty.text = nil;
            
            NSNumber *amount = [[NSNumber alloc] initWithLong:[self finalAmount]];
            txtAmount.text = [UtilCalls percentAmountToString:amount];
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
        }
        case 7: // Estimated Delivery Time
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"OtherCell" forIndexPath:indexPath];
            cell.textLabel.text = [NSString stringWithFormat:@"Est. Delivery Time %@", [self orderDateString]];
            break;
        }
        case 8: // Delivery Address
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"OtherCell" forIndexPath:indexPath];
            NSString *address = appDelegate.globalObjectHolder.defaultUserAddress.fullAddress;
            if (IsEmpty(address))
                address = @"(Not specified)";
            cell.textLabel.text = [NSString stringWithFormat:@"Delivery Address %@", address];
            cell.tag = 701;
            break;
        }
        case 9: // Payment Mode
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"OtherCell" forIndexPath:indexPath];
            NSString *card = appDelegate.globalObjectHolder.defaultUserCard.last4;
            
            if (self.stripePay.applePayEnabled)
                cell.textLabel.text = @"Payment Mode Apple Pay";
            else if (IsEmpty(card))
                card = @"(Not specified)";
            cell.textLabel.text = [NSString stringWithFormat:@"Payment Mode %@", card];
            cell.tag = 702;
            break;
        }
        case 10: // Special Instructions
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"OtherCell" forIndexPath:indexPath];
            cell.textLabel.text = [NSString stringWithFormat:@"Special Instructions %@", self.orderInProgress.specialInstructions];
            break;
        }
        default:
            break;
    }
    return cell;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewCell *headerCell = [tableView dequeueReusableCellWithIdentifier:@"HeaderCell"];
    if (self.orderInProgress != nil && self.orderInProgress.selectedStore != nil)
        [UtilCalls setupHeaderView:headerCell WithTitle:self.orderInProgress.selectedStore.name AndSubTitle:@"Order Summary"];
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
    CLLocation* second = [[CLLocation alloc] initWithLatitude:self.orderInProgress.selectedStore.lat.doubleValue longitude:self.orderInProgress.selectedStore.lng.doubleValue];
    
    return [UtilCalls isDistanceBetweenPointA:first AndPointB:second withinRange:self.orderInProgress.selectedStore.deliveryDistance.intValue];
}

- (Boolean)AreDeliveryRequirementsValid
{
    if (self.orderInProgress.orderType == [DeliveryOrCarryoutViewController ORDERTYPE_DELIVERY])
    {
        if (![self isDefaultUserAddressValidForStoreDelivery])
        {
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
            if (appDelegate.globalObjectHolder.defaultUserAddress != nil)
            {
                __block Boolean bReturn = NO;
                __weak __typeof(self) weakSelf = self;
                NSString *errMsg = [NSString stringWithFormat:@"%@ does not deliver to your %@. what do you want to do?", self.orderInProgress.selectedStore.name, appDelegate.globalObjectHolder.defaultUserAddress.title];
                [UIAlertView showWithTitle:@"Address outside delivery range" message:errMsg cancelButtonTitle:@"Switch to Carryout" otherButtonTitles:@[@"Change Address", @"Cancel"]
                                  tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex)
                 {
                     if (buttonIndex == [alertView cancelButtonIndex])
                     {
                         weakSelf.orderInProgress.orderType = [DeliveryOrCarryoutViewController ORDERTYPE_CARRYOUT];
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
        [controller setSelectedStore:self.orderInProgress.selectedStore];
        [controller setOrderType:self.orderInProgress.orderType];
        [controller setPartySize:self.orderInProgress.partySize];
        [controller setOrderTime:self.orderInProgress.orderTime];
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
        [controller setSelectedStore:self.orderInProgress.selectedStore];
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
