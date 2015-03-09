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

@interface OrderHistoryTableViewController ()<DataProviderDelegate>
@property (nonatomic) int startPosition;
@property (nonatomic) int maxResult;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) GTLStoreendpointStoreOrder *selectedOrder;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
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
    
    if (self.selectedStore == nil)
    {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        [appDelegate.notificationUtils getSlidingMenuBarButtonSetupWith:self];
    }
}

- (void)setupOrderHistoryData {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Please Wait";
    hud.hidden = NO;
    
    if (self)
    {
        __weak __typeof(self) weakSelf = self;
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        GTLServiceStoreendpoint *gtlStoreService= [appDelegate gtlStoreService];
        GTLQueryStoreendpoint *query;
        
        if (self.selectedStore != nil)
            query = [GTLQueryStoreendpoint queryForGetStoreOrdersForCurrentUserAndStoreWithStoreId:self.selectedStore.identifier.longLongValue firstPosition:0 maxResult:FluentPagingTablePageSize];
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
                     _dataProvider = [[DataProvider alloc] initWithPageSize:object.orders.count itemCount:object.count.longLongValue];
                     _dataProvider.delegate = weakSelf;
                     _dataProvider.shouldLoadAutomatically = YES;
                     _dataProvider.automaticPreloadMargin = FluentPagingTablePreloadMargin;
                    [_dataProvider setInitialObjects:object.orders ForPage:1];
                 }
             }else{
                 NSLog(@"setupOrderHistoryData Error:%@",[error userInfo][@"error"]);
             }
             [weakSelf.tableView reloadData];
             hud.hidden = YES;
         }];
    }
}

#pragma mark -
#pragma mark  === DataProviderDelegate ===
#pragma mark -

- (void)dataProvider:(DataProvider *)dataProvider didLoadDataAtIndexes:(NSIndexSet *)indexes
{
    
    NSMutableArray *indexPathsToReload = [NSMutableArray array];
    
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
        
        if ([self.tableView.indexPathsForVisibleRows containsObject:indexPath]) {
            [indexPathsToReload addObject:indexPath];
        }
    }];
    
    if (indexPathsToReload.count > 0) {
        [self.tableView reloadRowsAtIndexPaths:indexPathsToReload withRowAnimation:UITableViewRowAnimationFade];
    }
    [self.hud hide:YES];
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
    [self.hud hide:NO];
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
    return self.dataProvider.dataObjects.count;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewCell *headerCell = [tableView dequeueReusableCellWithIdentifier:@"HeaderCell"];
    
    NSString *title = @"All Restaurants";
    if (self.selectedStore != nil)
        title = self.selectedStore.name;

    [UtilCalls setupHeaderView:headerCell WithTitle:title AndSubTitle:@"Order History"];
    return headerCell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OrderCell" forIndexPath:indexPath];
    cell.tag = indexPath.row;
    
    UILabel *txtTitle=(UILabel *)[cell viewWithTag:501];
    UILabel *txtSubtitle=(UILabel *)[cell viewWithTag:502];
    txtTitle.text = nil;
    txtSubtitle.text = nil;
    GTLStoreendpointStoreOrder *order = self.dataProvider.dataObjects[indexPath.row];
    if (![order isKindOfClass:[NSNull class]])
    {
        txtTitle.text = order.storeName;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:order.createdDate.longLongValue/1000];
        
        txtSubtitle.text = [dateFormatter stringFromDate:date];
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
