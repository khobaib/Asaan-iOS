//
//  ReviewItemsTableViewController.m
//  Savoir
//
//  Created by Nirav Saraiya on 1/23/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import "ReviewItemsTableViewController.h"
#import "InlineCalls.h"
#import "UtilCalls.h"
#import "OrderItemSummaryFromPOS.h"
#import "RXMLElement.h"
#import "OrderedDictionary.h"
#import "GTLStoreendpointItemReview.h"
#import "GTLServiceStoreendpoint.h"
#import "GTLQueryStoreendpoint.h"
#import "GTLStoreendpointItemReviewsArray.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "OrderHistorySummaryTableViewController.h"
#import "UIAlertView+Blocks.h"

@interface ReviewItemsTableViewController ()
@property (nonatomic, strong) NSMutableArray *finalItems;

@end

@implementation ReviewItemsTableViewController

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
    
    for (RXMLElement *entry in allEntries)
    {
        OrderItemSummaryFromPOS *orderItemSummaryFromPOS = [[OrderItemSummaryFromPOS alloc]init];
        orderItemSummaryFromPOS.posMenuItemId = [UtilCalls stringToNumber:[entry attribute:@"ITEMID"]].intValue;
        orderItemSummaryFromPOS.qty = [UtilCalls stringToNumber:[entry attribute:@"QUANTITY"]].intValue;
        orderItemSummaryFromPOS.price = [UtilCalls stringToNumber:[entry attribute:@"PRICE"]].doubleValue;
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
            NSString *key = [NSString stringWithFormat:@"%d", item.posMenuItemId];
            OrderItemSummaryFromPOS *duplicateItem = [combinedItems objectForKey:key];
            if (duplicateItem == nil)
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
    
    return self.finalItems.count;
}

- (IBAction)reviewSliderValueChanged:(UISlider *)sender
{
    OrderItemSummaryFromPOS *item = [self.finalItems objectAtIndex:sender.tag];
    NSNumber *number = [NSNumber numberWithFloat:sender.value*100];
    item.like = number.shortValue;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewCell *headerCell = [tableView dequeueReusableCellWithIdentifier:@"HeaderCell"];
    [UtilCalls setupHeaderView:headerCell WithTitle:self.selectedOrder.storeName AndSubTitle:@"Did any item stand out?"];
    return headerCell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:@"MenuItemCell" forIndexPath:indexPath];
    UILabel *txtMenuItemName = (UILabel *)[cell viewWithTag:501];
    UISlider *sliderReview = (UISlider *)[cell viewWithTag:502];
    txtMenuItemName.text = nil;
    sliderReview.value = 1.5;

    OrderItemSummaryFromPOS *item = [self.finalItems objectAtIndex:indexPath.row];
    if (item != nil)
    {
        sliderReview.tag = indexPath.row;
        txtMenuItemName.text = item.name;
        if (item.like == 0)
            sliderReview.value = 1.5;
        else
            sliderReview.value = [NSNumber numberWithLong:item.like].floatValue/100;
        [sliderReview addTarget:self action:@selector(reviewSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    
    return cell;
}
- (IBAction)reviewDone:(id)sender
{
    NSMutableArray *reviewedItems = [[NSMutableArray alloc]init];
    for (OrderItemSummaryFromPOS *item in self.finalItems)
    {
        if (item.like != 0)
        {
            GTLStoreendpointItemReview *itemReview = [[GTLStoreendpointItemReview alloc]init];
            itemReview.menuItemPOSId = [NSNumber numberWithInt:item.posMenuItemId];
            itemReview.storeId = self.selectedOrder.storeId;
            itemReview.orderId = self.selectedOrder.identifier;
            itemReview.itemName = item.name;
            itemReview.itemLike = [NSNumber numberWithShort:item.like];
            [reviewedItems addObject:itemReview];
        }
    }
    if (reviewedItems.count > 0)
    {
        GTLStoreendpointItemReviewsArray *itemReviewsArray = [[GTLStoreendpointItemReviewsArray alloc]init];
        itemReviewsArray.itemReviews = reviewedItems;
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
        GTLQueryStoreendpoint *query = [GTLQueryStoreendpoint queryForSaveStoreItemReviewsWithObject:itemReviewsArray];
        NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
        dic[USER_AUTH_TOKEN_HEADER_NAME]=[UtilCalls getAuthTokenForCurrentUser];
        
        [query setAdditionalHTTPHeaders:dic];
        
        [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error)
         {
             if (error)
                 NSLog(@"saveItemReviews Error:%@",[error userInfo]);
             else
             {
                 self.reviewAndItems.itemReviews = itemReviewsArray.itemReviews;
                 NSString *reviewText = [NSString stringWithFormat:@"Thank you for reviewing %@.", self.selectedOrder.storeName];
                 [UIAlertView showWithTitle:@"Thank you" message:reviewText cancelButtonTitle:@"Ok" otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex)
                 {
                     if (self.presentedFromNotification == true)
                         [self dismissViewControllerAnimated:YES completion:nil];
                     else
                         [UtilCalls popFrom:self index:2 Animated:YES];
 //                        [self.navigationController popViewControllerAnimated:YES];
 //                        [self.navigationController popToRootViewControllerAnimated:YES];
                 }];
             }
         }];
    }
}

@end
