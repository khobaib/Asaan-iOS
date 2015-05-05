//
//  OrderHistoryTableViewController.m
//  Savoir
//
//  Created by Nirav Saraiya on 1/16/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import "OrderHistoryTableViewController.h"
#import "OrderHistorySummaryTableViewController.h"
#import "DataProvider.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "OrderForStoreLoadingOperation.h"
#import "OrderLoadingOperation.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "UtilCalls.h"
#import "Constants.h"
#import "InlineCalls.h"

@interface OrderHistoryTableViewController ()<DataProviderDelegate>
@property (nonatomic) int startPosition;
@property (nonatomic) int maxResult;
@property (nonatomic, strong) GTLStoreendpointStoreOrder *selectedOrder;

@end

@implementation OrderHistoryTableViewController
@synthesize startPosition = _startPosition;
@synthesize maxResult = _maxResult;
@synthesize dataProvider = _dataProvider;
@synthesize selectedStore = _selectedStore;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupOrderHistoryData];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    appDelegate.topViewController = self;
    
    if (self.selectedStore == nil)
    {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        [appDelegate.notificationUtils getSlidingMenuBarButtonSetupWith:self];
    }
}

- (void)setupOrderHistoryData {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    if (self)
    {
        __weak __typeof(self) weakSelf = self;
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
        GTLQueryStoreendpoint *query;
        
        if (self.selectedStore != nil)
            query = [GTLQueryStoreendpoint queryForGetStoreOrdersForCurrentUserAndStoreWithFirstPosition:0 maxResult:FluentPagingTablePageSize storeId:self.selectedStore.identifier.longLongValue];
        else
            query = [GTLQueryStoreendpoint queryForGetStoreOrdersForCurrentUserWithFirstPosition:0 maxResult:FluentPagingTablePageSize];
        NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
        dic[USER_AUTH_TOKEN_HEADER_NAME]=[UtilCalls getAuthTokenForCurrentUser];
        
        [query setAdditionalHTTPHeaders:dic];       
        
        [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLStoreendpointStoreOrderListAndCount *object,NSError *error)
        {
             if(!error)
             {
                 if (object.orders.count > 0)
                 {
                     _dataProvider = [[DataProvider alloc] initWithPageSize:object.orders.count itemCount:object.count.intValue];
                     _dataProvider.delegate = weakSelf;
                     _dataProvider.shouldLoadAutomatically = YES;
                     _dataProvider.automaticPreloadMargin = FluentPagingTablePreloadMargin;
                    [_dataProvider setInitialObjects:object.orders ForPage:1];
                 }
             }else{
                 NSString *msg = [NSString stringWithFormat:@"Failed to obtain order history. Please retry in a few minutes. If this error persists please contact Savoir Customer Assistance team. Error: %@", [error userInfo][@"error"]];
                 [[[UIAlertView alloc]initWithTitle:@"Error" message:msg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                 NSLog(@"setupOrderHistoryData Error:%@",[error userInfo][@"error"]);
             }
             [weakSelf.tableView reloadData];
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
         }];
    }
}

#pragma mark -
#pragma mark  === DataProviderDelegate ===
#pragma mark -

- (void)dataProvider:(DataProvider *)dataProvider didLoadDataAtIndexes:(NSIndexSet *)indexes
{
    
//    NSMutableArray *indexPathsToReload = [NSMutableArray array];
//    
//    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
//        
//        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
//        
//        if ([self.tableView.indexPathsForVisibleRows containsObject:indexPath]) {
//            [indexPathsToReload addObject:indexPath];
//        }
//    }];
//    
//    if (indexPathsToReload.count > 0) {
//        [self.tableView reloadRowsAtIndexPaths:indexPathsToReload withRowAnimation:UITableViewRowAnimationFade];
//    }
    [self.tableView reloadRowsAtIndexPaths:self.tableView.indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationFade];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (DataLoadingOperation *) getDataLoadingOperationForPage:(NSUInteger)page indexes:(NSIndexSet *)indexes
{
    if (self.selectedStore != nil)
    {
        OrderForStoreLoadingOperation *milo = [[OrderForStoreLoadingOperation alloc] initWithIndexes:indexes storeId:self.selectedStore.identifier.longLongValue];
        return milo;
    }
    else
    {
        OrderLoadingOperation *milo = [[OrderLoadingOperation alloc] initWithIndexes:indexes];
        return milo;
    }
}

- (void)dataProvider:(DataProvider *)dataProvider willLoadDataAtIndexes:(NSIndexSet *)indexes
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Display a message when the table is empty
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.dataProvider.dataObjects.count == 0)
    {
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        messageLabel.text = @"No order history information is currently available.";
        messageLabel.textColor = [UIColor whiteColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        [messageLabel sizeToFit];
        
        self.tableView.backgroundView = messageLabel;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        return 0;
    }
    else
    {
        self.tableView.backgroundView = nil;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        return self.dataProvider.dataObjects.count;
    }
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewCell *headerCell = [tableView dequeueReusableCellWithIdentifier:@"HeaderCell"];
    headerCell.backgroundColor = [UIColor clearColor];
    NSString *title = @"All Restaurants";
    if (self.selectedStore != nil)
        title = self.selectedStore.name;

    [UtilCalls setupHeaderView:headerCell WithTitle:title AndSubTitle:@"Order History"];
    return headerCell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OrderCell" forIndexPath:indexPath];
    cell.tag = indexPath.row;
    cell.backgroundColor = [UIColor clearColor];
    GTLStoreendpointStoreOrder *order = self.dataProvider.dataObjects[indexPath.row];
    long row = (long)indexPath.row;
    NSLog(@"Order at index: %ld", row);
    if (![order isKindOfClass:[NSNull class]])
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:order.createdDate.longLongValue/1000];
        
        cell.textLabel.text = order.storeName;
        cell.detailTextLabel.text = [dateFormatter stringFromDate:date];
        
        if (IsEmpty(cell.detailTextLabel.text))
            NSLog(@"txtSubtitle.text = %@ for row = %ld", cell.detailTextLabel.text, row);
    }
    else
    {
        NSLog(@"Found nil order at index: %ld", row);
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedOrder = self.dataProvider.dataObjects[indexPath.row];
    [self performSegueWithIdentifier:@"segueOrderHistoryToOrderSummary" sender:self];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"segueOrderHistoryToOrderSummary"])
    {
        OrderHistorySummaryTableViewController *controller = [segue destinationViewController];
        [controller setSelectedOrder:self.selectedOrder];
    }
}

@end
