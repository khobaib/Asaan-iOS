//
//  InStoreOrderSummaryViewController.m
//  Savoir
//
//  Created by Nirav Saraiya on 4/28/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import "InStoreOrderSummaryViewController.h"
#import "AppDelegate.h"
#import "OrderItemSummaryFromPOS.h"
#import "RXMLElement.h"
#import "OrderedDictionary.h"
#import "InlineCalls.h"
#import "UtilCalls.h"
#import "MBProgressHUD.h"
#import "InStoreOrderReceiver.h"
#import "XMLPOSOrder.h"

@interface InStoreOrderSummaryViewController () <InStoreOrderReceiver, UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) GTLStoreendpointStoreOrder *selectedOrder;
@property (nonatomic, strong) NSMutableArray *finalItems;
@property (nonatomic, strong) NSTimer *timer;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnPay;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation InStoreOrderSummaryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    if (self.navigationController.viewControllers[0] == self)
    {
        //        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        //        [appDelegate.notificationUtils getSlidingMenuBarButtonSetupWith:self];
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"UINavigationBarBackIndicatorGold"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonPressed)];
        self.navigationItem.leftBarButtonItem = backButton;
    }
}

- (void)backButtonPressed
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)btnLeaveGroup:(id)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    if ([self subTotal] > 0)
    {
        if (appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.members.count == 1)
        {
            [[[UIAlertView alloc]initWithTitle:@"Leave Group/Table Error" message:@"This table has an active order. Please ask your server to close the table before leaving." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            return;
        }
    }
    
    [appDelegate.globalObjectHolder.inStoreOrderDetails leaveGroup:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self refreshOrderDetails];
    [self startTimer];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [super viewWillDisappear:animated];
    [self.timer invalidate];
}

- (void)startTimer
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:35.0 target:self selector:@selector(refreshOrderDetails) userInfo:nil repeats:YES];
}

#pragma mark - InStoreOrderReceiver Delegate

- (void)orderChanged
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    if (appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.memberMe == nil
        || appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.order.orderStatus.intValue == 4 // Fully Paid
        || appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.order.orderStatus.intValue == 5) // Paid and Closed
    {
        [self.timer invalidate];
        [UtilCalls handleClosedOrderFor:self SegueTo:@"segueUnwindInStoreOrderSummaryToStoreList"];
    }
    self.finalItems = [XMLPOSOrder parseOrderDetails:appDelegate.globalObjectHolder.inStoreOrderDetails.teamAndOrderDetails.order.orderDetails];
    if ([self subTotal] > 0)
        self.btnPay.enabled = true;
    else
        self.btnPay.enabled = false;
    
    [self.tableView reloadData];
}

- (void) tableGroupMemberChanged
{
    [self refreshOrderDetails];
}

- (void) openGroupsChanged
{
    // Don't Care.
}

- (void)refreshOrderDetails
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    [appDelegate.globalObjectHolder.inStoreOrderDetails getStoreOrderDetails:self];
    NSLog(@"InStoreOrderSummaryTableViewController refreshOrderDetails");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewCell *headerCell = [tableView dequeueReusableCellWithIdentifier:@"HeaderCell"];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSString *title = [NSString stringWithFormat:@"%@", appDelegate.globalObjectHolder.inStoreOrderDetails.selectedStore.name];
    [UtilCalls setupHeaderView:headerCell WithTitle:title AndSubTitle:@"Order Summary"];
    return headerCell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
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
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            txtMenuItemName.text = @"Discount";
            NSString *discount = [self discountTitle];
            if (!IsEmpty(discount))
            {
                NSNumber *amount = [[NSNumber alloc] initWithDouble:[self discountAmount]];
                txtAmount.text = [NSString stringWithFormat:@"%@-", [UtilCalls doubleAmountToString:amount]];
                txtDesc.text = discount;
            }
            else
                txtDesc.text = @"None";
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

- (double)subTotalNoDiscount
{
    NSUInteger subTotalNoDiscount = 0;
    for (OrderItemSummaryFromPOS *item in self.finalItems)
        subTotalNoDiscount += item.price;
    return subTotalNoDiscount;
}

- (double)discountAmount
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    GTLStoreendpointStoreDiscount *discount = appDelegate.globalObjectHolder.inStoreOrderDetails.selectedDiscount;
    if (discount == nil)
        return 0;
    if (discount.percentOrAmount.boolValue == true)
        return ([self subTotalNoDiscount]*discount.value.intValue/100);
    else
        return discount.value.intValue/100;
}

- (NSString *)discountTitle
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    return appDelegate.globalObjectHolder.inStoreOrderDetails.selectedDiscount.title;
}

- (double)subTotal  // already * by 1000000
{
    return [self subTotalNoDiscount] - [self discountAmount];
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
