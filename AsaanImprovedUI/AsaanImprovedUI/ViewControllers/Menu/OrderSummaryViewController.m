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

@interface OrderSummaryViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) OnlineOrderDetails *orderInProgress;
@end

@implementation OrderSummaryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    self.orderInProgress = appDelegate.globalObjectHolder.orderInProgress;
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)placeOrder:(id)sender {
}
- (IBAction)cancelOrder:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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
