//
//  OrderHistorySummaryTableViewController.m
//  AsaanImprovedUI
//
//  Created by Nirav Saraiya on 1/20/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import "OrderHistorySummaryTableViewController.h"
#import "InlineCalls.h"
#import "UtilCalls.h"
#import "OrderItemSummaryFromPOS.h"
#import "RXMLElement.h"
#import "OrderedDictionary.h"

@interface OrderHistorySummaryTableViewController ()
@property (nonatomic) Boolean bDataLoaded;
@property (nonatomic, strong) NSMutableArray *finalItems;

@end

@implementation OrderHistorySummaryTableViewController
@synthesize bDataLoaded = _bDataLoaded;

const NSTimeInterval XMLLoadingOperationDuration = 0.3;

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    if (self.selectedOrder != nil)
    {
        [self parsePOSCheckDetails];
        [self.tableView reloadData];
    }
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    
    int count = allEntries.count;
    
    for (RXMLElement *entry in allEntries)
    {
         OrderItemSummaryFromPOS *orderItemSummaryFromPOS = [[OrderItemSummaryFromPOS alloc]init];
         orderItemSummaryFromPOS.posMenuItemId = [UtilCalls stringToNumber:[entry attribute:@"ITEMID"]].longValue;
         orderItemSummaryFromPOS.qty = [UtilCalls stringToNumber:[entry attribute:@"QUANTITY"]].intValue;
         orderItemSummaryFromPOS.price = [UtilCalls stringToNumber:[entry attribute:@"PRICE"]].doubleValue;
         orderItemSummaryFromPOS.name = [entry attribute:@"DISP_NAME"];
         orderItemSummaryFromPOS.parentEntryId = [UtilCalls stringToNumber:[entry attribute:@"PARENTENTRY"]].longValue;
         orderItemSummaryFromPOS.entryId = [UtilCalls stringToNumber:[entry attribute:@"ID"]].longValue;
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
                    NSLog(@"ParentItem.price: %f, Item.price: %f", parentItem.price, item.price);
                    if (item.price > 0)
                    {
                        desc = [NSString stringWithFormat:@"%@ (%@)", item.name, [UtilCalls rawAmountToString:[NSNumber numberWithDouble:item.price]]];
                        finalPrice = parentItem.price + item.price;
                    }
                    else
                        desc = item.name;
                    
                    if (IsEmpty(parentItem.desc) == false)
                        desc = [NSString stringWithFormat:@"%@, %@", parentItem.desc, desc];
                    
                    NSLog(@"ParentItem: %@, Item: %@, finalDesc: %@, finalPrice: %f", parentItem.name, item.name, desc, finalPrice);
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
            NSString *key = [NSString stringWithFormat:@"%ld_%@_%@", item.posMenuItemId, [UtilCalls rawAmountToString:[NSNumber numberWithDouble:item.price]], item.desc];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.selectedOrder == nil)
        return 0;
    
    long count = 0;
    if (self.selectedOrder.discount.longValue != 0)
        count = self.finalItems.count + 5;
    else
        count = self.finalItems.count + 4;
    return count;
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
    
    return cell;
}

- (UITableViewCell *)cellForAdditionalRowAtIndex:(int)index forTable:(UITableView *)tableView forIndexPath:indexPath
{
    if (self.selectedOrder.discount.longValue == 0)
        index++;
    
    UITableViewCell *cell;
    switch (index)
    {
        case 0: // Discount
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"MenuItemCell" forIndexPath:indexPath];
            UILabel *txtMenuItemName = (UILabel *)[cell viewWithTag:501];
            UILabel *txtQty = (UILabel *)[cell viewWithTag:502];
            UILabel *txtAmount = (UILabel *)[cell viewWithTag:503];
            UILabel *txtDesc = (UILabel *)[cell viewWithTag:504];
            txtDesc.text = nil;
            cell.tag = 703;
            txtQty.text = nil;
            txtAmount.text = [NSString stringWithFormat:@"%@-", [UtilCalls amountToString:self.selectedOrder.discount]];
            txtMenuItemName.text = [NSString stringWithFormat:@"Discount %@", self.selectedOrder.discountDescription];
            break;
        }
        case 1: // Subtotal
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"MenuItemCell" forIndexPath:indexPath];
            UILabel *txtMenuItemName = (UILabel *)[cell viewWithTag:501];
            UILabel *txtQty = (UILabel *)[cell viewWithTag:502];
            UILabel *txtAmount = (UILabel *)[cell viewWithTag:503];
            UILabel *txtDesc = (UILabel *)[cell viewWithTag:504];
            txtDesc.text = nil;
            
            txtMenuItemName.text = @"Subtotal";
            txtQty.text = nil;
            txtAmount.text = [NSString stringWithFormat:@"%@", [UtilCalls amountToString:self.selectedOrder.subTotal]];
            break;
        }
        case 2: // Gratuity
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"MenuItemCell" forIndexPath:indexPath];
            UILabel *txtMenuItemName = (UILabel *)[cell viewWithTag:501];
            UILabel *txtQty = (UILabel *)[cell viewWithTag:502];
            UILabel *txtAmount = (UILabel *)[cell viewWithTag:503];
            UILabel *txtDesc = (UILabel *)[cell viewWithTag:504];
            txtDesc.text = nil;
            
            txtMenuItemName.text = @"Gratuity";
            txtQty.text = nil;
            txtAmount.text = [NSString stringWithFormat:@"%@", [UtilCalls amountToString:self.selectedOrder.serviceCharge]];
            break;
        }
        case 3: // Tax
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"MenuItemCell" forIndexPath:indexPath];
            UILabel *txtMenuItemName = (UILabel *)[cell viewWithTag:501];
            UILabel *txtQty = (UILabel *)[cell viewWithTag:502];
            UILabel *txtAmount = (UILabel *)[cell viewWithTag:503];
            UILabel *txtDesc = (UILabel *)[cell viewWithTag:504];
            txtDesc.text = nil;
            
            txtMenuItemName.text = @"Tax";
            txtQty.text = nil;
            txtAmount.text = [NSString stringWithFormat:@"%@", [UtilCalls amountToString:self.selectedOrder.tax]];
            break;
        }
        case 4: // Amount Due
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"MenuItemCell" forIndexPath:indexPath];
            UILabel *txtMenuItemName = (UILabel *)[cell viewWithTag:501];
            UILabel *txtQty = (UILabel *)[cell viewWithTag:502];
            UILabel *txtAmount = (UILabel *)[cell viewWithTag:503];
            UILabel *txtDesc = (UILabel *)[cell viewWithTag:504];
            txtDesc.text = nil;
            
            txtMenuItemName.text = @"Amount Due";
            txtQty.text = nil;
            
            txtAmount.text = [NSString stringWithFormat:@"%@", [UtilCalls amountToString:self.selectedOrder.finalTotal]];
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
    headerCell.textLabel.text = self.selectedOrder.storeName;
    UILabel *txtSubtitle=(UILabel *)[headerCell viewWithTag:502];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:self.selectedOrder.createdDate.longValue/1000];
    
    txtSubtitle.text = [dateFormatter stringFromDate:date];
    return headerCell;
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
