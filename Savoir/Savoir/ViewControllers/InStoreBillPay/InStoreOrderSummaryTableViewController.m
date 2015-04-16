//
//  InStoreOrderSummaryTableViewController.m
//  Savoir
//
//  Created by Nirav Saraiya on 4/5/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import "InStoreOrderSummaryTableViewController.h"
#import "AppDelegate.h"
#import "OrderItemSummaryFromPOS.h"
#import "RXMLElement.h"
#import "OrderedDictionary.h"
#import "InlineCalls.h"
#import "UtilCalls.h"
#import "MBProgressHUD.h"
#import "InStoreOrderReceiver.h"

@interface InStoreOrderSummaryTableViewController () <InStoreOrderReceiver>
@property (strong, nonatomic) GTLStoreendpointStoreOrder *selectedOrder;
@property (nonatomic, strong) NSMutableArray *finalItems;
@end

@implementation InStoreOrderSummaryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    if (self.navigationController.viewControllers[0] != self)
        self.navigationItem.leftBarButtonItem = nil;
    else
    {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        [appDelegate.notificationUtils getSlidingMenuBarButtonSetupWith:self];
    }
    
    NSLog(@"InStoreOrderSummaryTableViewController viewDidLoad");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self refreshOrderDetails];
    NSLog(@"InStoreOrderSummaryTableViewController viewWillAppear");
}

- (void)orderChanged
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    self.finalItems = [appDelegate.globalObjectHolder.inStoreOrderDetails parseOrderDetails];
    [self.tableView reloadData];
    NSLog(@"InStoreOrderSummaryTableViewController orderChanged finalItems count = %lu", (unsigned long)self.finalItems.count);
}

- (void) tableGroupMemberChanged
{
    // Don't Care.
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
