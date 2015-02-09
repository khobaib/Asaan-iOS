//
//  ReviewsSummaryTableViewController.m
//  AsaanImprovedUI
//
//  Created by Nirav Saraiya on 2/5/15.
//  Copyright (c) 2015 Nirav Saraiya. All rights reserved.
//

#import "ReviewsSummaryTableViewController.h"
#import "GTLStoreendpoint.h"
#import "GTMHTTPFetcher.h"
#import "AppDelegate.h"
#import "InlineCalls.h"
#import "UtilCalls.h"
#import "MBProgressHUD.h"
#import "DataProvider.h"
#import "ReviewLoadingOperation.h"

@interface ReviewsSummaryTableViewController ()<DataProviderDelegate>

@property (nonatomic, strong) MBProgressHUD *hud;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) int startPosition;
@property (nonatomic) int maxResult;
@property (strong, nonatomic) UIImage *imgLike;
@property (strong, nonatomic) UIImage *imgDislike;

// Chat Test
@property (strong, nonatomic) UITabBarController *tabBarController;

@end

@implementation ReviewsSummaryTableViewController
@synthesize startPosition = _startPosition;
@synthesize maxResult = _maxResult;
@synthesize dataProvider = _dataProvider;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupReviewHistoryData];
    
    self.imgLike = [UIImage imageNamed:@"ic_good_rating"];
    self.imgDislike = [UIImage imageNamed:@"ic_bad_rating"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
    {
        self.tableView.estimatedRowHeight = 110;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
    }
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [self.tableView reloadData];
}

- (void)setupReviewHistoryData
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
        GTLQueryStoreendpoint *query;
        
        if (self.selectedStore != nil)
            query = [GTLQueryStoreendpoint queryForGetOrderReviewsForStoreWithStoreId:self.selectedStore.store.identifier.longValue firstPosition:0 maxResult:FluentPagingTablePageSize]; //queryForGetStoreOrdersForCurrentUserAndStoreWithStoreId:self.selectedStore.identifier.longValue firstPosition:0 maxResult:FluentPagingTablePageSize];
        else
            query = [GTLQueryStoreendpoint queryForGetStoreOrdersForCurrentUserWithFirstPosition:0 maxResult:FluentPagingTablePageSize];
        NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
        dic[USER_AUTH_TOKEN_HEADER_NAME]=[UtilCalls getAuthTokenForCurrentUser];
        
        [query setAdditionalHTTPHeaders:dic];
        
        [gtlStoreService executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLStoreendpointOrderReviewListAndCount *object,NSError *error)
         {
             if(!error)
             {
                 if (object.reviews.count > 0)
                 {
                     _dataProvider = [[DataProvider alloc] initWithPageSize:object.reviews.count itemCount:object.count.longValue];
                     _dataProvider.delegate = weakSelf;
                     _dataProvider.shouldLoadAutomatically = YES;
                     _dataProvider.automaticPreloadMargin = FluentPagingTablePreloadMargin;
                     [_dataProvider setInitialObjects:object.reviews ForPage:1];
                 }
             }else{
                 NSLog(@"setupOrderHistoryData Error:%@",[error userInfo]);
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
    ReviewLoadingOperation *milo = [[ReviewLoadingOperation alloc] initWithIndexes:indexes];
    return milo;
}

- (void)dataProvider:(DataProvider *)dataProvider willLoadDataAtIndexes:(NSIndexSet *)indexes
{
    [self.hud hide:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return 1;
    else
        return self.dataProvider.dataObjects.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0)
        return @"Summary";
    else
        return @"Reviews";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
        return [self setupSummaryCellAtIndexPath:indexPath];
    else
        return [self setupReviewCellAtIndexPath:indexPath];
}

- (UITableViewCell *)setupSummaryCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"SummaryCell" forIndexPath:indexPath];
    cell.tag = indexPath.row;

    UILabel *txtCustomers=(UILabel *)[cell viewWithTag:501];
    UILabel *txtFood=(UILabel *)[cell viewWithTag:502];
    UILabel *txtService=(UILabel *)[cell viewWithTag:503];
    
    NSString *strVisitCount = [UtilCalls formattedNumber:self.selectedStore.stats.visits];
    NSString *str = [NSString stringWithFormat:@"%@ every week", strVisitCount];
    txtCustomers.text = str;
    
    txtFood.text = [UtilCalls getFoodReviewStringFromStats:self.selectedStore];
    txtService.text = [UtilCalls getServiceReviewStringFromStats:self.selectedStore];
    
    return cell;
}

- (UITableViewCell *)setupReviewCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ReviewDetailCell" forIndexPath:indexPath];
    cell.tag = indexPath.row;
    
    UILabel *txtPersonNameAndDate=(UILabel *)[cell viewWithTag:501];
    UILabel *txtReview=(UILabel *)[cell viewWithTag:504];
    txtPersonNameAndDate.text = nil;
    txtReview.text = nil;
    GTLStoreendpointOrderReview *review = self.dataProvider.dataObjects[indexPath.row];
    if (![review isKindOfClass:[NSNull class]])
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:review.createdDate.longValue/1000];
        txtPersonNameAndDate.text = [NSString stringWithFormat:@"%@ %@", review.userName, [dateFormatter stringFromDate:date]];
        
        UIImageView *imgFoodLike = (UIImageView *)[cell viewWithTag:502];
        UIImageView *imgServiceLike = (UIImageView *)[cell viewWithTag:503];
        if (review.foodLike.intValue > 0 && review.foodLike.intValue < 140)
            imgFoodLike.image = self.imgLike;
        else
            imgFoodLike.image = self.imgDislike;
        if (review.serviceLike.intValue > 0 && review.serviceLike.intValue < 140)
            imgServiceLike.image = self.imgLike;
        else
            imgServiceLike.image = self.imgDislike;
        
        txtReview.text = review.comments;
    }
    
    return cell;
}
//- (CGFloat)tableView:(UITableView *)tableView
//estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 100;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView
//heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
////    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
////        return UITableViewAutomaticDimension;
////    else
//        return 100;
//}
@end
