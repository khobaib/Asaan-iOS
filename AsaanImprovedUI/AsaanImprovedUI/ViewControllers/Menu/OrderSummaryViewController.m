//
//  OrderSummaryViewController.m
//  AsaanImprovedUI
//
//  Created by Nirav Saraiya on 12/7/14.
//  Copyright (c) 2014 Nirav Saraiya. All rights reserved.
//

#import "OrderSummaryViewController.h"
#import "UIColor+AsaanGoldColor.h"
#import "UIColor+AsaanBackgroundColor.h"
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

@interface OrderSummaryViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) OnlineOrderDetails *orderInProgress;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnAdd;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnEdit;
@property (strong, nonatomic) MenuTableViewController *itemInputController;

@property (nonatomic) NSUInteger selectedIndex;
@end

@implementation OrderSummaryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
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
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor goldColor]};
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    self.orderInProgress = appDelegate.globalObjectHolder.orderInProgress;
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)placeOrder:(id)sender
{
    if (self.orderInProgress == nil)
        return;
    
    NSString *str = @"<ITEMREQUESTS>";
    for (OnlineOrderSelectedMenuItem *object in self.orderInProgress.selectedMenuItems)
    {
        NSString *itemString=[NSString stringWithFormat:@"<ADDITEM QTY=\"%d\" ITEMID=\"%@\" />",object.qty,object.selectedItem.menuItemPOSId];
        
        str=[str stringByAppendingString:itemString];
    }
    str=[str stringByAppendingString:@"</ITEMREQUESTS>"];
    
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
        GTLUserendpointUserAddress *address = self.orderInProgress.savedUserAddress;
        NSString *deliveryString=[NSString stringWithFormat:@"<DELIVERY DELIVERYACCT=\"%@\" DELIVERYNOTE=\"%@\" ADDRESS=\"%@\" />", address.title, address.address3, address.address2];
        
        orderString=[NSString stringWithFormat:@"<CHECKREQUESTS><ADDCHECK EXTCHECKID=\"ASAAN\" READYTIME=\"%@\" NOTE=\"%@\" ORDERMODE=\"@ORDER_MODE\">%@%@%@</ADDCHECK></CHECKREQUESTS>",orderTime, self.orderInProgress.specialInstructions, contactString, deliveryString, str];
    }
    else
        orderString=[NSString stringWithFormat:@"<CHECKREQUESTS><ADDCHECK EXTCHECKID=\"ASAAN\" READYTIME=\"%@\" NOTE=\"%@\" ORDERMODE=\"@ORDER_MODE\">%@%@</ADDCHECK></CHECKREQUESTS>",orderTime, self.orderInProgress.specialInstructions, contactString, str];
    
    NSLog(@"%@",orderString);
    
    GTLQueryStoreendpoint *query=[GTLQueryStoreendpoint queryForPlaceOrderWithStoreId:self.orderInProgress.selectedStore.identifier.longValue orderMode:self.orderInProgress.orderType order:orderString];
    
    //[query setCustomParameter:@"hmHAJvHvKYmilfOqgUnc22tf/RL5GLmPbcFBg02d6wm+ZB1o3f7RKYqmB31+DGoH9Ad3s3WP99n587qDZ5tm+w==" forKey:@"asaan-auth-token"];
    NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
    dic[@"asaan-auth-token"]=[PFUser currentUser][@"authToken"];
    
    [query setAdditionalHTTPHeaders:dic];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    typeof(self) weakSelf = self;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
    [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket,GTLStoreendpointStoreMenuItem *object,NSError *error)
    {
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        
        NSLog(@"%@",object);
        if(error==nil)
        {
            NSString *title = [NSString stringWithFormat:@"Your Order - %@", self.orderInProgress.selectedStore.name];
            NSString *msg = [NSString stringWithFormat:@"Thank you - your order has been placed. If you need to make changes please call %@ immediately at %@.", weakSelf.orderInProgress.selectedStore.name, weakSelf.orderInProgress.selectedStore.phone];
            [appDelegate.globalObjectHolder removeOrderInProgress];
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
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
    typeof(self) weakSelf = self;
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
    
    if (self.orderInProgress.orderType == 0)
        return self.orderInProgress.selectedMenuItems.count + 8;
    else
        return self.orderInProgress.selectedMenuItems.count + 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (self.orderInProgress.selectedMenuItems.count <= indexPath.row)
    {
        int realIndex = indexPath.row - self.orderInProgress.selectedMenuItems.count;
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
            txtQty.text = [NSString stringWithFormat:@"%d", onlineOrderSelectedMenuItem.qty];
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
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}
- (NSUInteger)subTotal
{
    NSUInteger subTotal = 0;
    for (OnlineOrderSelectedMenuItem *onlineOrderSelectedMenuItem in self.orderInProgress.selectedMenuItems)
        subTotal += onlineOrderSelectedMenuItem.amount;
    return subTotal;
}

- (NSUInteger)taxPercentAmount
{
    NSUInteger taxPercentAmount = 0;
    for (OnlineOrderSelectedMenuItem *onlineOrderSelectedMenuItem in self.orderInProgress.selectedMenuItems)
        taxPercentAmount += onlineOrderSelectedMenuItem.amount * onlineOrderSelectedMenuItem.selectedItem.tax.longValue;
    return taxPercentAmount;
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
    if (self.orderInProgress.orderType == 0 && index > 3)
        index++;
    if (self.orderInProgress.orderType == 0 && index > 6)
        index++;

    UITableViewCell *cell;
    switch (index)
    {
        case 0: // Subtotal
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"MenuItemCell" forIndexPath:indexPath];
            UILabel *txtMenuItemName = (UILabel *)[cell viewWithTag:501];
            UILabel *txtQty = (UILabel *)[cell viewWithTag:502];
            UILabel *txtAmount = (UILabel *)[cell viewWithTag:503];
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            txtMenuItemName.text = @"Subtotal";
            txtQty.text = nil;
            NSNumber *amount = [[NSNumber alloc] initWithLong:[self subTotal]];
            txtAmount.text = [UtilCalls amountToString:amount];
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
        }
        case 1: // Gratuity
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"MenuItemCell" forIndexPath:indexPath];
            UILabel *txtMenuItemName = (UILabel *)[cell viewWithTag:501];
            UILabel *txtQty = (UILabel *)[cell viewWithTag:502];
            UILabel *txtAmount = (UILabel *)[cell viewWithTag:503];
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            txtMenuItemName.text = @"Gratuity (Default: 15%)";
            txtQty.text = nil;
            NSNumber *percentAmount = [[NSNumber alloc] initWithLong:([self subTotal]*15)];
            txtAmount.text = [UtilCalls percentAmountToString:percentAmount];
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
        }
        case 2: // Tax
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"MenuItemCell" forIndexPath:indexPath];
            UILabel *txtMenuItemName = (UILabel *)[cell viewWithTag:501];
            UILabel *txtQty = (UILabel *)[cell viewWithTag:502];
            UILabel *txtAmount = (UILabel *)[cell viewWithTag:503];
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            txtMenuItemName.text = @"Tax";
            txtQty.text = nil;
            NSNumber *amount = [[NSNumber alloc] initWithLong:[self taxPercentAmount]];
            txtAmount.text = [UtilCalls percentAmountToString:amount];
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
        }
        case 3: // Order Total
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"MenuItemCell" forIndexPath:indexPath];
            UILabel *txtMenuItemName = (UILabel *)[cell viewWithTag:501];
            UILabel *txtQty = (UILabel *)[cell viewWithTag:502];
            UILabel *txtAmount = (UILabel *)[cell viewWithTag:503];
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            txtMenuItemName.text = @"Order Total";
            txtQty.text = nil;
            NSNumber *amount = [[NSNumber alloc] initWithLong:([self subTotal]*100 + [self subTotal]*15 + [self taxPercentAmount])];
            txtAmount.text = [UtilCalls percentAmountToString:amount];
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
        }
        case 4: // Delivery Fee
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"MenuItemCell" forIndexPath:indexPath];
            UILabel *txtMenuItemName = (UILabel *)[cell viewWithTag:501];
            UILabel *txtQty = (UILabel *)[cell viewWithTag:502];
            UILabel *txtAmount = (UILabel *)[cell viewWithTag:503];
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            txtMenuItemName.text = @"Delivery";
            txtQty.text = nil;
            NSNumber *amount = [[NSNumber alloc] initWithLong:(5)];
            txtAmount.text = [UtilCalls amountToString:amount];
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
        }
        case 5: // Amount Due
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"MenuItemCell" forIndexPath:indexPath];
            UILabel *txtMenuItemName = (UILabel *)[cell viewWithTag:501];
            UILabel *txtQty = (UILabel *)[cell viewWithTag:502];
            UILabel *txtAmount = (UILabel *)[cell viewWithTag:503];
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            txtMenuItemName.text = @"Amount Due";
            txtQty.text = nil;
            NSNumber *amount = [[NSNumber alloc] initWithLong:([self subTotal]*100 + [self subTotal]*15 + [self taxPercentAmount] + 5*100)];
            txtAmount.text = [UtilCalls percentAmountToString:amount];
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
            cell.textLabel.text = [NSString stringWithFormat:@"Delivery Address %@", self.orderInProgress.savedUserAddress.address2];
            break;
        }
        case 8: // Payment Mode
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"OtherCell" forIndexPath:indexPath];
            cell.textLabel.text = [NSString stringWithFormat:@"Payment Mode %@", self.orderInProgress.savedUserCard.last4];
            break;
        }
        case 9: // Special Instructions
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
        headerCell.textLabel.text = self.orderInProgress.selectedStore.name;
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
        [self performSegueWithIdentifier:@"segueOrderSummaryToModifierGroup" sender:self];
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
        [controller setSavedUserAddress:self.orderInProgress.savedUserAddress];
        [controller setSavedUserCard:self.orderInProgress.savedUserCard];
        [controller setOrderType:self.orderInProgress.orderType];
        [controller setPartySize:self.orderInProgress.partySize];
        [controller setOrderTime:self.orderInProgress.orderTime];
    }
    else if ([[segue identifier] isEqualToString:@"segueOrderSummaryToModifierGroup"])
    {
        MenuModifierGroupViewController *controller = [segue destinationViewController];
        [controller setSelectedIndex:self.selectedIndex];
        [controller setBInEditMode:YES];
    }
}

- (IBAction)unwindToOrderSummary:(UIStoryboardSegue *)unwindSegue
{
}
@end
