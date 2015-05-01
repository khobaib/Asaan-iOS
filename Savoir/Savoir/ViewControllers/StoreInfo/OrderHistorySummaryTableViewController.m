//
//  OrderHistorySummaryTableViewController.m
//  Savoir
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
#import "GTLStoreendpointOrderReviewAndItemReviews.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "MainReviewViewController.h"
#import "Constants.h"
#import "UtilCalls.h"

@interface OrderHistorySummaryTableViewController ()
@property (nonatomic, strong) NSMutableArray *finalItems;
@property (strong, nonatomic) GTLStoreendpointOrderReviewAndItemReviews *reviewAndItems;
@property (strong, nonatomic) UIImage *imgLike;
@property (strong, nonatomic) UIImage *imgDislike;
@property (nonatomic) CGFloat cellHeight;

@end

@implementation OrderHistorySummaryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imgLike = [UIImage imageNamed:@"ic_good_rating"];
    self.imgDislike = [UIImage imageNamed:@"ic_bad_rating"];
//    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

//    self.tableView.tableFooterView.hidden = YES;
    if (self.selectedOrder != nil)
    {
        [self parsePOSCheckDetails];
        [self getOrderReview];
    }
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
    {
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 78;
    }
    else
        self.cellHeight = 78;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    appDelegate.topViewController = self;
    
    if (self.selectedOrder != nil && self.reviewAndItems == nil)
    {
        [self parsePOSCheckDetails];
        [self getOrderReview];
    }
    else
    {
        if ([UtilCalls orderHasAlreadyBeenReviewed:self.reviewAndItems] == false)
        {
            self.navigationItem.rightBarButtonItem.title = @"Review";
            self.navigationItem.rightBarButtonItem.enabled = true;
        }
        else
        {
            self.navigationItem.rightBarButtonItem.title = @"";
            self.navigationItem.rightBarButtonItem.enabled = false;
        }
        [self.tableView reloadData];
    }
}

- (void) getOrderReview
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
        GTLQueryStoreendpoint *query = [GTLQueryStoreendpoint queryForGetReviewForCurrentUserAndOrderWithOrderId:self.selectedOrder.identifier.longLongValue];
        NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
        dic[USER_AUTH_TOKEN_HEADER_NAME]=[UtilCalls getAuthTokenForCurrentUser];
        
        [query setAdditionalHTTPHeaders:dic];
        
        [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLStoreendpointOrderReviewAndItemReviews *object,NSError *error)
         {
             if(!error)
             {
                 weakSelf.reviewAndItems = object;
                 if ([UtilCalls orderHasAlreadyBeenReviewed:weakSelf.reviewAndItems] == false)
                 {
                     weakSelf.navigationItem.rightBarButtonItem.title = @"Review";
                     weakSelf.navigationItem.rightBarButtonItem.enabled = true;
                 }
                 else
                 {
                     weakSelf.navigationItem.rightBarButtonItem.title = @"";
                     weakSelf.navigationItem.rightBarButtonItem.enabled = false;
                 }
                 [weakSelf.tableView reloadData];
             }else{
                 NSLog(@"getOrderReview Error:%@",[error userInfo][@"error"]);
             }
             hud.hidden = YES;
         }];
    }
}

- (UIImage *) getOrderItemReviewLikeDislikeImageForMenuItem:(int)menuItemPOSId
{
    if ([UtilCalls orderHasAlreadyBeenReviewed:self.reviewAndItems] == false)
        return nil;
    if (self.reviewAndItems.itemReviews == nil || self.reviewAndItems.itemReviews.count == 0)
        return nil;
    for (GTLStoreendpointItemReview *itemReview in self.reviewAndItems.itemReviews)
    {
        if (itemReview.menuItemPOSId.intValue == menuItemPOSId)
        {
            if (itemReview.itemLike.shortValue == 0)
                return nil;
            if (itemReview.itemLike.shortValue <= 140)
                return self.imgDislike;
            if (itemReview.itemLike.shortValue >= 160)
                return self.imgLike;
        }
    }
    return nil;
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
    if (self.selectedOrder.discount.longLongValue != 0)
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
        UIImageView *imgLike = (UIImageView *)[cell viewWithTag:505];
        txtDesc.text = nil;
        txtMenuItemName.text = nil;
        txtQty.text = nil;
        txtAmount.text = nil;
        imgLike.image = nil;
        
        OrderItemSummaryFromPOS *item = [self.finalItems objectAtIndex:indexPath.row];
        if (item != nil)
        {
            txtMenuItemName.text = item.name;
            txtQty.text = [NSString stringWithFormat:@"%d", item.qty];
            txtAmount.text = [NSString stringWithFormat:@"%@", [UtilCalls rawAmountToString:[NSNumber numberWithDouble:item.price]]];
            txtDesc.text = item.desc;
            imgLike.image = [self getOrderItemReviewLikeDislikeImageForMenuItem:item.posMenuItemId];
        }
    }
    
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (UITableViewCell *)cellForAdditionalRowAtIndex:(int)index forTable:(UITableView *)tableView forIndexPath:indexPath
{
    if (self.selectedOrder.discount.longLongValue == 0)
        index++;
    
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:@"MenuItemCell" forIndexPath:indexPath];
    UILabel *txtMenuItemName = (UILabel *)[cell viewWithTag:501];
    UILabel *txtQty = (UILabel *)[cell viewWithTag:502];
    UILabel *txtAmount = (UILabel *)[cell viewWithTag:503];
    UILabel *txtDesc = (UILabel *)[cell viewWithTag:504];
    UIImageView *imgLike = (UIImageView *)[cell viewWithTag:505];
    txtDesc.text = nil;
    txtQty.text = nil;
    imgLike.image = nil;

    switch (index)
    {
        case 0: // Discount
        {
            cell.tag = 703;
            txtAmount.text = [NSString stringWithFormat:@"%@-", [UtilCalls amountToString:self.selectedOrder.discount]];
            txtMenuItemName.text = [NSString stringWithFormat:@"Discount %@", self.selectedOrder.discountDescription];
            break;
        }
        case 1: // Subtotal
        {
            txtMenuItemName.text = @"Subtotal";
            txtAmount.text = [NSString stringWithFormat:@"%@", [UtilCalls amountToString:self.selectedOrder.subTotal]];
            break;
        }
        case 2: // Gratuity
        {
            txtMenuItemName.text = @"Gratuity";
            txtAmount.text = [NSString stringWithFormat:@"%@", [UtilCalls amountToString:self.selectedOrder.serviceCharge]];
            break;
        }
        case 3: // Tax
        {
            txtMenuItemName.text = @"Tax";
            txtAmount.text = [NSString stringWithFormat:@"%@", [UtilCalls amountToString:self.selectedOrder.tax]];
            break;
        }
        case 4: // Amount Due
        {
            txtMenuItemName.text = @"Amount Due";
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

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:self.selectedOrder.createdDate.longLongValue/1000];
    
    NSString *subTitle = [NSString stringWithFormat:@"Order Summary - %@", [dateFormatter stringFromDate:date]];
    [UtilCalls setupHeaderView:headerCell WithTitle:self.selectedOrder.storeName AndSubTitle:subTitle];
    return headerCell;
}

-(UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if ([UtilCalls orderHasAlreadyBeenReviewed:self.reviewAndItems] == false)
        return [[UIView alloc] initWithFrame:CGRectZero];
    
    UITableViewCell *footerCell = [tableView dequeueReusableCellWithIdentifier:@"FooterCell"];
    UIImageView *imgFoodLike = (UIImageView *)[footerCell viewWithTag:502];
    UIImageView *imgServiceLike = (UIImageView *)[footerCell viewWithTag:503];
    UITextView *txtReview = (UITextView *)[footerCell viewWithTag:504];
    
    txtReview.text = nil;
    txtReview.editable = false;
    
    if (self.reviewAndItems.orderReview.foodLike.shortValue == 0)
        imgFoodLike.image = nil;
    else if (self.reviewAndItems.orderReview.foodLike.shortValue <= 140)
        imgFoodLike.image = self.imgDislike;
    else if (self.reviewAndItems.orderReview.foodLike.shortValue >= 160)
        imgFoodLike.image = self.imgLike;
    
    if (self.reviewAndItems.orderReview.serviceLike.shortValue == 0)
        imgServiceLike.image = nil;
    else if (self.reviewAndItems.orderReview.serviceLike.shortValue <= 140)
        imgServiceLike.image = self.imgDislike;
    else if (self.reviewAndItems.orderReview.serviceLike.shortValue >= 160)
        imgServiceLike.image = self.imgLike;
    
    txtReview.text = self.reviewAndItems.orderReview.comments;

    return footerCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
        return UITableViewAutomaticDimension;
    else
        return self.cellHeight;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"segueOrderHistorySummaryToReview"])
    {
        MainReviewViewController *controller = [segue destinationViewController];
        [controller setSelectedOrder:self.selectedOrder];
        controller.reviewAndItems = self.reviewAndItems;
    }
}

- (IBAction)unwindToOrderHistorySummary:(UIStoryboardSegue *)unwindSegue
{
}
@end
