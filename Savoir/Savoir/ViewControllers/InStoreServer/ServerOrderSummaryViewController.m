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
#import "DeliveryOrCarryoutViewController.h"

@interface ServerOrderSummaryViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *txtTable;
@property (weak, nonatomic) IBOutlet UITextField *txtCheckId;
@property (weak, nonatomic) IBOutlet UITextField *txtPartySize;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnEdit;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnAdd;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *finalItems;
@property (strong, nonatomic) NSString *discountName;
@property (nonatomic) float discountAmt;
@property (nonatomic) Boolean isNewOrder;

@end

@implementation ServerOrderSummaryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isNewOrder = false;
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    if (self.navigationController.viewControllers[0] != self)
        self.navigationItem.leftBarButtonItem = nil;
    else
    {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        [appDelegate.notificationUtils getSlidingMenuBarButtonSetupWith:self];
    }
    if (self.selectedOrder != nil)
    {
        self.txtTable.text = [NSString stringWithFormat:@"%d", self.selectedOrder.tableNumber.intValue];
        self.txtPartySize.text = [NSString stringWithFormat:@"%d", self.selectedOrder.guestCount.intValue];
        self.txtCheckId.text = [NSString stringWithFormat:@"%d", self.selectedOrder.poscheckId.intValue];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    if (self.selectedOrder == nil)
    {
        self.selectedOrder = [[GTLStoreendpointStoreOrder alloc]init];
        self.selectedOrder.storeId = appDelegate.globalObjectHolder.selectedStore.identifier;
        self.selectedOrder.storeName = appDelegate.globalObjectHolder.selectedStore.name;
        self.selectedOrder.guestCount = 0;  // intValue
        self.selectedOrder.orderMode = [NSNumber numberWithInt:[DeliveryOrCarryoutViewController ORDERTYPE_DININGIN]];  // intValue
        self.isNewOrder = true;
    }
    [self updateOrderStringFromOrderInProgress];
    [self parsePOSCheckDetails];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.finalItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MenuItemCell" forIndexPath:indexPath];
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
    
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If row is deleted, remove it from the list.
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        OrderItemSummaryFromPOS *item = [self.finalItems objectAtIndex:indexPath.row];
        int deletedEntryId = item.entryId;
        for (OrderItemSummaryFromPOS *anotherItem in self.finalItems)
        {
            if (anotherItem.entryId == deletedEntryId || anotherItem.parentEntryId == deletedEntryId)
            {
                NSLog(@"%@", self.selectedOrder.orderDetails);
                NSString *XMLOrderStr = [XMLPOSOrder buildPOSResponseXMLByRemovingItem:anotherItem.entryId FromOrderString:self.selectedOrder.orderDetails];
                self.selectedOrder.orderDetails = XMLOrderStr;
            }
        }
        [self parsePOSCheckDetails];
        [self.tableView reloadData];
    }
}

- (double)subTotalNoDiscountFull
{
    NSUInteger subTotalNoDiscount = 0;
    for (OrderItemSummaryFromPOS *item in self.finalItems)
        subTotalNoDiscount += item.price*item.qty;
    return subTotalNoDiscount;
}

- (double)discount
{
    return self.discountAmt;
}

- (void)saveClicked
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
    self.selectedOrder.tableNumber = [NSNumber numberWithInt:[self.txtTable.text intValue]];
    self.selectedOrder.guestCount = [NSNumber numberWithInt:[self.txtPartySize.text intValue]];
    self.selectedOrder.poscheckId = [NSNumber numberWithInt:[self.txtCheckId.text intValue]];
    
    if (self.isNewOrder == true && IsEmpty(self.selectedOrder.orderDetails))
        return;

    [self.receiver changedOrder:self.selectedOrder];
    GTLQueryStoreendpoint *query = [GTLQueryStoreendpoint queryForUpdateOrderFromServerWithObject:self.selectedOrder];
    
    NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
    dic[USER_AUTH_TOKEN_HEADER_NAME]=[UtilCalls getAuthTokenForCurrentUser];
    
    [query setAdditionalHTTPHeaders:dic];
    
    [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id object,NSError *error)
     {
         if(error)
         {
             NSLog(@"ServerOrderSummary: queryForUpdateOrderFromServerWithObject Error:%@",[error userInfo][@"error"]);
         }
     }];
}

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

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:YES];
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
    self.selectedOrder.orderStatus = [NSNumber numberWithInt:5]; // Status = closed
    [self performSegueWithIdentifier:@"segueUnwindOrderToServerTable" sender:sender];
}

- (void)updateOrderStringFromOrderInProgress
{
    self.selectedOrder.tableNumber = [NSNumber numberWithInt:[self.txtTable.text intValue]];
    self.selectedOrder.guestCount = [NSNumber numberWithInt:[self.txtPartySize.text intValue]];
    self.selectedOrder.poscheckId = [NSNumber numberWithInt:[self.txtCheckId.text intValue]];

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    if(appDelegate.globalObjectHolder.orderInProgress == nil)
        return;
    NSString *XMLOrderStr;
    
    if (IsEmpty(self.selectedOrder.orderDetails) == true)
        XMLOrderStr = [XMLPOSOrder buildPOSResponseXML:appDelegate.globalObjectHolder.orderInProgress gratuity:0.0 discountTitle:nil discountAmount:0 subTotal:0 deliveryFee:0 taxAmount:0 finalAmount:0 guestCount:self.selectedOrder.guestCount.intValue tableNumber:self.selectedOrder.tableNumber.intValue];
    else
        XMLOrderStr = [XMLPOSOrder buildPOSResponseXMLByAddingNewItems:appDelegate.globalObjectHolder.orderInProgress ToOrderString:self.selectedOrder.orderDetails];
    self.selectedOrder.orderDetails = XMLOrderStr;
    appDelegate.globalObjectHolder.orderInProgress = nil;
}

- (MutableOrderedDictionary *)getCheckItemsFromXML:(NSString *)strPOSCheckDetails
{
    if (IsEmpty(strPOSCheckDetails))
        return nil;
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
        orderItemSummaryFromPOS.desc = [entry attribute:@"OPTION"];
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
    for (int i = 0; i < items.count; i++)
    {
        OrderItemSummaryFromPOS *item = [items objectAtIndex:i];
        [self.finalItems addObject:item];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"segueShowServerOrderToSelectGroup"])
    {
        ServerSelectGroupTableViewController *controller = [segue destinationViewController];
        [controller setSelectedOrder:self.selectedOrder];
    }
    else if ([[segue identifier] isEqualToString:@"segueServerOrderSummaryToMenu"])
    {
        MenuTableViewController *controller = [segue destinationViewController];
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        [controller setSelectedStore:appDelegate.globalObjectHolder.selectedStore];
        [controller setBMenuIsInOrderMode:YES];
    }
}

- (IBAction)unwindToServerOrderSummary:(UIStoryboardSegue *)unwindSegue
{
}

@end
